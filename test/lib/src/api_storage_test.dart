import 'package:api_connect/src/api_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ApiStorage apiStorage;

  setUp(() async {
    apiStorage = ApiStorage('test');
  });

  group('ApiStorage', () {
    test('Adiciona valor no armazenamento local', () {
      var onAddA = expectAsync0(() async {
        await apiStorage.add('valueA', '123456');
        expect(apiStorage.read('valueA'), '123456');
      });
      onAddA();

      var onAddB = expectAsync0(() async {
        await apiStorage.add('valueB', 'abcdef');
        expect(apiStorage.read('valueB'), 'abcdef');
      });
      onAddB();
    });

    test('Inicia armazenamento local criado anteriormente', () {
      var onInit = expectAsync0(() async {
        final apiStorage = await ApiStorage.init('test');
        expect(apiStorage, isA<ApiStorage>());
      });
      onInit();
    });

    test('Remove valor do armazenamento local', () {
      var onRemove = expectAsync0(() async {
        await apiStorage.remove('valueA');
        expect(apiStorage.read('valueA'), null);
      });
      onRemove();
    });

    test('Limpa armazenamento local', () {
      var onClean = expectAsync0(() async {
        await apiStorage.clean();
        expect(apiStorage.read('valueB'), null);
      });
      onClean();
    });
  });
}
