import 'dart:ui';

import 'package:riverpod/riverpod.dart';

import '../entity/example/contact.dart';
import '../entity/example/message.dart';
import '../layer/domain_layer.dart';

/// Domain Layer provider
final domainLayerProvider = Provider((ref) => DomainLayer(read: ref.read));

/// Function provider for dependency configuration (implementation injection)
final domainConfigurationProvider = Provider<DomainConfiguration>(
    (ref) => ref.watch(domainLayerProvider.select((layer) => layer.configure)));

/// System locales obtained on main()
final systemLocalesProvider = StateProvider<List<Locale>>((ref) => []);

/// Usecase provider
final contactsUsecaseProvider =
    Provider(((ref) => ref.watch(domainLayerProvider.select((layer) => layer.contactsUsecase))));

/// watchAllContacts StreamProvider
final watchAllContactsProvider =
    StreamProvider((ref) => ref.watch(contactsUsecaseProvider).watchAll());

/// watchContact StreamProvider
final watchContactProvider = StreamProvider.autoDispose
    .family<Contact, int>((ref, id) => ref.watch(contactsUsecaseProvider).watch(id));

/// MessageProvider for a contact
final messageProvider = FutureProvider.autoDispose.family<Message?, Contact>(
  (ref, contact) =>
      ref.watch(contactsUsecaseProvider.select((usecase) => usecase.getMessageFor(contact))),
);
