import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker_web/image_picker_web.dart'; // Apenas para Web
import 'package:image_picker/image_picker.dart'; // Apenas para Mobile

class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Seleciona uma imagem e retorna os bytes (compatível com Web e Mobile)
  static Future<Uint8List?> pickImage() async {
    try {
      if (const bool.fromEnvironment('dart.library.html')) {
        // Para Web
        return await ImagePickerWeb.getImageAsBytes();
      } else {
        // Para Mobile
        final picker = ImagePicker();
        final XFile? image =
            await picker.pickImage(source: ImageSource.gallery);
        if (image == null) return null;
        return await image.readAsBytes();
      }
    } catch (e) {
      print("Erro ao selecionar imagem: $e");
      return null;
    }
  }

  /// Faz upload da imagem para Firebase Storage e retorna a URL
  static Future<String?> uploadProfileImage(
      String userId, Uint8List imageBytes) async {
    try {
      final ref = _storage.ref().child('profile_pictures/$userId.jpg');
      await ref.putData(imageBytes);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Erro ao enviar imagem: $e");
      return null;
    }
  }
}
