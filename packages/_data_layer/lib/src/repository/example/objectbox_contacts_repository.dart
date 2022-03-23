import 'package:_domain_layer/domain_layer.dart';

import '../../../objectbox.g.dart';
import '../../mapper/example/contact_mapper.dart';
import '../../model/example/contact_model.dart';
import '../objectbox_repository.dart';

class ObjectboxContactsRepository
    extends ObjectboxRepository<Contact, ContactModel>
    implements ContactsRepository {
  ObjectboxContactsRepository({required Box<ContactModel> box})
      : super(box: box, mapper: const ContactMapper());

  /// Id of my model
  @override
  get idProperty => ContactModel_.id;
  get uuidProperty => ContactModel_.uuid;

  @override
  Contact getByUuid(String uuid) {
    final q = box.query(uuidProperty.equals(uuid)).build();
    final model = q.findFirst();
    if (model == null) {
      throw const EntityNotFoundException();
    }
    return mapper.mapEntity(model);
  }
}
