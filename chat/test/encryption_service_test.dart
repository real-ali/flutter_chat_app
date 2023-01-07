import 'package:chat/src/services/encryption/encryption_contract.dart';
import 'package:chat/src/services/encryption/encryption_service.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  IEncryption sut;

  setUp(() {
    final encrypter = Encrypter(AES(Key.fromLength(32), IV.fromLength(16)));
    sut = EncryptionService(encrypter);
  });
  test("it Encrypt the plain text", () {
    const text = 'this is a text ';
    final base64 = RegExp(
        r'^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$');

    final encrypted = sut.encrypt(text);

    expect(base64.hasMatch(encrypted), true);
  });

  test("decrypts the encrypted text", () {
    const text = 'this is a message';
    final encrypted = sut.encrypt(text);
    final decrypted = sut.decrypt(encrypted);
    expect(decrypted, text);
  });
}
