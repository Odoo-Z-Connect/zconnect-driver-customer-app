import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio dio;

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: 'http://127.0.0.1:8070/api/v1/zconnect',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final sessionId = prefs.getString('session_id');
        if (sessionId != null && sessionId.isNotEmpty) {
          options.headers['Cookie'] = 'session_id=$sessionId';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) async {
        try {
          final setCookieHeaders = response.headers['set-cookie'];
          if (setCookieHeaders != null && setCookieHeaders.isNotEmpty) {
            for (final header in setCookieHeaders) {
              if (header.contains('session_id=')) {
                final match = RegExp(r'session_id=([^;]+)').firstMatch(header);
                if (match != null) {
                  final newSid = match.group(1);
                  if (newSid != null && newSid.isNotEmpty) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('session_id', newSid);
                  }
                }
              }
            }
          }
        } catch (_) {}
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        return handler.next(e);
      },
    ));
  }
}
