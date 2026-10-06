import 'package:flutter_test/flutter_test.dart';
import 'package:oleena/core/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppConfig Tests', () {
    test('Default devHostIp returns valid IP format', () {
      expect(AppConfig.devHostIp, isNotEmpty);
      expect(AppConfig.devHostIp, contains('.'));
    });

    test('Backend port defaults to 5131', () {
      expect(AppConfig.backendPort, equals('5131'));
    });

    test('BaseUrl defaults to live Railway backend URL', () {
      final url = AppConfig.baseUrl;
      expect(url, equals('https://owpbackend-production.up.railway.app/api'));
    });

    test('setHostIp updates currentHost and baseUrl', () async {
      await AppConfig.setHostIp('192.168.1.99');
      expect(AppConfig.currentHost, equals('192.168.1.99'));
      expect(AppConfig.baseUrl, equals('http://192.168.1.99:5131/api'));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(AppConfig.kCachedDevIp), equals('192.168.1.99'));
    });
  });
}
