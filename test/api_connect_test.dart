import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('A group of tests', () {
    //late ApiConnect apiConnect;
    late GetStorage g;

    setUp(() async {
      /*apiConnect = ApiConnect(
          'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdWQiOlsiaHR0cDovL2xvY2FsaG9zdDo0NjAwIl0sImNudCI6InN1cG9ydGUtYXBpQGFlZ2lzLmFwcC5iciIsImNpZCI6IjYwN2M4MzViNDM5ZWQxNDk4ODViMGNiYSIsImNuYSI6IkNvcmRhIEx1eiIsImN0eCI6ImNsaWVudCIsImV4cCI6NDcyOTE3MjgyNywiaWF0IjoxNjE4NzcyODI3LCJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjQ2MDAiLCJzY29wZSI6Im11dDphdXRob3JpemUiLCJzdWIiOiJhdXRoX3Rva2VuIiwidWlkIjoiczM3YmMyZWIxMCIsInByaiI6ImJhcnJhLWRvLWNvcmRhIn0.2dMV9K1DfNcR1PHnSI9gRi7xisBbS7cIXwxKGiWTvek');*/

      await GetStorage.init();
      g = GetStorage();
      await g.erase();
    });

    test('Testa a conexção da aplicação', () {
      print('ssssssssssssssssssssssssssssssssssssssssssssssss');
      //print(apiConnect.apiClientAccessToken);
      //print(apiConnect.apiClientAuthorize);
      print(g);
      print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
      //expect(apiConnect.isAwesome, isTrue);
    });
  });
}
