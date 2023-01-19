import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'request_handler_controller.dart';

import 'package:mongo_dart/mongo_dart.dart';

// https://youtu.be/Md6F93lqraQ

class AuthController extends RequestsHandlerController {
  DbCollection store;
  String secret;

  AuthController({
    required void Function(String) log,
    required this.store,
    required this.secret,
  }) : super(log: log);

  Router get router {
    final router = Router();

    router.post('/register', register);
    router.post('/login', login);

    return router;
  }

  Response register(Request request) {
    return Response.ok('register');
  }

  Response login(Request request) {
    return Response.ok('login');
  }
}
