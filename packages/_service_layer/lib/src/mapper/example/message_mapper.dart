import 'package:_domain_layer/domain_layer.dart';

import 'package:riverpod/riverpod.dart';

import '../../model/example/message_model.dart';

class MessageMapper {
  MessageMapper(Reader reader) : personMapper = PersonMapper(reader);

  final PersonMapper personMapper;

  Message mapEntity(MessageModel model, {Contact? receiver}) => Message(
        sender: personMapper.mapEntity(model.sender),
        receiver: personMapper.mapEntity(
          model.receiver,
          possibleMatch: receiver,
        ),
        title: model.message.title,
        text: model.message.text,
      );
}

class PersonMapper {
  const PersonMapper(this.reader);

  final Reader reader;

  Contact mapEntity(PersonModel model, {Contact? possibleMatch}) {
    if (model.uuid == possibleMatch?.uuid) {
      return possibleMatch!;
    }
    return reader(contactsUsecaseProvider).getByUuid(
      model.uuid,
      orElse: () => Contact(uuid: model.uuid, name: model.name),
    );
  }
}