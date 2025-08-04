import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracking_app/model/customer.dart';
import 'package:tracking_app/model/user.dart';

import 'auth_service.dart';

class APIService {
  static const String baseUrl = 'http://192.168.1.3:8000/api';
  final Dio dio;
  late String message;

  APIService()
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) {
          final code = e.response?.statusCode;
          if (code == 400) {
            message = "Gagal Memasukan Data";
          } else if (code == 500) {
            message = "Gagal Menyimpan data";
          } else if (e.type == DioExceptionType.connectionTimeout) {
            message =
                "Tidak ada respon dari server, Timeout Lebih dari 15 detik. server kemungkinan tidak aktif";
          } else {
            message = e.message ?? "Terjadi Kesalahan yang tidak Diketahui";
          }
          return handler.next(e);
        },
      ),
    );
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  Future<User?> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );
      final body = response.data;

      if (body['status'] == true) {
        final data = body['user'];
        final token = body['token'];

        return User(
          id: data['id'],
          email: data['email'],
          username: data['name'],
          password: '',
          token: token,
          fotoUrl: null,
        );
      } else {
        print('Login gagal: ${body['message']}');
      }
    } on DioException catch (e) {
      print('Login error: ${e.response?.data ?? e.message}');
    }

    return null;
  }

  Future<String?> getFotoProfil(int userId) async {
    try {
      final response = await dio.get('/user/$userId/foto');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['foto_url'];
      }
    } on DioException catch (e) {
      print('Gagal ambil foto: ${e.response?.data ?? e.message}');
    }
    return null;
  }

  Future<void> logoutFromBackend() async {
    final token = await AuthService.getToken();
    try {
      final response = await dio.post(
        '/logout',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('Logout API status: ${response.statusCode}');
    } on DioException catch (e) {
      print('Logout error: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<Customer>> getCustomerByUser(int userId) async {
    try {
      final response = await dio.get('/user/$userId/customers');

      if (response.statusCode == 200 && response.data['status'] == true) {
        List data = response.data['data'];
        return data.map((json) => Customer.fromJson(json)).toList();
      } else {
        throw Exception("Gagal memuat data");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<Map<String, dynamic>> updateStatus(int id, int status) async {
    try {
      final response = await dio.put(
        '/customers/$id/status',
        data: {'status': status},
      );

      return response.data;
    } catch (e) {
      print("Error saat update status: $e");
      return {'success': false, 'message': 'Terjadi kesalahan'};
    }
  }
}
