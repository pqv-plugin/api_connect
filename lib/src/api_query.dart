import 'api_connect.dart';
import 'api_connection.dart';
import 'api_error.dart';
import 'api_response.dart';
import 'api_user.dart';

class ApiQuery {
  final String params;
  final dynamic variable;
  ApiConnect apiConnect = ApiConnect();

  ApiQuery({required this.params, this.variable});

  Future<ApiResponse> exec() async {
    //Conecta o servidor e realiza consulta
    ApiResponse? apiResponse = await apiConnect.exec(
      apiGraphql: () async {
        return await _query(params, variable);
      },
    );

    return apiResponse;
  }

  Future<ApiResponse?> _query(String params, dynamic variable) async {
    final accessToken = await ApiUser.getAccessToken;
    final serverUri = await ApiUser.getServerUri;

    if (accessToken != null && serverUri != null) {
      final apiConnection = ApiConnection(accessToken, serverUri);
      return apiConnection.query(params, variable);
    }

    return ApiResponse(
      success: false,
      errors: [
        ApiError.register(
          endpoint: 'ApiQuery.exec()',
          message: 'Falha na conexão com servidor API',
          module: 'api_query',
          service: 'ApiQuery',
          type: 'query',
          variable: variable,
        ),
      ],
    );
  }
}
