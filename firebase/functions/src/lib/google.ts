import { logger } from 'firebase-functions';
import { HttpsError } from 'firebase-functions/v2/https';
export type Fetch = typeof fetch;
export async function google<T>(url: string, init: RequestInit, fetchImpl: Fetch = fetch, timeoutMs = 8000): Promise<T> {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), timeoutMs);
    try {
        const response = await fetchImpl(url, { ...init, signal: controller.signal });
        if (!response.ok) {
            // Only Google's error code and reason are logged (e.g. API_KEY_INVALID); never the body or key.
            const body = await response.json().catch(() => undefined) as
                { error?: { status?: string; details?: { reason?: string }[] } } | undefined;
            logger.error('Google request failed', { status: response.status, googleStatus: body?.error?.status,
                reason: body?.error?.details?.find(d => d?.reason)?.reason });
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
