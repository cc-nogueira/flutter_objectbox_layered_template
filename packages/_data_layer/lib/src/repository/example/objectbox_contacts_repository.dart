import 'package:_domain_layer/domain_layer.dart';

import '../../../objectbox.g.dart';
import '../../mapper/example/contact_mapper.dart';
import '../../model/example/contact_model.dart';
import '../objectbox_repository.dart';

/// ObjectBox Contacts Repository implementation.
///
/// Implements domain ContactsRepository as an ObjectBoxRepository
class ObjectboxContactsRepository extends ObjectboxRepository<Contact, ContactModel>
    implements ContactsRepository {
  /// Const constructor receives a Box<ContactModel>.
  const ObjectboxContactsRepository({required super.box}) : super(mapper: const ContactMapper());

  /// Id of my model
  @override
  get idProperty => ContactModel_.id;

  /// uuid property for query by Uuid
  get uuidProperty => ContactModel_.uuid;

  @override
  Contact getByUuid(String uuid) {
    final model = _getModelByUuid(uuid);
    if (model == null) {
      throw const EntityNotFoundException();
    }
    return mapper.mapEntity(model);
  }

  ContactModel? _getModelByUuid(String uuid) =>
      box.query(uuidProperty.equals(uuid)).build().findFirst();
}
