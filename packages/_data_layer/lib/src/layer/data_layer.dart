import 'dart:io';

import 'package:_core_layer/core_layer.dart';
import 'package:_domain_layer/domain_layer.dart';

import 'package:path_provider/path_provider.dart';

import '../../objectbox.g.dart';
import '../model/example/contact_model.dart';
import '../repository/example/objectbox_contacts_repository.dart';

/// DataLayer has the responsibility to provide repository implementaions.
///
/// Provides all repository implementations, also accessible through providers.
class DataLayer extends AppLayer {
  DataLayer();

  late final Store _store;

  ContactsRepository get contactsRepository =>
      ObjectboxContactsRepository(box: _store.box<ContactModel>());

  @override
  Future<void> init() async {
    _store = await _openStore();
    _initDataWhenEmpty();
  }

  @override
  void dispose() => _store.close();

  Future<Store> _openStore() async {
    final appDir = await getApplicationDocumentsDirectory();
    final objectboxPath =
        _isMobile ? '${appDir.path}/objectbox' : '${appDir.path}/objectbox/project_name';
    if (Store.isOpen(objectboxPath)) {
      return Store.attach(getObjectBoxModel(), objectboxPath);
    } else {
      return Store(getObjectBoxModel(), directory: objectboxPath);
    }
  }

  bool get _isMobile => Platform.isAndroid || Platform.isIOS;

  void _initDataWhenEmpty() {
    final box = _store.box<ContactModel>();
    if (box.isEmpty()) {
      box.putMany([
        ContactModel(name: 'Trygve Reenskaug', uuid: '082a4b92-dbed-4b34-8a76-77100beace88'),
        ContactModel(name: 'Gilad Bracha', uuid: 'd12acf0d-ccbc-482b-8b19-d4e7185ac653'),
        ContactModel(name: 'Robert C. Martin', uuid: '36e3073d-7acb-4f41-96e6-ba25108332d2'),
        ContactModel(name: 'Martin Fowler', uuid: 'bfb17eb8-4274-4aff-8d7c-d7caa709efa7'),
        ContactModel(name: 'Ricardo Nogueira', uuid: '05cd0e2a-a344-4fae-a960-8624a7db8be0'),
      ]);
    }
  }
}
