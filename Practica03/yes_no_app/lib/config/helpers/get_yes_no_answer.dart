import 'dart:math';

import 'package:dio/dio.dart';
import 'package:yes_no_app/domain/entities/message.dart';
import 'package:yes_no_app/infrastructure/models/yes_no_model.dart';

class GetYesNoAnswer {
  static const _answers = ['yes', 'yes', 'no', 'no', 'maybe'];

  final _random = Random();
  final _dio = Dio();

  static const _yesImages = [
    'src/yes1.webp',
    'src/yes2.webp',
    'src/yes3.webp',
  ];

  static const _noImages = [
    'src/no1.webp',
    'src/no2.webp',
    'src/no3.webp',
  ];

  static const _maybeImages = [
    'src/may1.webp',
    'src/may2.webp',
    'src/may3.webp',
  ];

  Future<Message> getAnswer() async {
    final answer = _answers[_random.nextInt(_answers.length)];
    final response = await _dio.get(
      'https://yesno.wtf/api',
      queryParameters: {'force': answer},
    );
    
    final yesNoModel = YesNoModel.fromJsonMap(response.data);
    final originalMessage = yesNoModel.toMessageEntity();

    String randomLocalImage = '';
    if (originalMessage.text == 'Sí') {
      randomLocalImage = _yesImages[_random.nextInt(_yesImages.length)];
    } else if (originalMessage.text == 'No') {
      randomLocalImage = _noImages[_random.nextInt(_noImages.length)];
    } else {
      randomLocalImage = _maybeImages[_random.nextInt(_maybeImages.length)];
    }

    return Message(
      text: originalMessage.text,
      fromwho: originalMessage.fromwho,
      imageUrl: randomLocalImage,
    );
  }
}