// ignore_for_file: depend_on_referenced_packages
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

class TokenGenerator {


  static final _uuid = Uuid();
  static final _random = Random.secure();

  static String generateSecureToken() {
    final randomBytes = List<int>.generate(32, (i) => _random.nextInt(256));

    final uuidPart = _uuid.v4().replaceAll('-', '').substring(0, 8);

    final sha512Hash = sha512
        .convert(utf8.encode(base64UrlEncode(randomBytes) + uuidPart))
        .bytes;
    final shortHash =
        base64UrlEncode(sha512Hash).substring(0, 32); // Обрезаем до 32 символов

    return shortHash;
  }
}
