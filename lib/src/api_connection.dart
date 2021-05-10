import 'package:graphql/client.dart';

import 'api_error.dart';
import 'api_response.dart';

class ApiConnection {
  late GraphQLClient _graphQLClient;

  ApiConnection(String token, String serverUri) {
    final httpLink = HttpLink(serverUri);
    final authLink = AuthLink(
      getToken: () async => 'Bearer $token',
    );

    _graphQLClient = GraphQLClient(
      cache: GraphQLCache(),
      link: authLink.concat(httpLink),
    );
  }

  Future<ApiResponse?> query(String params, dynamic variable) async {
    ApiResponse? apiResponse;
    final options = QueryOptions(document: gql(params), variables: variable);
    final queryResult = await _graphQLClient.query(options);

    // Verifica se o resultado é do tipo QueryResult
    // Verifica se foi retornado uma exception
    if (queryResult is QueryResult && queryResult.hasException) {
      if (queryResult.exception != null && queryResult.exception!.graphqlErrors.isNotEmpty) {
        apiResponse = ApiResponse(success: false, errors: queryResult.exception!.graphqlErrors);
      } else {
        apiResponse = ApiResponse(
          success: false,
          errors: [
            ApiError.register(
              endpoint: 'ApiConnection.query()',
              message: 'Servidor de API não foi localizado',
              module: 'api_connection',
              service: 'ApiConnection',
              type: 'application.api_error',
              variable: variable,
            )
          ],
        );
      }
    } else if (queryResult is QueryResult) {
      apiResponse = ApiResponse(success: true, data: queryResult.data);
    } else {
      apiResponse = ApiResponse(
        success: false,
        errors: [
          ApiError.register(
            endpoint: 'ApiConnection.query()',
            message: 'Falha na conexão com servidor API',
            module: 'api_connection',
            service: 'ApiConnection',
            type: 'api_error',
            variable: variable,
          )
        ],
      );
    }
    return apiResponse;
  }

  Future<ApiResponse?> mutation(String params, dynamic variable) async {
    ApiResponse? apiResponse;
    final options = MutationOptions(document: gql(params), variables: variable);
    final queryResult = (await _graphQLClient.mutate(options));

    // Verifica se o resultado é do tipo QueryResult
    // Verifica se foi retornado uma exception
    if (queryResult is QueryResult && queryResult.hasException) {
      if (queryResult.exception != null && queryResult.exception!.graphqlErrors.isNotEmpty) {
        apiResponse = ApiResponse(success: false, errors: queryResult.exception!.graphqlErrors);
      } else {
        apiResponse = ApiResponse(
          success: false,
          errors: [
            ApiError.register(
              endpoint: 'ApiConnection.mutation()',
              message: 'Falha na conexão com servidor API',
              module: 'api_connection',
              service: 'ApiConnection',
              type: 'application.api_error',
              variable: variable,
            )
          ],
        );
      }
    } else if (queryResult is QueryResult) {
      apiResponse = ApiResponse(success: true, data: queryResult.data);
    } else {
      apiResponse = ApiResponse(
        success: false,
        errors: [
          ApiError.register(
            endpoint: 'ApiConnection.mutation()',
            message: 'Falha na conexão com servidor API',
            module: 'api_connection',
            service: 'ApiConnection',
            type: 'api_error',
            variable: variable,
          )
        ],
      );
    }
    return apiResponse;
  }
}
