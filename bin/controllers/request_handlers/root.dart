import 'package:shelf/shelf.dart';

import 'request_handler_controller.dart';

class RootController extends RequestsHandlerController {
  RootController({required void Function(String) log}) : super(log: log);

  Response root(Request request) {
    return Response.ok('Hello, World!\n');
  }
}