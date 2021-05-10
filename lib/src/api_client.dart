import 'api_storage.dart';

class ApiClient {
  static Future<ApiStorage?> get storage async {
    return await ApiStorage.init('CLI');
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
}
