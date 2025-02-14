import 'dart:io';
import 'package:avl/models/user_Local.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class UserServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final UserLocal _userLocal = UserLocal();

  CollectionReference get _collectionRef => _firestore.collection('users');
  DocumentReference get _docRef => _collectionRef.doc(_userLocal.id!);

  /// Cadastro de usuário e armazenamento de dados no Firestore
  Future<bool> signUp(String userName, String email, String password, String phone, [String ? profileImageUrl]) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        _userLocal.id = user.uid;
        _userLocal.userName = userName;
        _userLocal.email = user.email;
        _userLocal.phone = phone;
        _userLocal.passaword = password;

        await saveData();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("Erro no cadastro: ${e.message}");
    }
    return false;
  }

  /// Login do usuário
  Future<bool> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint("Erro no login: ${e.message}");
    }
    return false;
  }

  /// Retorna os dados do usuário logado
  Future<Map<String, dynamic>?> getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    }
    return null;
  }

  /// Salva os dados do usuário no Firestore
  Future<void> saveData() async {
    try {
      await _docRef.set(_userLocal.toJson());
    } catch (e) {
      debugPrint("Erro ao salvar dados no Firestore: $e");
    }
  }

  /// Faz upload da imagem de perfil para Firebase Storage e retorna a URL
  Future<String?> uploadProfileImage(File image) async {
    try {
      final ref = _storage.ref().child('users/${_auth.currentUser!.uid}.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("Erro ao fazer upload da imagem: $e");
      return null;
    }
  }

  /// Atualiza a URL da imagem no Firestore
  Future<void> updateProfileImage(String imageUrl) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      'profileImageUrl': imageUrl,
    });
  }
}
