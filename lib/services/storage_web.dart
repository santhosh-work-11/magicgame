import 'dart:html' as html;
import 'storage_service.dart';

class WebStorage implements AppStorage {
  @override
  Future<void> init() async {}

  @override
  Future<void> saveString(String key, String value) async {
    html.window.localStorage[key] = value;
  }

  @override
  Future<String?> getString(String key) async {
    return html.window.localStorage[key];
  }
}

AppStorage createStorage() => WebStorage();
