import 'dart:async';

import 'package:web/web.dart' as web;

Future<bool>? _loading;
Future<bool> loadAdminMaps() => _loading ??= _load();
Future<bool> _load() async {
  const key = String.fromEnvironment('MAPS_WEB_KEY');
  if (key.isEmpty) return false;
  final completer = Completer<bool>();
  final script = (web.document.createElement('script') as web.HTMLScriptElement)
    ..src = Uri.https('maps.googleapis.com', '/maps/api/js', {
      'key': key,
    }).toString()
    ..async = true;
  final loaded = script.onLoad.listen((_) {
    if (!completer.isCompleted) completer.complete(true);
  });
  final failed = script.onError.listen((_) {
    if (!completer.isCompleted) completer.complete(false);
  });
  web.document.head!.appendChild(script);
  try {
    return await completer.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () => false,
    );
  } finally {
    await loaded.cancel();
    await failed.cancel();
  }
}
