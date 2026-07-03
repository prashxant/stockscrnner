import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

class ApiClient {
  final Dio dio;
  final FirebaseAuth auth;

  ApiClient({required this.dio, required this.auth}) {
    dio.options.baseUrl =
        'http://localhost:3000/api'; // Replace with env config
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final user = auth.currentUser;
          if (user != null) {
            final token = await user.getIdToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          final requestOptions = error.requestOptions;
          final shouldRetry =
              error.response?.statusCode == 401 &&
              requestOptions.extra['authRetry'] != true;

          if (shouldRetry) {
            final user = auth.currentUser;
            if (user != null) {
              final refreshedToken = await user.getIdToken(true);
              requestOptions.headers['Authorization'] =
                  'Bearer $refreshedToken';
              requestOptions.extra['authRetry'] = true;
              return handler.resolve(await dio.fetch(requestOptions));
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return dio.post(path, data: data);
  }
}

final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return ApiClient(dio: dio, auth: auth);
});
