import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_data.dart';
import 'local_store.dart';

final localStoreProvider = Provider<LocalStore>((ref) {
  return LocalStore();
});

final appDataProvider = FutureProvider<AppData>((ref) async {
  final store = ref.read(localStoreProvider);
  final data = await store.load();
  return data;
});
