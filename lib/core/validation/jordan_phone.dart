/// Normalizes the national Jordanian mobile input used at sign-in.
String? normalizeJordanPhone(String phone) {
  if (!RegExp(r'^0?7[0-9]{8}$').hasMatch(phone) || phone.endsWith('\n')) {
    return null;
  }
  return '+962${phone.startsWith('0') ? phone.substring(1) : phone}';
}
