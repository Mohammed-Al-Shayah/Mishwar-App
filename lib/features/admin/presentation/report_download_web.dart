import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

void downloadReport(String csv, String filename) {
  final blob = web.Blob(
    [csv.toJS].toJS,
    web.BlobPropertyBag(type: 'text/csv;charset=utf-8'),
  );
  final url = web.URL.createObjectURL(blob);
  final link = web.HTMLAnchorElement()
    ..href = url
    ..download = filename;
  web.document.body!.appendChild(link);
  link
    ..click()
    ..remove();
  // Keep the URL alive until the browser has consumed the download navigation.
  Timer(const Duration(seconds: 1), () => web.URL.revokeObjectURL(url));
}
