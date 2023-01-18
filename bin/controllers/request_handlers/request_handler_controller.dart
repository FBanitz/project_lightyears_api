import 'package:meta/meta.dart';

class RequestsHandlerController {
  late void Function(String) _log;
  @protected void log(String msg) => _log(msg);

  RequestsHandlerController({required void Function(String) log}) {
    _log = (msg) {
      log('[$runtimeType]: $msg');
    };
  }
}
