import 'dart:convert';

import 'package:graphql/client.dart';

import 'api_connect.dart';
import 'api_endpoint.dart';
import 'api_error.dart';

class ApiResponse {
  final bool success;
  final List<GraphQLError>? errors;
  final dynamic data;

  final Map<String, dynamic> _errors = {};
  ApiMode mode = ApiMode.create;

  ApiResponse({
    this.success = false,
    this.errors,
    this.data,
  }) {
    if (errors != null) {
      errors!.forEach((GraphQLError item) {
        if (item.message.isNotEmpty) {
          final regex = RegExp(r'^{[\s\S]*}', multiLine: false, caseSensitive: false);
          final itemRegex = regex.allMatches(item.message).map((m) => m.group(0));
          if (itemRegex.isNotEmpty) {
            dynamic itemJson = jsonDecode(itemRegex.first!);
            _errors[(itemJson['endpoint'])] = itemJson;
            print(itemJson);
          } else {
            if (item.message.isNotEmpty) {
              _errors['queryField'] = {
                'createdAt': DateTime.now().toIso8601String(),
                'endpoint': 'ApiResponse',
                'message': item.message,
                'module': 'api_response',
                'service': 'ApiResponse',
                'type': 'cannot_query_field',
              };
            } else {
              print('════════ Error: Erro de api não tratado! ════════');
              print(item.message);
            }
          }
        }
      });
    }
  }

  dynamic result(String endpoint) {
    if (data != null) {
      dynamic response = data[endpoint];
      if (response != null) {
        return data[endpoint]['result'];
      }
    }
  }

  dynamic pageInfo(String endpoint) {
    if (data != null) {
      dynamic response = data[endpoint];
      if (response != null) {
        return data[endpoint]['pageInfo'];
      }
    }
  }

  ApiEndpoint endpoint(String name) {
    dynamic endpoint = data[name];
    if (endpoint != null) {
      return ApiEndpoint(endpoint);
    }
    return ApiEndpoint(null);
  }

  ApiError? get error {
    ApiError? apiError;
    if (_errors.isNotEmpty) {
      dynamic keys = _errors.keys;
      dynamic value = _errors[keys.first];
      apiError = ApiError(value);
    }
    return apiError;
  }

  bool get hasError {
    return _errors.isNotEmpty;
  }

  ApiError endpointError(String name) {
    return _errors[name];
  }

  @override
  String toString() {
    return 'Instance of ApiResponse(data:$data, success:$success, errors:$errors)';
  }
}
