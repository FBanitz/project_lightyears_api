import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'constants/app_info.dart';
import 'controllers/request_handlers/auth.dart';
import 'controllers/request_handlers/local_files.dart';
import 'controllers/request_handlers/root.dart';
import 'controllers/request_handlers/user.dart';

final DateTime _serverStart = DateTime.now();

final File _requestsLogfile = File('logs/requests/log_${_serverStart.day}-${_serverStart.month}-${_serverStart.year}_${_serverStart.hour}-${_serverStart.minute}-${_serverStart.second}.txt');

final String _webDirectory = Platform.environment['WEB_DIRECTORY'] ?? 'web';
final LocalFileController _localFileHandler = LocalFileController(log : ((msg) =>  _log(msg, _requestsLogfile)), webDirectory: _webDirectory);
final RootController _rootHandler = RootController(log : ((msg) =>  _log(msg, _requestsLogfile)));
final AuthController _authHandler = AuthController(log : ((msg) =>  _log(msg, _requestsLogfile)));
final UserController _userHandler = UserController(log : ((msg) =>  _log(msg, _requestsLogfile)));

final _router = Router();

void _log(String msg, File logfile) {
  print(msg);

  if (!Platform.environment.containsKey('DEBUG')) {
    logfile.writeAsStringSync('\n$msg', mode: FileMode.append);
  }
}

void main(List<String> args) async {
  _router
    ..get('/', _rootHandler.root)
    ..post('/register', _authHandler.register)
    ..post('/login', _authHandler.login)
    ..get('/user/<id>', _userHandler.get)
    ..put('/user/<id>', _userHandler.update)
    ..get('/<file|.*>', _localFileHandler.get);

  _log("Project Lightyears v$appVersion", _requestsLogfile);

  if (!Directory('logs').existsSync()) {
    Directory('logs').createSync();
  }

  if (!Directory('logs/requests').existsSync()) {
    Directory('logs/requests').createSync();
  }

  if (!Directory('data').existsSync()) {
    Directory('data').createSync();
  }

  if (!Directory('data/users').existsSync()) {
    Directory('data/users').createSync();
  }

  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests to the console and writes them to a file.
  final handler = Pipeline().addMiddleware(logRequests(logger: (msg, isError) => _log(msg, _requestsLogfile))).addHandler(_router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8081');
  final server = await serve(handler, ip, port);

  _log('---', _requestsLogfile);
  _log('| ${_serverStart.day}/${_serverStart.month}/${_serverStart.year} ${_serverStart.hour}:${_serverStart.minute}', _requestsLogfile);
  _log('| Server started at ${server.address.address}', _requestsLogfile);
  _log('| Listening on port ${server.port}', _requestsLogfile);
  _log('---\n', _requestsLogfile);
}
