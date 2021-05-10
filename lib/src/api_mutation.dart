import 'api_connect.dart';
import 'api_connection.dart';
import 'api_error.dart';
import 'api_response.dart';
import 'api_user.dart';

class ApiMutation {
  final String params;
  final dynamic variable;

  ApiConnect apiConnect = ApiConnect();

  ApiMutation({required this.params, this.variable});

  Future<ApiResponse> exec() async {
    //Conecta o servidor e realiza consulta
    ApiResponse? apiResponse = await apiConnect.exec(
      apiGraphql: () async {
        return await _mutation(params, variable);
      },
    );
    return apiResponse;
  }

  Future<ApiResponse?> _mutation(String params, dynamic variable) async {
    final accessToken = await ApiUser.getAccessToken;
    final serverUri = await ApiUser.getServerUri;

    if (accessToken != null && serverUri != null) {
      final apiConnection = ApiConnection(accessToken, serverUri);
      return apiConnection.mutation(params, variable);
    }

    return ApiResponse(
      success: false,
      errors: [
        ApiError.register(
          endpoint: 'ApiMutation.exec()',
          message: 'Falha na conexão com servidor API',
          module: 'api_mutation',
          service: 'ApiMutation',
          type: 'mutation',
          variable: variable,
        ),
      ],
    );
  }
}
