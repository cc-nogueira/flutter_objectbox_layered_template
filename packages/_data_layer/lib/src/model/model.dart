/// Abstract persistence model super class.
///
/// Defines just the required ObjectBox persistence key.
abstract class Model {
  /// Constructor defaults id to zero (not persisted model).
  Model({this.id = 0});

  /// ObjectBox key field.
  /// This field should be zero for new models (not persisted), and should never be numbered by
  /// the application. It is sole ObjectBox responsibilitiy to define objects ids.
  int id;
}
