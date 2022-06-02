import 'package:_domain_layer/domain_layer.dart';

import '../../model/example/contact_model.dart';
import '../entity_mapper.dart';

/// ContactMapper to convert domain entities to persistence models and vice-versa.
class ContactMapper extends EntityMapper<Contact, ContactModel> {
  /// Const constructor.
  const ContactMapper();

  /// Map a persistence model to a domain entity.
  @override
  Contact mapEntity(ContactModel model) =>
      Contact(id: model.id, uuid: model.uuid, name: model.name);

  /// Map a domain entity to a persistence model.
  @override
  ContactModel mapModel(Contact entity) =>
      ContactModel(id: entity.id, uuid: entity.uuid, name: entity.name);
}
