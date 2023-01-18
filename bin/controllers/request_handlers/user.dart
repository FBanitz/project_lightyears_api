import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'request_handler_controller.dart';

class UserController extends RequestsHandlerController {
  UserController({required void Function(String) log}) : super(log: log);
  
  final _usersDirectory = Directory('${Platform.environment['DATA_DIR']}/users');

  Response get(Request request) {
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

  Response update(Request request) {
    return Response.ok('updateUser');
  }

  Response delete(Request request) {
    return Response.ok('deleteUser');
  }
}