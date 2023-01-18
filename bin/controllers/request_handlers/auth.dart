import 'package:shelf/shelf.dart';

import 'request_handler_controller.dart';

class AuthController extends RequestsHandlerController {
  AuthController({required void Function(String) log}) : super(log: log);

  Response register(Request request) {
    return Response.ok('register');
  }

  Response login(Request request) {
    return Response.ok('login');
  }
}
