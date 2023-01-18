import 'dart:io';

import 'package:shelf/shelf.dart';

import 'request_handler_controller.dart';

class LocalFileController extends RequestsHandlerController {
  final String webDirectory;

  LocalFileController(
      {required void Function(String) log, required this.webDirectory})
      : super(log: log);

  _getContentType(String fileExtension) {
    switch (fileExtension) {
      case 'html':
        return 'text/html';
      case 'css':
        return 'text/css';
      case 'js':
        return 'application/javascript';
      case 'png':
        return 'image/png';
      case 'jpg':
        return 'image/jpeg';
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'svg':
        return 'image/svg+xml';
      case 'ico':
        return 'image/x-icon';
      default:
        return 'text/plain';
    }
  }

  Response get(Request request) {
    final fileName = request.url.pathSegments.last;
    final localFile = File('$webDirectory/$fileName');
    if (!localFile.existsSync()) {
      return Response(404, body: 'File not found');
    }
    final fileExtension = fileName.split('.').last;
    final contentType = _getContentType(fileExtension);
    log('Serving $fileName as $contentType');
    return Response.ok(localFile.readAsBytesSync(), headers: {
      HttpHeaders.contentTypeHeader: contentType,
    });
  }
}
