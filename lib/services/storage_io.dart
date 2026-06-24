import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'storage_service.dart';

class IoStorage implements AppStorage {
  Directory? _dir;

  @override
  Future<void> init() async {
    _dir = await getApplicationDocumentsDirectory();
  }

  @override
  Future<void> saveString(String key, String value) async {
    if (_dir == null) return;
    final file = File('${_dir!.path}/$key.json');
    await file.writeAsString(value);
  }

  @override
  Future<String?> getString(String key) async {
    if (_dir == null) return null;
    final file = File('${_dir!.path}/$key.json');
    if (await file.exists()) {
      return await file.readAsString();
    }
    return null;
  }
}

AppStorage createStorage() {
  if (Platform.environment.containsKey('FLUTTER_TEST')) {
    return MemoryStorage();
  }
  return IoStorage();
}
