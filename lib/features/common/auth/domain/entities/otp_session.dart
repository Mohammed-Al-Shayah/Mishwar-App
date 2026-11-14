/// Opaque attempt identity; Firebase handles remain in the data layer.
///
/// Identity equality intentionally keeps separate web attempts distinct.
class OtpSession {
  const OtpSession({
    required this.phone,
    this.verificationId,
    this.resendToken,
    this.autoVerified = false,
  });
  final String? verificationId;
  final String phone;
  final int? resendToken;
  final bool autoVerified;
}
