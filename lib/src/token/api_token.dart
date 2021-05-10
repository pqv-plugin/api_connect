import 'package:jose/jose.dart';

class ApiToken {
  final String token;

  ApiToken(this.token);

  Future<bool> get valid async {
    var isValid = false;
    try {
      final jwt = JsonWebToken.unverified(token);
      if (jwt.claims['iss'] != null) {
        isValid = true;
      }
    } catch (e) {
      throw ('Token inválido');
    }
    return isValid;
  }
}
