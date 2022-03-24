import '../../entity/example/contact.dart';
import '../entity_stream_repository.dart';

/// Contacts Repository interface.
///
/// Most method return values may be watched by StreamProviders.
abstract class ContactsRepository extends EntityStreamRepository<Contact> {
  /// Get a Contact from storage by uuid.
  ///
  /// Throws an [EntityNotFoundException] if no contact has this uuid.
  Contact getByUuid(String uuid);
}
