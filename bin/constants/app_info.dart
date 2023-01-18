import 'dart:io';

final appVersion = File('pubspec.yaml').readAsStringSync().split('\n').firstWhere((line) => line.startsWith('version:')).split(' ').last;