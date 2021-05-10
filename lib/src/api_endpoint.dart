import 'api_error.dart';

class ApiEndpoint {
  bool success = false;
  ApiError? error;
  dynamic result;

  ApiEndpoint(dynamic value) {
    if (value != null) {
      success = value['success'];
      result = value['result'];
      if (value['error'] != null) {
        error = ApiError(value['error']);
      }
    }
  }

  bool get hasData {
    return result != null;
  }

  bool get hasError {
    return error != null;
  }

  @override
  String toString() {
    return 'Instance of ApiEndpoint(result:$result, success:$success, error:$error)';
  }
}
