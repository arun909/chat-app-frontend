import 'package:dio/dio.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final Dio _dio;
  static const String _baseUrl = 'http://192.168.31.240:5000/api';

  AuthRemoteDataSource(this._dio);

  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      if (response.data['success'] == true) {
        final userData = response.data['data']['user'];
        final token = response.data['data']['token'];
        
        return UserModel.fromJson({
          ...userData,
          'token': token,
        });
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<UserModel> login({
  required String email,
  required String password,
}) async {
  try {
    final response = await _dio.post(
      '$_baseUrl/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    if (response.data['success'] == true) {
      final userData = response.data['data']['user'];
      final token = response.data['data']['token'];
      
      return UserModel.fromJson({
        ...userData,
        'token': token,
      });
    } else {
      throw Exception(response.data['message'] ?? 'Login failed');
    }
  } on DioException catch (e) {
    throw Exception(e.response?.data['message'] ?? 'Network error');
  }
}
}
