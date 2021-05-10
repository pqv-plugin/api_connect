import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';

import 'api_error.dart';
import 'api_mutation.dart';
import 'api_query.dart';
import 'api_response.dart';
import 'loading.dart';
import 'message.dart';
import 'token/api_client_access_token.dart';
import 'token/api_client_authorize_token.dart';
import 'token/api_user_access_token.dart';
import 'token/api_user_authorize_token.dart';

enum ApiMode { create, find, edit, delete }

class ApiConnect {
  static final ApiConnect _instance = ApiConnect._internalConstructor();

  //ApiUser apiUser;
  //ApiStorage apiStorage;
  late ApiClientAccessToken apiClientAccessToken;
  late ApiClientAuthorizeToken apiClientAuthorize;

  factory ApiConnect([String? authToken]) {
    if (authToken != null) {
      _instance._init(authToken);
    }
    return _instance;
  }

  ApiConnect._internalConstructor();

  void _init(String authToken) async {
    print('11111111111111111111111111111111111111111111111111');
    apiClientAuthorize = ApiClientAuthorizeToken(authToken);
    print('apiClientAuthorize================>>');
    print(apiClientAuthorize);
    print('22222222222222222222222222222222222222222222222');
    print(await apiClientAuthorize.isValid);
    print('3333333355555555555555555555555');
    if (await apiClientAuthorize.isValid) {
      print('33333333333333333333333333333333333333333333');
      final isAuthorized = await apiClientAuthorize.authorize();
      print('4444444444444444444444444444444444444444444444');
      if (isAuthorized) {
        apiClientAccessToken = ApiClientAccessToken(apiClientAuthorize);
        final accessToken = await apiClientAccessToken.token();
        if (accessToken != null) {
          final apiUserAuthorizeToken = ApiUserAuthorizeToken(accessToken);

          if (await apiUserAuthorizeToken.isValid) {
            final isAuthorizeValid = await apiUserAuthorizeToken.authorize();
            if (isAuthorizeValid) {
              var apiUserAccessToken = ApiUserAccessToken(apiUserAuthorizeToken);
              final isTokenValid = await apiUserAccessToken.token();
              if (!isTokenValid) {
                print('════════ Exception caught by ApiConnect.init (1)════════');
                print('!isTokenValid');
                throw ("Token de autorização da usuário 'user' inválido.");
              }
            } else {
              print('════════ Exception caught by ApiConnect.init (2)════════');
              print('isAuthorizeValid');
              throw ("Token de autorização da usuário 'user' inválido.");
            }
          } else {
            print('════════ Exception caught by ApiConnect.init (3)════════');
            print('apiUserAuthorizeToken.isValid');
            throw ("Token de autorização da usuário 'user' inválido.");
          }
        } else {
          print('════════ Exception caught by ApiConnect.init (4)════════');
          print('accessToken != null');
          throw ("Token de autorização da aplicação 'client' inválido.");
        }
      }
    } else {
      print('════════ Exception caught by ApiConnect.init (5)════════');
      print('apiClientAuthorize.isValid');
      throw ('Token de autorização da aplicação \'client\' inválido.');
    }
  }

  Future<ApiResponse> exec({dynamic apiGraphql}) async {
    final hasConnectivity = await checkInternetConnection();
    var apiResponse = ApiResponse();
    try {
      if (hasConnectivity) {
        apiResponse = await apiGraphql();
      } else {
        apiResponse = ApiResponse(
          errors: [
            ApiError.register(
              endpoint: 'exec',
              message: 'Sem conexão com a Internet',
              module: 'api_connect',
              service: 'ApiConnect',
              type: 'connect_error',
            ),
          ],
        );
      }
    } catch (e) {
      print(e);
    }
    return apiResponse;
  }

  Future<bool> checkInternetConnection() async {
    var hasConnectivity = false;
    // Verifica se é serviço web
    if (kIsWeb) {
      hasConnectivity = true;
    } else {
      final connectivityResult = await (Connectivity().checkConnectivity());
      // Verifica se tem conexão mobile ou wifi
      if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
        hasConnectivity = true;
      }
    }
    return hasConnectivity;
  }

  static Future<ApiResponse> dao({
    ApiQuery? query,
    ApiMutation? mutation,
    ValueChanged<Loading>? loading,
    Message? message,
  }) async {
    ApiResponse apiResponse;
    ApiConnect.loadingStart(loading, message);
    if (query != null) {
      apiResponse = await query.exec();
    } else if (mutation != null) {
      apiResponse = await mutation.exec();
    } else {
      print('════════ Exception caught by ApiConnect.dao ════════');
      throw ('Necessário fornecer um modelo de conexão, \'query\' ou \'mutation\'.');
    }
    ApiConnect.loadingEnd(apiResponse, loading, message);
    return apiResponse;
  }

  /// Prepara a mensagem que deve ser apresentada para o usuário durante a conexão
  static void loadingStart(ValueChanged<Loading>? loading, Message? message) {
    if (loading != null) {
      message ??= Message();
      loading(Loading(message: message.progress, isConnect: true));
    }
  }

  /// Prepara a mensagem que deve ser apresentada para o usuário no encerramento da conexão
  static void loadingEnd(ApiResponse apiResponse, ValueChanged<Loading>? loading, Message? message) {
    if (loading != null) {
      message ??= Message();
      if (apiResponse.success) {
        loading(Loading(message: message.success, isConnect: false));
      } else {
        loading(Loading(message: message.error, isConnect: false));
      }
    }
  }
}
