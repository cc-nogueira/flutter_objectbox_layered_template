import 'dart:ui';

import 'package:objectbox/objectbox.dart';

import '../model.dart';

@Entity()
class ContactModel implements Model {
  ContactModel({this.id = 0, this.uuid = '', this.name = ''});

  @override
  int id;

  String uuid;
  String name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactModel &&
          other.id == id &&
          other.uuid == uuid &&
          other.name == name;

  @override
  int get hashCode => hashValues(id, uuid, name);

  @override
  String toString() => 'ContactModel(id: $id, uuid: "$uuid", name: "$name")';
}
