import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';
import './extensions/string.dart';

final File _favicon = File('web/favicon.ico');
final Directory _usersDirectory = Directory('data/users');

final DateTime _serverStart = DateTime.now();

// Create a log file.
final _requestsLogfile = File('logs/requests/log_${_serverStart.day}-${_serverStart.month}-${_serverStart.year}_${_serverStart.hour}-${_serverStart.minute}-${_serverStart.second}.txt');

// Configure routes.
final _router = Router()
  ..get('/', _rootHandler)
  ..get('/echo/<message>', _echoHandler)
  ..get('/ping', _pingHandler)
  ..get('/favicon.ico', _faviconHandler)
  ..post('/register', _registerHandler)
  ..post('/login', _loginHandler)
  ..get('/user/<id>', _getUserHandler)
  ..put('/user/<id>', _updateUserHandler)
  ;

Response _rootHandler(Request req) {
  return Response.ok('Hello, World!\n');
}

Response _pingHandler(Request req) {
  return Response.ok('pong\n');
}

Response _getUserHandler(Request request) {
  final id = request.params['id'];

  final userFile = File('${_usersDirectory.path}/$id.json');

  if (!userFile.existsSync()) {
    return Response(404, body: 'User not found');
  }

  final user = jsonDecode(userFile.readAsStringSync());

  final safeUser = {
    'id': user['id'],
    'created_at': user['created_at'],
    'updated_at': user['updated_at'],
    'first_name': user['first_name'],
    'last_name': user['last_name'],
  };

  return Response.ok(jsonEncode(safeUser));
}

Response _echoHandler(Request request) {
  final message = request.params['message'];
  return Response.ok('$message\n');
}

Response _registerHandler(Request request) {
  final id = Uuid().v4();
  final createdAt = DateTime.now().toIso8601String();
  final updatedAt = DateTime.now().toIso8601String();
  final firstName = request.url.queryParameters['first_name'];
  final lastName = request.url.queryParameters['last_name'];
  final email = request.url.queryParameters['email'];
  final password = request.url.queryParameters['password'];
  final tocken = Uuid().v4();

  final userFile = File('${_usersDirectory.path}/$id.json');

  if (firstName == null) {
    return Response(400, body: 'Missing first name');
  }

  if (lastName == null) {
    return Response(400, body: 'Missing last name');
  }

  if (email == null) {
    return Response(400, body: 'Missing email');
  }

  for (final userFileEntity in _usersDirectory.listSync()) {
    final userFile = File(userFileEntity.path);
    final user = jsonDecode(userFile.readAsStringSync());

    if (user['email'] == email) {
      return Response(400, body: 'Email already in use');
    }
  }

  if (password == null) {
    return Response(400, body: 'Missing password');
  }
  
  final passwordHached = password.hached();

  final user = {
    'id': id,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'password': passwordHached,
    'tocken': tocken,
  };

  userFile.writeAsStringSync(jsonEncode(user));

  Future.delayed(Duration(milliseconds: 1), () {
    _log('User created: $firstName $lastName', _requestsLogfile);
  });

  final safeUser = {
    'id': user['id'],
    'created_at': user['created_at'],
    'updated_at': user['updated_at'],
    'first_name': user['first_name'],
    'last_name': user['last_name'],
    'email': email,
    'tocken': tocken,
  };

  return Response.ok(jsonEncode(safeUser));
}

Future<Response> _loginHandler(Request request) async {
  final email = request.url.queryParameters['email'];
  final password = request.url.queryParameters['password'];

  if (email == null) {
    return Response(400, body: 'Missing email');
  }

  if (password == null) {
    return Response(400, body: 'Missing password');
  }

  final passwordHached = password.hached();

  for (final userFileEntity in _usersDirectory.listSync()) {
    final userFile = File(userFileEntity.path);
    final user = jsonDecode(userFile.readAsStringSync());

    if (user['email'] == email) {
      if (user['password'] != passwordHached) {
        return Response(401, body: 'Wrong password');
      }

      final tocken = Uuid().v4();

      user['tocken'] = tocken;

      userFile.writeAsStringSync(jsonEncode(user));

      _log('User logged in: ${user['first_name']} ${user['last_name']}', _requestsLogfile);

      final safeUser = {
        'id': user['id'],
        'created_at': user['created_at'],
        'updated_at': user['updated_at'],
        'first_name': user['first_name'],
        'last_name': user['last_name'],
        'email': user['email'],
        'tocken': user['tocken'],
      };

      return Response.ok(jsonEncode(safeUser));
    }
  }

  return Response(404, body: 'User not found');
}

Response _updateUserHandler(Request request) {
  final id = request.params['id'];
  final firstName = request.url.queryParameters['first_name'];
  final lastName = request.url.queryParameters['last_name'];
  final email = request.url.queryParameters['email'];
  final password = request.url.queryParameters['password'];
  final tocken = request.url.queryParameters['tocken'];

  final userFile = File('${_usersDirectory.path}/$id.json');

  if (!userFile.existsSync()) {
    return Response(404, body: 'User not found');
  }

  final user = jsonDecode(userFile.readAsStringSync());

  if (user['tocken'] != tocken) {
    return Response(401, body: 'Unauthorized');
  }

  if (firstName != null) {
    user['first_name'] = firstName;
  }

  if (lastName != null) {
    user['last_name'] = lastName;
  }

  if (email != null) {
    user['email'] = email;
  }

  if (password != null) {
    user['password'] = password.hached();
  }

  user['updated_at'] = DateTime.now().toIso8601String();

  userFile.writeAsStringSync(jsonEncode(user));

  _log('User updated: ${user['first_name']} ${user['last_name']}', _requestsLogfile);

  final safeUser = {
    'id': user['id'],
    'created_at': user['created_at'],
    'updated_at': user['updated_at'],
    'first_name': user['first_name'],
    'last_name': user['last_name'],
    'email': user['email'],
  };

  return Response.ok(jsonEncode(safeUser));
}

Response _faviconHandler(Request request) {
  return Response.ok(_favicon.readAsBytesSync(), headers: {
    HttpHeaders.contentTypeHeader: 'image/x-icon',
  });
}

void _log(String msg, File logfile) {
  print(msg);

  // Append the message to the log file if not in debug mode.
  if (!Platform.environment.containsKey('DEBUG')) {
    logfile.writeAsStringSync('\n$msg', mode: FileMode.append);
  }
}

void main(List<String> args) async {

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
