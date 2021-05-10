import 'package:api_connect/src/api_security.dart';
import 'package:api_connect/src/api_storage.dart';
import 'package:api_connect/src/token/api_user_access_token.dart';
import 'package:api_connect/src/token/api_user_authorize_token.dart';
import 'package:flutter/material.dart';

class ApiUser {
  String? id;
  String? apiKey;
  String? email;
  String? authUri;
  String? tokenUri;
  String? info;
  String? auth;
  String? services;
  String? name = '';
  String? role;
  String? firstLetter;
  String clientId = ApiSecurity.encodeSha1('GUEST');

  static final ApiUser _instance = ApiUser._internalConstructor();

  factory ApiUser({dynamic config}) {
    if (config != null) {
      _instance._init(config);
    }
    return _instance;
  }

  ApiUser._internalConstructor();

  void _init(dynamic value) async {
    if (value != null) {
      if (value['name'] != null && value['name'] != '') {
        name = value['name'];
        firstLetter = name!.substring(0, 1);
      }
      if (value['_id'] != null && value['_id'] != '') {
        id = value['_id'];
      }
      if (value['role'] != null && value['role'] != '') {
        role = value['role'];
      }
      if (value['clientId'] != null && value['clientId'] != '') {
        clientId = value['clientId'];
      }
    }

    final apiStorage = await storage;
    if (apiStorage != null) {
      await apiStorage.add('clientId', clientId);
    }
  }

  void dispose() {
    name = null;
    id = null;
    role = null;
    firstLetter = null;
    clientId = ApiSecurity.encodeSha1('GUEST');
  }

  void authorize(String clientId, VoidCallback next) async {
    clientId = clientId;

    final accessToken = await ApiUser.getAccessToken;
    if (accessToken != null) {
      final apiUserAuthorizeToken = ApiUserAuthorizeToken(accessToken);

      if (await apiUserAuthorizeToken.isValid) {
        final isAuthorizeValid = await apiUserAuthorizeToken.authorize();
        if (isAuthorizeValid) {
          final apiUserAccessToken = ApiUserAccessToken(apiUserAuthorizeToken);
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
    next();
  }

  Map<String, dynamic> resume() {
    return {'_id': id, 'name': name};
  }

  static Future<ApiStorage?> get storage async {
    return await ApiStorage.init('user');
  }

  static Future<String?> get getAccessToken async {
    final apiStorage = await storage;
    return apiStorage!.read('ACT');
  }

  static void accessToken(String value) async {
    final apiStorage = await storage;
    await apiStorage!.add('ACT', value);
  }

  static Future<String?> get getAuthToken async {
    final apiStorage = await storage;
    return apiStorage!.read('AUT');
  }

  static void authToken(String value) async {
    final apiStorage = await storage;
    await apiStorage!.add('AUT', value);
  }

  static void serverUri(String value) async {
    final apiStorage = await storage;
    await apiStorage!.add('URI', value);
  }

  static Future<String?> get getServerUri async {
    final apiStorage = await storage;
    return apiStorage!.read('URI');
  }

  @override
  String toString() {
    return 'Instance of ApiUser(clientId:$clientId, id:$id, name:$name, role:$role)';
  }
}
