import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'constants/app_info.dart';
import 'controllers/request_handlers/auth.dart';
import 'controllers/request_handlers/local_files.dart';
import 'controllers/request_handlers/root.dart';
import 'controllers/request_handlers/user.dart';


void log(String msg, File logfile) {
  print(msg);

  if (!Platform.environment.containsKey('DEBUG')) {
    logfile.writeAsStringSync('\n$msg', mode: FileMode.append);
  }
}



void main(List<String> args) async {
  final db = Db('mongodb://localhost:27017/project_lightyears');
  final DateTime serverStart = DateTime.now();

  final File requestsLogfile = File(
      'logs/requests/log${serverStart.day}-${serverStart.month}-${serverStart.year}${serverStart.hour}-${serverStart.minute}-${serverStart.second}.txt');

  await db.open();
  log('Connected to MongoDB', requestsLogfile);

  final DbCollection store = db.collection('users');

  final router = Router();

  router.mount('/auth/', AuthController(log: (msg) =>  log(msg, requestsLogfile), store: store, secret: 'mysecret').router);


  // router
  //   ..get('/', rootHandler.root)
  //   ..get('/user/<id>', userHandler.get)
  //   ..put('/user/<id>', userHandler.update)
  //   ..get('/<file|.*>', localFileHandler.get);

  log("Project Lightyears v$appVersion", requestsLogfile);

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
  final handler = Pipeline().addMiddleware(logRequests(logger: (msg, isError) => log(msg, requestsLogfile))).addHandler(router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8081');
  final server = await serve(handler, ip, port);

  log('---', requestsLogfile);
  log('| ${serverStart.day}/${serverStart.month}/${serverStart.year} ${serverStart.hour}:${serverStart.minute}', requestsLogfile);
  log('| Server started at ${server.address.address}', requestsLogfile);
  log('| Listening on port ${server.port}', requestsLogfile);
  log('---\n', requestsLogfile);
}
