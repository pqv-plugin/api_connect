import 'package:jose/jose.dart';

import '../api_client.dart';
import '../api_connection.dart';
import '../api_security.dart';

class ApiClientAuthorizeToken {
  final String token;

  String? apiUri;
  String? clientId;
  String? clientSecret;
  String? code;
  String? codeChallenge;
  String? codeVerifier;
  String? codeVerifier64;
  String? nonceToken;
  String? state;
  String? context;
  String? subject;

  ApiClientAuthorizeToken(this.token) {
    codeVerifier = ApiSecurity.randomBytes(32);
    codeVerifier64 = ApiSecurity.base64URLEncode(codeVerifier!);
    codeChallenge = ApiSecurity.base64URLEncode(ApiSecurity.encodeSha256(codeVerifier64!));
    state = ApiSecurity.randomBytes(16);
  }

  ///Verifica se existe um token de autorização de cliente registrado na sessão local da aplicação
  ///Verifica se o token tem identificação do distribuidor e se o subject é do tipo auth_token
  Future<bool> get isValid async {
    var isValid = false;

    print('7777777777777777777777777777777777');

    try {
      final jwt = JsonWebToken.unverified(token);
      print('999999999999999999999999999999999999999');
      if (jwt.claims['iss'] != null && jwt.claims['sub'] == 'auth_token') {
        print('33333333333333333333333333333333333333');
        apiUri = jwt.claims['iss'];
        clientId = jwt.claims['cid'];
        context = jwt.claims['ctx'];
        subject = jwt.claims['sub'];
        clientSecret = ApiSecurity.encodeSha256((clientId!) + (codeVerifier64!));
        print('55555555555555555555555555555555555');
        print(clientSecret);
        print('kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk');

        final apiStorage = await ApiClient.storage;

        print('6666666666666666666666666666');
        print(apiStorage);

        if (apiStorage != null && clientId != null) {
          print('wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww');
          await apiStorage.add('clientId', clientId);
        }
        print('ffffffffffffffffffffffffffffff');
        isValid = true;
      }
      print('444444444444444444444444444444444');
    } catch (e) {
      print('════════ Exception caught by ApiClientAuthorizeToken.isValid ════════');
      throw ("Token de autorização da aplicação 'client' inválido.");
    }

    print('88888888888888888888888888888888888888888888');
    print(isValid);

    return isValid;
  }

  Future<bool> get ready async {
    final apiStorage = await ApiClient.storage;
    final clientId = apiStorage!.read('clientId');
    return clientId!.isNotEmpty;
  }

  Future<bool> authorize() async {
    //Cria conexão com o servidor graphql
    final apiConnection = ApiConnection(token, apiUri!);

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
      if (authorize.success && authorize.hasData) {
        if (authorize.result['state'] == state) {
          code = authorize.result['code'];
          nonceToken = authorize.result['nonceToken'];
          return true;
        }
      }
    } else {
      print('════════ Exception caught by ApiClientAuthorizeToken.authorize ════════');
      print(apiResponse.error);
    }
    return false;
  }
}
