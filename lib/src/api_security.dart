import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:xxtea/xxtea.dart';

class ApiSecurity {
  static String randomBytes(int length) {
    var text = '';
    final possible = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_';
    final rng = Random();
    for (var i = 0; i < length; i++) {
      text += (possible[rng.nextInt(possible.length)]).toString();
    }
    return text;
  }

  static String base64URLEncode(String str) {
    return base64Url.encode(utf8.encode(str)).replaceAll('+', '-').replaceAll('\/', '_').replaceAll('=', '');
  }

  static String encodeSha256(String value) {
    final subject = utf8.encode(value);
    return sha256.convert(subject).toString();
  }

  static String encodeSha1(String value) {
    final subject = utf8.encode(value);
    return sha1.convert(subject).toString();
  }

  static String? encrypt(String? value, String? password) {
    if (value != null && password != null) {
      value = xxtea.encryptToString(value, password);
    }
    return value;
  }

  static String? decode(String? value, String? password) {
    if (value != null && password != null) {
      value = xxtea.decryptToString(value, password);
    }
    return value;
  }

  static String uid() {
    var text = '';
    final length = 16;
    final possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rng = Random();
    for (var i = 0; i < length; i++) {
      text += (possible[rng.nextInt(possible.length)]).toString();
    }

    return text.substring(0, 4) + '-' + text.substring(4, 8) + '-' + text.substring(8, 12) + '-' + text.substring(12, text.length);
  }

  static String uidSha1(String text) {
    text = encodeSha1(text).toUpperCase();
    return text.substring(0, 4) + '-' + text.substring(4, 8) + '-' + text.substring(8, 12) + '-' + text.substring(12, 16);
  }
}
