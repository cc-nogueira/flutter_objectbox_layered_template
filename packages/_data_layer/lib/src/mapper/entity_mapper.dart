import 'package:_domain_layer/domain_layer.dart';

import '../model/model.dart';

abstract class EntityMapper<E extends Entity, M extends Model> {
  const EntityMapper();

  E mapEntity(M model);
  M mapModel(E entity);

  List<E> mapEntities(Iterable<M> models) =>
      List.unmodifiable(models.map((model) => mapEntity(model)));

  List<M> mapModels(Iterable<E> entities) =>
      List.unmodifiable(entities.map((e) => mapModel(e)));
}
