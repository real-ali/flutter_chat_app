import 'dart:io';

import 'package:http/http.dart';

class ImageUploader {
  final String _url;

  ImageUploader(this._url);

  Future<String> uploadImage(File image) async {
    final request = MultipartRequest('POST', Uri.parse(_url));
    request.files.add(await MultipartFile.fromPath('picture', image.path));
    final result = await request.send();
    if (result.statusCode != 200) return null;
    final respons = await Response.fromStream(result);
    print("complete image uploading");
    return Uri.parse(_url).origin + respons.body;
  }
}
