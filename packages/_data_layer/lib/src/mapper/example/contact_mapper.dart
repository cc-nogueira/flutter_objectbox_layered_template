import 'package:_domain_layer/domain_layer.dart';

import '../../model/example/contact_model.dart';
import '../entity_mapper.dart';

class ContactMapper extends EntityMapper<Contact, ContactModel> {
  const ContactMapper();

  @override
  Contact mapEntity(ContactModel model) =>
      Contact(id: model.id, uuid: model.uuid, name: model.name);

  @override
  ContactModel mapModel(Contact entity) =>
      ContactModel(id: entity.id, uuid: entity.uuid, name: entity.name);
}
