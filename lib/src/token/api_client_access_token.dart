import 'package:jose/jose.dart';

import '../api_client.dart';
import '../api_connection.dart';
import '../token/api_client_authorize_token.dart';

class ApiClientAccessToken {
  final ApiClientAuthorizeToken apiClientAuthorize;
  late String clientId;
  late String tokenType;
  late String expiresIn;
  late String? accessToken;
  late String refreshToken;

  ApiClientAccessToken(this.apiClientAuthorize) {
    clientId = apiClientAuthorize.clientId!;
  }

  ///Verifica se existe um token de acesso de cliente registrado na sessão local da aplicação
  ///Verifica se o token tem identificação do distribuidor e se o subject é do tipo access_token
  static Future<bool> get isValid async {
    final accessToken = await ApiClient.getAccessToken;
    var isValid = false;
    if (accessToken != null) {
      try {
        final jwt = JsonWebToken.unverified(accessToken);
        if (jwt.claims['iss'] != null && jwt.claims['sub'] == 'access_token') {
          isValid = true;
        }
      } catch (e) {
        print('════════ Exception caught by ApiClientAccessToken.isValid ════════');
        throw ("Token de acesso da aplicação 'client' inválido.");
      }
    }
    return isValid;
  }

  static Future<bool> get ready async {
    final accessToken = await ApiClient.getAccessToken;
    var isReady = false;
    if (accessToken != null) {
      try {
        final jwt = JsonWebToken.unverified(accessToken);
        if (jwt.claims['iss'] != null && jwt.claims['sub'] == 'access_token') {
          isReady = true;
        }
      } catch (e) {
        print('════════ Exception caught by ApiClientAccessToken.ready ════════');
        throw ("Token de acesso da aplicação 'client' inválido.");
      }
    }
    return isReady;
  }

  Future<String?> token() async {
    final apiConnection = ApiConnection(apiClientAuthorize.nonceToken!, apiClientAuthorize.apiUri!);

    final params = r'''
      mutation token($clientId: String!, $clientSecret: String!, $code: String!, $codeVerifier: String!, $grantType: GrantTypeEnum!) {
        token(clientId: $clientId, clientSecret: $clientSecret, code: $code, codeVerifier: $codeVerifier, grantType: $grantType) {
          success
          result {
            tokenType
            expiresIn
            accessToken
            refreshToken
          }
        }
      }
      ''';
    dynamic variable = {
      'clientId': apiClientAuthorize.clientId,
      'clientSecret': apiClientAuthorize.clientSecret,
      'code': apiClientAuthorize.code,
      'codeVerifier': apiClientAuthorize.codeVerifier64,
      'grantType': 'authorization_code'
    };

    final apiResponse = await apiConnection.mutation(params, variable);

    if (apiResponse!.success) {
      final token = apiResponse.endpoint('token');
      if (token.success && token.hasData) {
        tokenType = token.result['tokenType'];
        expiresIn = token.result['expiresIn'];
        accessToken = token.result['accessToken'];
        refreshToken = token.result['refreshToken'];

        final apiStorage = await ApiClient.storage;
        if (apiStorage != null) {
          await apiStorage.add('accessToken', accessToken!);
          await apiStorage.add('refreshToken', refreshToken);
        }
      }
    } else if (apiResponse.hasError) {
      print('════════ Exception caught by ApiClientAccessToken.token ════════');
      if (apiResponse.error!.endpoint == 'tokenGuest') {
        throw ("Perfil de usuário 'guest' não foi localizado.");
      } else {
        print(apiResponse.error);
      }
    }

    return accessToken;
  }
}
