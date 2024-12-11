import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../entity/user_entity.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  //  store user in FireStore
  Future<void> createUser(UserEntity user, BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser; // Lấy thông tin người dùng hiện tại

    if (currentUser != null) {
      final uid = currentUser.uid; // Lấy UID của người dùng từ FirebaseAuth

      // Lưu vào Firestore với UID làm Document ID
      await _db.collection("Users").doc(uid).set(user.toJson()).whenComplete(() {
        print("Người dùng được tạo thành công với UID: $uid");
      }).catchError((error) {
        print("Lỗi khi tạo người dùng: $error");
      });
    } else {
      print("Người dùng chưa đăng nhập!");
    }
  }

  // fetch all users or user details
  Future<UserEntity> getUserDetails(String email) async{
      final SnapshotController = await _db.collection("Users").where("Email",
          isEqualTo: email).get();
      final userData = SnapshotController.docs.map((e)
      =>UserEntity.fromSnapshot(e)).single;
      return userData;
  }

  Future<List<UserEntity>> allUser() async{
    final SnapshotController = await _db.collection("Users").get();
    final userData = SnapshotController.docs.map((e)
    =>UserEntity.fromSnapshot(e)).toList();
    return userData;
  }
  Future<void> updateUserRecord(UserEntity user) async {
    await _db.collection('Users').doc(user.id).update(user.toJson());
  }
  Future<void> addClassToFirestore(String className) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;
      final classesRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('classes');

      await classesRef.add({
        'name': className,
        'created_at': Timestamp.now(),
      });
    }
  }
}
