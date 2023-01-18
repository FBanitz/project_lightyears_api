import 'dart:convert';
import 'package:crypto/crypto.dart';

extension StringExtension on String {
  String hached() {
    return sha256.convert(utf8.encode(this)).toString();
  }
}