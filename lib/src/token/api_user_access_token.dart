import 'package:jose/jose.dart';

import '../api_connection.dart';
import '../api_user.dart';
import '../token/api_user_authorize_token.dart';

class ApiUserAccessToken {
  final ApiUserAuthorizeToken apiUserAuthorize;
  late String clientId;
  late String tokenType;
  late String expiresIn;
  late String accessToken;
  late String refreshToken;
  bool isValid = false;

  ApiUserAccessToken(this.apiUserAuthorize);

  Future<bool> token() async {
    String? clientId = ApiUser().clientId;
    final apiConnection = ApiConnection(apiUserAuthorize.nonceToken, apiUserAuthorize.apiUri);

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
      'clientId': clientId,
      'clientSecret': apiUserAuthorize.clientSecret,
      'code': apiUserAuthorize.code,
      'codeVerifier': apiUserAuthorize.codeVerifier64,
      'grantType': 'authorization_code'
    };

    final apiResponse = await apiConnection.mutation(params, variable);
    final token = apiResponse!.endpoint('token');

    if (token.success && token.hasData) {
      tokenType = token.result['tokenType'];
      expiresIn = token.result['expiresIn'];
      accessToken = token.result['accessToken'];
      refreshToken = token.result['refreshToken'];
      isValid = true;

      final apiStorage = await ApiUser.storage;
      if (apiStorage != null) {
        await apiStorage.add('accessToken', accessToken);
        await apiStorage.add('refreshToken', refreshToken);

        try {
          final jwt = JsonWebToken.unverified(accessToken);
          if (jwt.claims['iss'] != null) {
            await apiStorage.add('serverUri', jwt.claims['iss']);
          }
        } catch (e) {
          throw ("Token de inicialização 'User token' inválido");
        }
      }

      return isValid;
    }
    return false;
  }
}
