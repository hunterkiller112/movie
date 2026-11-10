import 'package:dio/dio.dart';

class ApiService {
  static Dio dio = Dio(BaseOptions(baseUrl: 'https://yts.gg/api/v2/'));
}
