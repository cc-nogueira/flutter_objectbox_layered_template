import 'dart:ui';

import 'package:objectbox/objectbox.dart';

import '../model.dart';

/// Contact persistence model.
///
/// Implements Model with default values for all fields.
/// @see [ContactMapper] for conversion to Entity details.
@Entity()
class ContactModel implements Model {
  /// Constructor with all default values.
  ContactModel({
    this.id = 0,
    this.uuid = '',
    this.name = '',
  });

  /// ObjectBox key field.
  @override
  int id;

  /// Domain unique identifier reference in chats.
  String uuid;

  // Contact name
  String name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactModel && other.id == id && other.uuid == uuid && other.name == name;

  @override
  int get hashCode => hashValues(id, uuid, name);

  @override
  String toString() => 'ContactModel(id: $id, uuid: "$uuid", name: "$name")';
}
