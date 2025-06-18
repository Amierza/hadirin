import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static String get apiKey => dotenv.env['API_KEY'] ?? "";
  static String get assetsKey => dotenv.env['ASSETS_KEY'] ?? "";
}
