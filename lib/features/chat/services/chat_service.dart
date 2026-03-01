import 'package:dio/dio.dart';
import '../../auth/domain/entities/user_entity.dart';
import '../models/message_model.dart';

class ChatService {
  final Dio _dio;
  static const String _baseUrl = 'http://192.168.31.240:5000/api';

  ChatService(this._dio);

  // ─── Users ────────────────────────────────────────────────────────────────

  Future<List<UserEntity>> searchUsers(String query, {String? token}) async {
    try {
      print('Searching users with query: $query');
      final response = await _dio.get(
        '$_baseUrl/users/search',
        queryParameters: {'query': query},
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );

      print('Search response: ${response.data}');

      final dynamic responseData = response.data;
      List<dynamic> usersData = [];

      if (responseData is List) {
        usersData = responseData;
      } else if (responseData is Map) {
        final data = responseData['data'];
        if (data is List) {
          usersData = data;
        } else if (responseData['users'] is List) {
          usersData = responseData['users'];
        }
      }

      return usersData.map((u) {
        return UserEntity(
          id: u['_id']?.toString() ?? u['id']?.toString() ?? '',
          username: u['username']?.toString() ?? u['name']?.toString() ?? 'Unknown',
          email: u['email']?.toString() ?? '',
          token: '',
        );
      }).toList();
    } on DioException catch (e) {
      final errData = e.response?.data;
      final msg = errData is Map ? errData['message']?.toString() : null;
      throw Exception(msg ?? 'Network error');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ─── Conversations ─────────────────────────────────────────────────────────

  /// Creates or fetches an existing conversation with [otherUserId].
  /// Returns the conversation ID string.
  Future<String> getOrCreateConversation(String otherUserId, {String? token}) async {
    try {
      print('Creating/fetching conversation with: $otherUserId');
      final response = await _dio.post(
        '$_baseUrl/conversations',
        data: {'otherUserId': otherUserId},
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );

      print('Conversation response: ${response.data}');

      final dynamic responseData = response.data;
      dynamic conversationObj;

      if (responseData is Map) {
        conversationObj = responseData['data'] ?? responseData;
      } else {
        conversationObj = responseData;
      }

      final id = conversationObj['_id']?.toString() ?? conversationObj['id']?.toString();
      if (id == null || id.isEmpty) {
        throw Exception('Could not determine conversation ID from response: $responseData');
      }
      return id;
    } on DioException catch (e) {
      final errData = e.response?.data;
      final msg = errData is Map ? errData['message']?.toString() : null;
      throw Exception(msg ?? 'Network error');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ─── Messages ─────────────────────────────────────────────────────────────

  Future<List<MessageModel>> getMessages(String conversationId, {String? token}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/messages/$conversationId',
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );

      print('Get messages response: ${response.data}');

      final dynamic responseData = response.data;
      List<dynamic> messagesData = [];

      if (responseData is List) {
        messagesData = responseData;
      } else if (responseData is Map) {
        final data = responseData['data'];
        if (data is List) {
          messagesData = data;
        } else if (responseData['messages'] is List) {
          messagesData = responseData['messages'];
        }
      }

      return messagesData
          .map((m) => MessageModel.fromJson(Map<String, dynamic>.from(m as Map)))
          .toList();
    } on DioException catch (e) {
      final errData = e.response?.data;
      final msg = errData is Map ? errData['message']?.toString() : null;
      throw Exception(msg ?? 'Network error');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Sends a message to [conversationId] with [text].
  Future<MessageModel> sendMessage(String conversationId, String text, {String? token}) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/messages',
        data: {
          'conversationId': conversationId,
          'text': text,
        },
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );

      print('Send message response type: ${response.data.runtimeType}');
      print('Send message response: ${response.data}');

      final dynamic responseData = response.data;
      Map<String, dynamic>? messageData;

      if (responseData is List && responseData.isNotEmpty) {
        messageData = Map<String, dynamic>.from(responseData.first as Map);
      } else if (responseData is Map) {
        final resMap = Map<String, dynamic>.from(responseData);
        if (resMap['data'] is Map) {
          messageData = Map<String, dynamic>.from(resMap['data'] as Map);
        } else if (resMap.containsKey('_id') || resMap.containsKey('text')) {
          messageData = resMap;
        } else {
          for (final value in resMap.values) {
            if (value is Map && (value.containsKey('_id') || value.containsKey('text'))) {
              messageData = Map<String, dynamic>.from(value);
              break;
            }
          }
        }
      }

      if (messageData != null) {
        return MessageModel.fromJson(messageData);
      }
      throw Exception('Unexpected response format: $responseData');
    } on DioException catch (e) {
      final errData = e.response?.data;
      String msg = 'Network error';
      if (errData is Map) {
        msg = errData['message']?.toString() ?? errData['error']?.toString() ?? msg;
      } else if (errData is String) {
        msg = errData;
      }
      throw Exception(msg);
    } catch (e) {
      print('sendMessage error: $e');
      throw Exception(e.toString());
    }
  }
}
