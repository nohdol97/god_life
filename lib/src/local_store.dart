import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_data.dart';

/// 로컬 파일 또는 메모리 저장소를 감싸는 단순 스토어.
class LocalStore {
  LocalStore() : _delegate = _FileStore();

  LocalStore.inMemory([AppData? seed])
    : _delegate = _MemoryStore(seed ?? AppData.sample());

  final _Store _delegate;

  Future<AppData> load() => _delegate.load();

  Future<void> save(AppData data) => _delegate.save(data);
}

abstract class _Store {
  Future<AppData> load();
  Future<void> save(AppData data);
}

class _MemoryStore implements _Store {
  _MemoryStore(this._data);
  AppData _data;

  @override
  Future<AppData> load() async => _data;

  @override
  Future<void> save(AppData data) async {
    _data = data;
  }
}

class _FileStore implements _Store {
  _FileStore() : _fileFuture = _initFile();

  final Future<File> _fileFuture;

  static Future<File> _initFile() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'god_life.json'));
    return file;
  }

  @override
  Future<AppData> load() async {
    final file = await _fileFuture;
    if (!await file.exists()) return AppData.sample();
    final contents = await file.readAsString();
    if (contents.isEmpty) return AppData.sample();
    final json = jsonDecode(contents) as Map<String, dynamic>;
    return AppData.fromJson(json);
  }

  @override
  Future<void> save(AppData data) async {
    final file = await _fileFuture;
    await file.create(recursive: true);
    await file.writeAsString(data.toJsonString());
  }
}
