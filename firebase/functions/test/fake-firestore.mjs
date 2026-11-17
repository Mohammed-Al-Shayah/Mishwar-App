import { FieldValue, Timestamp } from 'firebase-admin/firestore';
const nested = (data, path) => path.split('.').reduce((v, key) => v?.[key], data);
const scalar = (value) => value?.toMillis?.() ?? value;
// Atomic, serialized in-memory transactions, including queries and transforms.
export class FakeFirestore {
  records = new Map(); sequence = 0; queue = Promise.resolve();
  constructor(seed = {}) { for (const [path, data] of Object.entries(seed)) this.records.set(path, data); }
  doc(path) { return { path, id: path.split('/').at(-1), get: async () => this.snapshot(path) }; }
  snapshot(path) { const data = this.records.get(path); return { id: path.split('/').at(-1), ref: this.doc(path), exists: !!data, data: () => data }; }
  collection(name) {
    const query = (filters = [], count = Infinity, order, start, end) => ({
      where: (field, op, value) => query([...filters, [field, op, value]], count, order, start, end),
      limit: (n) => query(filters, n, order, start, end),
      orderBy: (field) => query(filters, count, field, start, end),
      startAt: (value) => query(filters, count, order, value, end),
      endAt: (value) => query(filters, count, order, start, value),
      get: async () => {
        const docs = [...this.records.keys()].filter((path) => path.startsWith(name + '/')).map((path) => this.snapshot(path))
          .filter((doc) => filters.every(([field, op, value]) => {
            const actual = nested(doc.data(), field);
            if (op === 'array-contains') return actual?.includes(value);
            if (op === '>=') return scalar(actual) >= scalar(value);
            if (op === '<=') return scalar(actual) <= scalar(value);
            return op === '==' ? actual === value : op === 'in' ? value.includes(actual) : scalar(actual) < scalar(value);
          })).filter((doc) => !order || (nested(doc.data(), order) !== undefined &&
            (start === undefined || nested(doc.data(), order) >= start) &&
            (end === undefined || nested(doc.data(), order) <= end)))
          .sort((a, b) => order ? String(nested(a.data(), order)).localeCompare(String(nested(b.data(), order))) : 0).slice(0, count);
        return { docs, empty: docs.length === 0 };
      },
      doc: () => this.doc(name + '/ride-' + ++this.sequence),
    });
    return query();
  }
  batch() {
    const writes = [];
    const batch = {
      update: (ref, data) => { writes.push(() => {
        const next = { ...this.records.get(ref.path) };
        for (const [key, value] of Object.entries(data)) {
          const parts = key.split('.'); let target = next;
          while (parts.length > 1) { const part = parts.shift(); target[part] = { ...target[part] }; target = target[part]; }
          target[parts[0]] = value;
        }
        this.records.set(ref.path, next);
      }); return batch; },
      delete: ref => { writes.push(() => this.records.delete(ref.path)); return batch; },
      commit: async () => { if (writes.length > 500) throw Error('Batch too large'); for (const write of writes) write(); },
    };
    return batch;
  }
  runTransaction(body) {
    const result = this.queue.then(async () => {
      const writes = [];
      const tx = { get: (ref) => { if (writes.length) throw Error('Read after write'); return ref.get(); }, create: (ref, data) => writes.push([ref, data]),
        set: (ref, data) => writes.push([ref, data]), update: (ref, data) => writes.push([ref, data]) };
      const result = await body(tx);
      for (const [ref, data] of writes) {
        const next = { ...this.records.get(ref.path) };
        for (const [key, value] of Object.entries(data)) {
          if (value?.isEqual?.(FieldValue.delete())) delete next[key];
          else if (value?.constructor?.name === 'ArrayUnionTransform') next[key] = [...new Set([...(next[key] ?? []), ...value.elements])];
          else next[key] = value?.isEqual?.(FieldValue.serverTimestamp()) ? Timestamp.fromMillis(1000) : value;
        }
        this.records.set(ref.path, next);
      }
      return result;
    });
    this.queue = result.catch(() => {});
    return result;
  }
}
