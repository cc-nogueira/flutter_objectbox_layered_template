import 'package:_domain_layer/domain_layer.dart';

import 'package:objectbox/internal.dart' show QueryIntegerProperty;
import 'package:objectbox/objectbox.dart' hide Entity;

import '../../objectbox.g.dart' show Box, ToMany, ToOne;
import '../mapper/entity_mapper.dart';
import '../model/model.dart';

/// Implements all EntityStreamRepository intergace.
///
/// Subclass must implement get idProperty, even without declaring the return
/// type (as it comes from Objectbox internal import), something like:
///   get idProperty => SubclassModel_.id;
///
/// The save method calls the [updataDependents] method, that should be redefined
/// in subclasses with no ToMany relations, where [updataDependetsToMany] may be
/// invoked.
abstract class ObjectboxRepository<E extends Entity, M extends Model>
    implements EntityStreamRepository<E> {
  /// Const constructor with a Box<M> and a Mapper<E,M>.
  const ObjectboxRepository({required this.box, required this.mapper});

  /// ObjectBox Box<M>
  final Box<M> box;

  /// Mapper for Entity / Model conversions.
  final EntityMapper<E, M> mapper;

  /// Id of my model
  QueryIntegerProperty<M> get idProperty;

  /// Returns the number of entities in the repository.
  ///
  /// May count only up to limit if adequate.
  /// Count all if limit is set to default value of zero.
  @override
  int count({int limit = 0}) => box.count(limit: limit);

  /// Returns an entity from storage by id.
  ///
  /// Throws [EntityNotFoundException] if none is found with id.
  @override
  E get(int id) {
    final model = box.get(id);
    if (model == null) {
      throw const EntityNotFoundException();
    }
    return mapper.mapEntity(model);
  }

  /// Returns all entities from storage.
  ///
  /// The returned list is in no specific order.
  @override
  List<E> getAll() => mapper.mapEntities(box.getAll());

  /// Returns a single entity stream by id.
  ///
  /// Throws [EntityNotFoundException] immediatly if no entity is found with id.
  /// Throws [EntityNotFoundException] through stream listener if that entity is
  /// removed while the stream is listenned.
  @override
  Stream<E> watch(int id) {
    if (!box.contains(id)) {
      throw const EntityNotFoundException();
    }

    return box.query(idProperty.equals(id)).watch(triggerImmediately: true).map<E>((q) {
      final model = q.findFirst();
      if (model == null) {
        throw const EntityNotFoundException();
      }
      return mapper.mapEntity(model);
    });
  }

  /// Returns all entities stream.
  ///
  /// Stream will be notified with all entities whenever the repository changes.
  @override
  Stream<List<E>> watchAll() =>
      box.query().watch(triggerImmediately: true).map<List<E>>((q) => mapper.mapEntities(q.find()));

  /// Removes a model from storage by id.
  ///
  /// Throws [EntityNotFoundException] if no model is found with id.
  @override
  void remove(int id) {
    if (!box.remove(id)) {
      throw const EntityNotFoundException();
    }
  }

  /// Saves an entity to repository.
  ///
  /// This is a add/update method.
  /// Entities with id == 0 (entity or dependents) will be added to storage.
  /// Entities with id != 0 (entity or dependents) will be updated in storage.
  ///
  /// Delegates updateDependents to subclasses that may use the provided
  /// [updateDependentsToMany] implementation.
  ///
  /// Throws [EntityNotFoundException] if a given id (entity or dependents) is not
  /// found in storage.
  @override
  E save(E entity) {
    final model = mapper.mapModel(entity);
    if (model.id > 0) {
      final boxModel = box.get(entity.id);
      if (boxModel == null) {
        throw const EntityNotFoundException();
      }
      updateDependents(toSaveModel: model, boxModel: boxModel);
    }

    try {
      box.put(model);
    } on ArgumentError catch (e) {
      throw EntityNotFoundException(e.message);
    }
    return mapper.mapEntity(model);
  }

  /// Save a list of entities in storage and return the corresponding saved list.
  ///
  /// For each entity:
  ///   - If the entity id is 0 it should generate the next id, add the new
  ///     entity to storage and return it.
  ///
  ///   - If the entity id is not 0 update an existint entry with that id.
  ///
  /// Throws an [EntityNotFoundException] if any entity to update is not found
  /// in storage. In this case there will be no updates.
  @override
  List<E> saveAll(List<E> entities) {
    final updatePairs = <MapEntry<M, M>>[];
    for (final entity in entities) {
      final model = mapper.mapModel(entity);
      if (model.id > 0) {
        final boxModel = box.get(entity.id);
        if (boxModel == null) {
          throw const EntityNotFoundException();
        }
        updatePairs.add(MapEntry(model, boxModel));
      }
    }
    for (final pair in updatePairs) {
      updateDependents(toSaveModel: pair.key, boxModel: pair.value);
    }

    final models = mapper.mapModels(entities);
    try {
      box.putMany(models);
    } on ArgumentError catch (e) {
      throw EntityNotFoundException(e.message);
    }
    return mapper.mapEntities(models);
  }

  /// Hook for subclasses to invoke [updateDependentsToMany] for each of its
  /// model [ToMany] relations, for example:
  ///
  ///   void updateDependents({required ContactModel toSaveModel, required ContactModel boxModel}) {
  ///     updateDependentsToMany<ContactPhoneModel>(
  ///       depBox: phonesBox,
  ///       toSaveList: toSaveModel.phones,
  ///       boxList: boxModel.phones,
  ///       removeMissing: true,
  ///     );
  ///   }
  void updateDependents({required M toSaveModel, required M boxModel}) {}

  void updateDependentToOne<T extends Model>({
    required Box<T> depBox,
    required ToOne<T> toSave,
    required ToOne<T> boxOne,
    required bool removeOnDereference,
  }) {
    final toSaveTarget = toSave.target;
    final boxOneTarget = boxOne.target;
    if (removeOnDereference && boxOneTarget != null) {
      if (toSaveTarget == null || toSaveTarget.id != boxOneTarget.id) {
        depBox.remove(boxOneTarget.id);
      }
    }
    if (toSaveTarget != null && boxOneTarget != null) {
      if (toSaveTarget.id == boxOneTarget.id) {
        depBox.put(toSaveTarget);
      }
    }
  }

  /// Update dependents in storage.
  ///
  /// Update changed elements that are not touched by parent box put() method.
  ///
  /// Any dependent not present in this entity list will be reomoved from storage
  /// if removeMissing flag is true (belongs-to relation).
  void updateDependentsToMany<T extends Model>({
    required Box<T> depBox,
    required ToMany<T> toSaveList,
    required ToMany<T> boxList,
    required bool removeMissing,
  }) {
    final toSaveMap = _mapById(toSaveList);
    final removedOnes = <T>[];
    final updatedOnes = <T>[];
    for (final each in boxList) {
      final toSave = toSaveMap[each.id];
      if (toSave == null) {
        removedOnes.add(each);
      } else {
        if (each != toSave) {
          updatedOnes.add(toSave);
        }
      }
    }

    // Update ToMany relation
    for (final each in removedOnes) {
      boxList.remove(each);
    }
    boxList.applyToDb();

    // Remove phones from storage
    if (removeMissing) {
      final removedIds = removedOnes.map((e) => e.id).toList();
      depBox.removeMany(removedIds);
    }

    // Update changed phones
    depBox.putMany(updatedOnes);

    // Don't remove this!!! Leave as a comment!
    // It was necessary on a previous ObjectBox implementation.
    // But it looks like it is not needed anymore...
    //
    // Just read the length to fix some cache error found in tests!!!
    // Maybe fetches some lazy loading collection...
    //
    // if (toSaveList.isEmpty) {}
  }

  Map<int, T> _mapById<T extends Model>(List<T> models) {
    final map = <int, T>{};
    for (final model in models) {
      map[model.id] = model;
    }
    return map;
  }
}
