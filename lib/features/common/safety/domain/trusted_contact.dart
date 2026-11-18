import 'package:equatable/equatable.dart';

class TrustedContact extends Equatable {
  const TrustedContact({
    required this.id,
    required this.name,
    required this.phone,
  });
  final String id;
  final String name;
  final String phone;
  @override
  List<Object?> get props => [id, name, phone];
}

bool validTrustedContact(TrustedContact contact) =>
    contact.name.trim().isNotEmpty &&
    contact.name.trim().runes.length <= 40 &&
    contact.phone.length <= 20 &&
    RegExp(r'^\+[1-9][0-9]{1,14}$').hasMatch(contact.phone) &&
    !contact.phone.endsWith('\n');
