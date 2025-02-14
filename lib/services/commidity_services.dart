import 'dart:io';
import 'package:avl/models/commodiity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CommodityServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Faz upload da imagem para Firebase Storage e retorna a URL
  Future<String?> _uploadImagem(File image) async {
    try {
      final ref = _storage
          .ref()
          .child('commodities/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      print("❌ Erro ao fazer upload da imagem: $e");
      return null;
    }
  }

  /// Adiciona um novo commodity ao Firestore, com upload de imagem opcional
  Future<void> addCommodity(Commodiity commodity, {File? image}) async {
    try {
      String? imageUrl;

      if (image != null) {
        imageUrl = await _uploadImagem(image);
      }

      // Adiciona a URL da imagem ao objeto, se existir
      final data = commodity.toJson();
      if (imageUrl != null) {
        data['imageUrl'] = imageUrl;
      }

      await _firestore.collection('commodities').add(data);
      print("✅ Commodity adicionado com sucesso!");
    } catch (e) {
      print("❌ Erro ao adicionar commodity: $e");
    }
  }

  /// Obtém os commodities do Firestore em tempo real
  Stream<QuerySnapshot> getCommodities() {
    return _firestore.collection('commodities').snapshots();
  }
}
