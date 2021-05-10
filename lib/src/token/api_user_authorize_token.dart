import 'package:jose/jose.dart';

import '../api_connection.dart';
import '../api_security.dart';
import '../api_user.dart';

class ApiUserAuthorizeToken {
  final String token;
  late String apiUri;
  late String clientSecret;
  late String code;
  late String codeChallenge;
  late String codeVerifier;
  late String codeVerifier64;
  late String nonceToken;
  late String state;

  ApiUserAuthorizeToken(this.token) {
    codeVerifier = ApiSecurity.randomBytes(32);
    codeVerifier64 = ApiSecurity.base64URLEncode(codeVerifier);
    codeChallenge = ApiSecurity.base64URLEncode(ApiSecurity.encodeSha256(codeVerifier64));

    state = ApiSecurity.randomBytes(16);
  }

  Future<bool> get isValid async {
    var isValid = false;

    try {
      final jwt = JsonWebToken.unverified(token);
      if (jwt.claims['iss'] != null && jwt.claims['sub'] == 'access_token') {
        apiUri = jwt.claims['iss'];
        isValid = true;
      }
    } catch (e) {
      print('════════ Exception caught by ApiUserAuthorizeToken.isValid ════════');
      throw ("Token de autorização de usuário 'user' inválido.");
    }

    return isValid;
  }

  Future<bool> authorize() async {
    final clientId = ApiUser().clientId;
    try {
      final jwt = JsonWebToken.unverified(token);
      if (jwt.claims['iss'] != null) {
        apiUri = jwt.claims['iss'];
        clientSecret = ApiSecurity.encodeSha256((clientId) + (codeVerifier64));
      }
    } catch (e) {
      print('════════ Exception caught by ApiUserAuthorizeToken.authorize (future:token)════════');
      throw ("Token de inicialização 'Client token' inválido");
    }

    final apiConnection = ApiConnection(token, apiUri);

    final params = r'''
    mutation authorize($clientId: String!, $codeChallenge: String!, $responseType: ResponseTypeEnum!, $scope: String!, $state: String!) {
      authorize(clientId: $clientId, codeChallenge: $codeChallenge, responseType: $responseType, scope: $scope, state: $state) {
        success
        result {
          state
          code
          nonceToken
        }
      }
    }
    ''';

    final apiStorage = await ApiUser.storage;

    if (apiStorage != null) {
      await apiStorage.add('clientId', clientId);
    }

    dynamic variable = {
      'clientId': clientId,
      'codeChallenge': codeChallenge,
      'responseType': 'code',
      'scope': 'mut:authorize',
      'state': state
    };

    final apiResponse = await apiConnection.mutation(params, variable);

    if (apiResponse!.success) {
      final authorize = apiResponse.endpoint('authorize');
      if (authorize.hasData) {
        if (authorize.result['state'] == state) {
          code = authorize.result['code'];
          nonceToken = authorize.result['nonceToken'];
          return true;
        }
      }
    } else {
      print('════════ Exception caught by ApiUserAuthorizeToken.authorize (endpoint)════════');
      if (apiResponse.error != null && apiResponse.error!.endpoint != null && apiResponse.error!.endpoint == 'accessControl') {
        throw ("Permissão de acesso inválido, '${apiResponse.error!.variable["endpoint"]}'");
      } else if (apiResponse.error != null) {
        print(apiResponse.error);
      } else {
        print(apiResponse);
      }
    }
    return false;
  }
}
