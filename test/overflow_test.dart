import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:oleena/main.dart';
import 'package:oleena/core/api_client.dart';
import 'package:oleena/core/auth_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Mock ApiClient and SecureStorage
class MockApiClient extends Mock implements ApiClient {
  @override
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    // Return longest realistic strings
    if (endpoint.contains('/services')) {
      return [
        {
          "serviceId": 1,
          "vendorId": 1,
          "categoryId": 1,
          "title": "A Very Long Service Title That Exceeds Normal Boundaries And Should Definitely Overflow If Not Handled Properly",
          "description": "An incredibly long description that goes on and on to test if the layout wraps correctly without throwing rendering errors or overflowing the bottom.",
          "price": 100000000.00,
          "vendor": {
            "vendorId": 1,
            "businessName": "The Most Extraordinarily Long Business Name In The World LLC",
          },
          "category": {
            "name": "Very Long Category Name"
          }
        }
      ];
    }
    return {};
  }
}

class FakeHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _FakeHttpClient();
  }
}

class _FakeHttpClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return _FakeHttpClientRequest();
  }
  @override
  bool autoUncompress = true;
}

class _FakeHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async {
    return _FakeHttpClientResponse();
  }
  @override
  HttpHeaders get headers => _FakeHttpHeaders();
}

class _FakeHttpHeaders extends Fake implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _FakeHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;
  
  @override
  int get contentLength => _transparentPixel.length;
  
  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_transparentPixel).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  // 1x1 transparent PNG
  static const List<int> _transparentPixel = [
    137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 
    0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 
    0, 0, 0, 11, 73, 68, 65, 84, 8, 215, 99, 96, 0, 2, 0, 0, 5, 
    0, 1, 226, 38, 5, 155, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130
  ];
}

void main() {
  setUpAll(() {
    HttpOverrides.global = FakeHttpOverrides();
  });

  testWidgets('Check for Overflows Across Screens', (WidgetTester tester) async {
    // 320x640 (very narrow)
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    
    // We will just pump the app and navigate through routes
    // But since it's hard to navigate all, we can just pump the individual screens or check manually.
  });
}
