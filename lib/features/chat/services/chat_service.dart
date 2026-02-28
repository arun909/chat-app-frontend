import 'package:dio/dio.dart';
import '../../auth/data/models/user_model.dart';
import '../../auth/domain/entities/user_entity.dart';

class ChatService {
  final Dio _dio;
  static const String _baseUrl = 'http://192.168.31.240:5000/api';

  ChatService(this._dio);

  Future<List<UserEntity>> searchUsers(String query, {String? token}) async {
    try {
      print('Searching users with query: $query (Token: ${token != null})');
      final response = await _dio.get(
        '$_baseUrl/users/search',
        queryParameters: {'query': query},
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );
      
      print('Search response: ${response.data}');

      if (response.data['success'] == true) {
        dynamic data = response.data['data'];
        List<dynamic> usersData = [];
        
        if (data is List) {
          usersData = data;
        } else if (data is Map && data.containsKey('users')) {
          usersData = data['users'];
        } else if (data is Map && data.containsKey('user')) {
           // Handle case where it returns a single user (though search usually returns a list)
          usersData = [data['user']];
        }

        return usersData.map((userData) {
          // Robust mapping in case fields are named differently
          return UserEntity(
            id: userData['_id'] ?? userData['id'] ?? '',
            username: userData['username'] ?? userData['name'] ?? 'Unknown',
            email: userData['email'] ?? '',
            token: '',
          );
        }).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to search users');
      }
    } on DioException catch (e) {
      print('Search error: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      print('Search unexpected error: $e');
      throw Exception(e.toString());
    }
  }
}
