import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../../entity/example/contact.dart';
import '../../entity/example/message.dart';
import '../../exception/validation_exception.dart';
import '../../repository/example/contacts_repository.dart';
import '../../service/example/message_service.dart';
import '../entity_stream_usecase.dart';

/// Usecase with Contacts business rules.
///
/// This class must be injected with [ContactsNotifierRepository] and [MessageService]
/// implementations. See [domainConfigurationProvider].
///
/// It provides an API to access and update [Contact] entities.
class ContactsUsecase extends EntityStreamUsecase<Contact> {
  ContactsUsecase({
    required ContactsRepository super.repository,
    required MessageService messageService,
  }) : _messageService = messageService;

  @internal
  @override
  ContactsRepository get repository => super.repository as ContactsRepository;

  final MessageService _messageService;
  final _uuid = const Uuid();

  /// Get a Contact from repository by uuid.
  ///
  /// Expects repository to throw an [EntityNotFoundException] if no contact has
  /// this uuid.
  Contact getByUuid(String uuid, {required Contact Function() orElse}) {
    try {
      return repository.getByUuid(uuid);
    } on Exception {
      return orElse();
    }
  }

  /// Get a Message from MessageService async invocation.
  ///
  /// Returns a Future for current message for a contact.
  /// Expects the future to return null if there are no messages for this contact.
  Future<Message?> getMessageFor(contact) => _messageService.getMessageFor(contact);

  /// Compare two contacts by name
  @override
  int compare(Contact a, Contact b) => a.name.compareTo(b.name);

  /// Validate contact's content.
  ///
  /// Throws a validation exception if contact's name is empty.
  @override
  void validate(Contact contact) {
    if (contact.name.trim().isEmpty) {
      throw const ValidationException('Contact\'s name should not be empty');
    }
  }

  /// Adjust contact's contents.
  ///
  /// Generates contact's uuid when it is empty.
  /// Trim contacts name if necessary.
  @override
  Contact adjust(Contact contact) {
    var adjusted = contact.uuid.isEmpty ? contact.copyWith(uuid: _uuid.v4()) : contact;

    final adjustedName = contact.name.trim();
    if (contact.name != adjustedName) {
      adjusted = adjusted.copyWith(name: adjustedName);
    }

    return adjusted;
  }
}
