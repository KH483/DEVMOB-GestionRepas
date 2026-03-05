import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  // Replace with your Cloudinary credentials
  static const String _cloudName = 'dvw5fprhk';
  static const String _uploadPreset = 'storage';

  static const String _uploadUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  /// Uploads image bytes to Cloudinary and returns the secure URL
  Future<String?> uploadImage(Uint8List imageBytes, String fileName) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      request.fields['upload_preset'] = _uploadPreset;
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: fileName,
        ),
      );

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final json = jsonDecode(body);
        return json['secure_url'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
