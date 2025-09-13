import 'dart:convert';
import 'dart:typed_data';
import 'package:basic_utils/basic_utils.dart';
import 'package:convert/convert.dart';
import 'package:pointycastle/asn1/asn1_parser.dart';
import 'package:pointycastle/asn1/primitives/asn1_integer.dart';
import 'package:pointycastle/asn1/primitives/asn1_sequence.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/signers/rsa_signer.dart';

class AituPassportConfig {
  static const String clientId = '';
  static const String url = 'passport.aitu.io';
  static const String redirectUrl = 'maktub://callback';
  static const String privateKeyPem = '';



static String signAndEncode(String iin) {
  final privateKey = _parseRsaPrivateKeyFromPem(privateKeyPem);
  final signer = RSASigner(SHA256Digest(), '0609608648016503040201');
  signer.init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));

  final dataToSign = Uint8List.fromList(utf8.encode(iin));
  final signature = signer.generateSignature(dataToSign).bytes;

  // Только base64!
  return base64Encode(signature);
}


static RSAPrivateKey _parseRsaPrivateKeyFromPem(String pem) {
  final rows = pem
      .replaceAll('-----BEGIN RSA PRIVATE KEY-----', '')
      .replaceAll('-----END RSA PRIVATE KEY-----', '')
      .replaceAll(RegExp(r'\s+'), '');

  final asn1Parser = ASN1Parser(base64Decode(rows));
  final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;

  BigInt _readBigInt(int index) {
    final integer = topLevelSeq.elements![index] as ASN1Integer;
    return BigInt.parse(hex.encode(integer.valueBytes!), radix: 16);
  }

  final modulus = _readBigInt(1);
  final privateExponent = _readBigInt(3);
  final p = _readBigInt(4);
  final q = _readBigInt(5);

  return RSAPrivateKey(modulus, privateExponent, p, q);
}

}
