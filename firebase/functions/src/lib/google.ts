import { logger } from 'firebase-functions';
import { HttpsError } from 'firebase-functions/v2/https';
export type Fetch = typeof fetch;
export async function google<T>(url: string, init: RequestInit, fetchImpl: Fetch = fetch, timeoutMs = 8000): Promise<T> {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), timeoutMs);
    try {
        const response = await fetchImpl(url, { ...init, signal: controller.signal });
        if (!response.ok) {
            logger.error('Google request failed', { status: response.status });
            throw new HttpsError(response.status >= 500 ? 'unavailable' : 'internal', 'Map service request failed.');
        }
        return await response.json() as T;
    }
    catch (error) {
        if (error instanceof HttpsError)
            throw error;
        // Never log exception messages, URLs, headers or response bodies.
        logger.error('Google request could not complete', { timeout: controller.signal.aborted });
        throw new HttpsError('unavailable', 'Map service is unavailable.');
    }
    finally {
        clearTimeout(timer);
    }
}
