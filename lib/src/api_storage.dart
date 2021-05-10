import 'package:get_storage/get_storage.dart';

import 'api_security.dart';

/// Um objeto que representa o armazenamento de dados locais.
///
/// A [ApiStorage] é usado para manipular o armazenamento de dados locais,
/// garantindo a persistência para uso futuro.
/// Por examplo:
/// ```dart
/// ApiStorage apiStorage = ApiStorage('data');
/// await apiStorage.add('valueA', '123456');
/// final data = apiStorage.read('valueA');
/// ```
///
/// A apiStorage pode persistir qualquer tipo de dados necessários para o funcionamento
/// da aplicação, sendo utilizado principlamente para guardar identificação do usuário.
class ApiStorage {
  /// Identificador do pacote de dados.
  final String name;

  /// Senha de proteção
  final String password;
  late GetStorage? _storage;

  ApiStorage(this.name, [this.password = '*']) {
    _storage = GetStorage(ApiSecurity.encodeSha1(name));
  }

  /// Recupera um objeto de armazenamento local criado anteriomente.
  static Future<ApiStorage?> init(String name) async {
    ApiStorage? apiStorage;
    dynamic isStorage = await GetStorage.init(ApiSecurity.encodeSha1(name));

    if (isStorage != null) {
      apiStorage = ApiStorage(name);
    }

    return apiStorage;
  }

  /// Adiciona valor no objeto de armazenamento local.
  Future<void> add(String? key, String? value) async {
    if (_storage != null && key != null && value != null) {
      await _storage!.write(ApiSecurity.encrypt(key, password)!, ApiSecurity.encrypt(value, password));
    } else {
      print('════════ Exception caught by ApiStorage.add ════════');
      throw ('storage.add(?)');
    }
  }

  /// Remove todos os valores do objeto
  Future<void> clean() async {
    await _storage!.erase();
  }

  // Remove da memória o objeto de gerenciamento local.
  void dispose() {
    _storage = null;
  }

  /// Remove um valor do objeto de armazenamento local.
  Future<void> remove(String? key) async {
    if (_storage != null && key != null) {
      await _storage!.remove(key);
    } else {
      print('════════ Exception caught by ApiStorage.remove ════════');
      throw ('storage.remove(?)');
    }
  }

  /// Obtém um do objeto de armazenamento local.
  String? read(String key) {
    String? result;
    if (_storage != null) {
      final value = _storage!.read(ApiSecurity.encrypt(key, password)!);
      if (value != null) {
        result = ApiSecurity.decode(value, password);
      }
    }
    return result;
  }
}
