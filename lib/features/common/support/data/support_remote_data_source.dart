import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/features/common/support/data/support_model.dart';
import 'package:mishwar/features/common/support/domain/support_ticket.dart';

@lazySingleton
class SupportRemoteDataSource {
  const SupportRemoteDataSource(this._db, this._functions);
  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;
  Stream<List<SupportTicketModel>> watchTickets({
    String? uid,
    SupportStatus? status,
  }) {
    Query<Map<String, dynamic>> query = _db.collection('supportTickets');
    if (uid != null) query = query.where('uid', isEqualTo: uid);
    if (status != null) query = query.where('status', isEqualTo: status.code);
    return query
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map(
          (s) => s.docs
              .map(
                (d) => SupportTicketModel.fromJson({...d.data(), 'id': d.id}),
              )
              .toList(),
        );
  }

  Stream<SupportTicketModel> watchTicket(String id) =>
      _db.doc('supportTickets/$id').snapshots().map((d) {
        if (!d.exists) throw StateError('support-not-found');
        return SupportTicketModel.fromJson({...d.data()!, 'id': d.id});
      });
  Stream<List<SupportMessageModel>> watchMessages(String id) => _db
      .collection('supportTickets/$id/messages')
      .orderBy('createdAt')
      .snapshots()
      .map(
        (s) => s.docs
            .map((d) => SupportMessageModel.fromJson({...d.data(), 'id': d.id}))
            .toList(),
      );
  Future<String> create(
    SupportCategory category,
    String message, {
    String? rideId,
  }) async {
    final result = await _functions
        .httpsCallable('createSupportTicket')
        .call<Map<String, dynamic>>({
          'category': category.code,
          'message': message,
          'rideId': ?rideId,
        });
    return result.data['ticketId'] as String;
  }

  Future<void> send(String id, String text, {bool admin = false}) async {
    if (admin) {
      await _functions.httpsCallable('replySupportTicket').call<void>({
        'ticketId': id,
        'text': text,
      });
    } else {
      await _db.collection('supportTickets/$id/messages').add({
        'from': 'user',
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> markRead(String id) =>
      _db.doc('supportTickets/$id').update({'userUnread': false});
  Future<void> setStatus(String id, SupportStatus status) async {
    await _functions.httpsCallable('setSupportTicketStatus').call<void>({
      'ticketId': id,
      'status': status.code,
    });
  }
}
