import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String rapidApiKey = dotenv.env['RAPIDAPI_KEY'] ?? '';
}
