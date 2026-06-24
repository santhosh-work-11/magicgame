import 'storage_unsupported.dart'
    if (dart.library.io) 'storage_io.dart'
    if (dart.library.html) 'storage_web.dart';

abstract class AppStorage {
  Future<void> init();
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
}

class MemoryStorage implements AppStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> init() async {}

  @override
  Future<void> saveString(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<String?> getString(String key) async {
    return _data[key];
  }
}

// Global or helper factory to get the platform-specific storage implementation
AppStorage createStorageInstance() => createStorage();
