import 'package:_core_layer/string_utils.dart';
import 'package:_domain_layer/domain_layer.dart';

import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/page/loading_page.dart';
import '../../../common/page/message_page.dart';
import '../../../l10n/translations.dart';
import '../../../routes/routes.dart';

/// Contacts page.
///
/// Display the list of contacts from [ContactsUsecase] and a floating button
/// to add pseudo random contacts (4 fixed contacts and fake contacts from there
/// on)
class ContactsPage extends ConsumerWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context)!;
    final usecase = ref.watch(contactsUsecaseProvider);
    return ref.watch(watchAllContactsProvider).when(
          loading: LoadingPage.builder(tr.title_contacts_page),
          error: ErrorMessagePage.errorBuilder,
          data: (data) => _ContactsPage(contacts: data, usecase: usecase),
        );
  }
}

class _ContactsPage extends StatelessWidget {
  _ContactsPage({required this.contacts, required this.usecase});

  final List<Contact> contacts;
  final ContactsUsecase usecase;
  final Faker _faker = Faker();

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(tr.title_contacts_page)),
      body: contacts.isEmpty ? _buildNoContactsMessage(context, tr) : _buildContactsList(context),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _newContact(),
      ),
    );
  }

  Widget _buildNoContactsMessage(BuildContext context, Translations tr) {
    final textStyle = Theme.of(context).textTheme.headline4;
    return Center(child: Text(tr.message_no_contacts, style: textStyle));
  }

  Widget _buildContactsList(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contact = contacts[index];
            return _ContactCard(
              contact: contact,
              onDelete: () => _removeContact(contact),
              onTap: () => _viewContact(context, contact),
            );
          },
        ),
      );

  void _removeContact(Contact contact) => usecase.remove(contact.id);

  void _viewContact(BuildContext context, Contact contact) =>
      Navigator.pushNamed(context, Routes.viewContact, arguments: contact.id);

  Contact _newContact() => usecase.save(_createContact());

  Contact _createContact() {
    return Contact(name: _faker.person.name(), uuid: _faker.guid.guid());
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.contact, required this.onDelete, required this.onTap});
  final Contact contact;
  final Function() onDelete;
  final Function() onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: CircleAvatar(child: Text(contact.name.cut(max: 2))),
          title: Text(contact.name),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
          onTap: onTap,
        ),
      );
}
