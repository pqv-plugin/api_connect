import 'dart:convert';

import 'package:graphql/client.dart';

class ApiError {
  late String createdAt;
  late String? endpoint;
  late String message;
  late String module;
  late String service;
  late String type;
  dynamic variable;

  ApiError(dynamic value) {
    {
      createdAt = value['createdAt'];
      endpoint = value['endpoint'];
      message = value['message'];
      module = value['module'];
      service = value['service'];
      type = value['type'];
      variable = value['variable'];
    }
  }

  static GraphQLError register({
    required String endpoint,
    required String message,
    required String module,
    required String service,
    required String type,
    dynamic variable,
  }) {
    dynamic error = {
      'createdAt': DateTime.now().toIso8601String(),
      'endpoint': endpoint,
      'message': message,
      'module': module,
      'service': service,
      'type': type,
      'variable': variable
    };

    return GraphQLError(message: '${jsonEncode(error)} : Undefined location');
  }

  @override
  String toString() {
    return 'Instance of ApiError(createdAt:$createdAt, endpoint:$endpoint, message:$message, module:$module, service:$service, type:$type, variable:$variable)';
  }
}
