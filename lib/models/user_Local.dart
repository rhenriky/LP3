import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:shared_preferences/shared_preferences.dart';

UserLocal _userLocal = UserLocal();

Future<void> saveData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user', _userLocal.toJson().toString());
}

class UserLocal {
  String? id;
  String? userName;
  String? passaword;
  String? email;
  String? phone;

  UserLocal({this.id, this.userName, this.passaword, this.email, this.phone});

  //método para converter o objeto em um mapa
  Map<String, dynamic> toJson() {
    return {
      id = 'id': id,
      userName = 'userName': userName,
      passaword = 'passaword': passaword,
      email = 'email': email,
      'phone': phone,
    };
  }
}
