import 'package:flutter_dotenv/flutter_dotenv.dart';

class Api {
  static final String midtransServerKey =
      dotenv.env['MIDTRANS_SERVER_KEY'] ?? 'KUNCI_TIDAK_DITEMUKAN';
  static final String keyWeather =
      dotenv.env['KEY_WEATHER'] ?? 'KUNCI_TIDAK_DITEMUKAN';
}
