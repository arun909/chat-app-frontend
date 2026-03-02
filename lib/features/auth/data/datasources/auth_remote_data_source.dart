import 'dart:io';
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

  Future<UserModel> updateProfile({
    required String token,
    String? username,
    String? email,
    String? password,
    File? profilePicFile,
  }) async {
    try {
      final Map<String, dynamic> fields = {};
      if (username != null && username.isNotEmpty) {
        fields['username'] = username;
      }
      if (email != null && email.isNotEmpty) {
        fields['email'] = email;
      }
      if (password != null && password.isNotEmpty) {
        fields['password'] = password;
      }

      FormData formData;
      if (profilePicFile != null) {
        final fileName = profilePicFile.path.split('/').last;
        formData = FormData.fromMap({
          ...fields,
          'profilePic': await MultipartFile.fromFile(
            profilePicFile.path,
            filename: fileName,
          ),
        });
      } else {
        formData = FormData.fromMap(fields);
      }

      final response = await _dio.patch(
        '$_baseUrl/users/profile',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['success'] == true) {
        final userData = response.data['data'];
        return UserModel.fromJson({
          ...userData,
          'token': token, // keep the same token
        });
      } else {
        throw Exception(response.data['message'] ?? 'Update failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
