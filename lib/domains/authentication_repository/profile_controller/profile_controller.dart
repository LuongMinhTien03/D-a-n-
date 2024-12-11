import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:doan/domains/authentication_repository/user_repository/user_responsitory.dart';

import '../entity/user_entity.dart';

class ProfileController extends GetxController {
  static ProfileController get instance => Get.find();

  final _authRepo = Get.put(AuthenticationRepository2());
  final _userRepo = Get.put(UserRepository());
  getUserData() async {
    final email = _authRepo.firebaseUser.value?.email;
    if (email != null) {
      return await _userRepo.getUserDetails(email);
    } else {
      // Show snackbar when user is not logged in
      Get.snackbar('Error', 'Login to continue');
      return null; // Return null if the user is not logged in
    }
  }
  updateUserRecord(UserEntity user) async{
    await _userRepo.updateUserRecord(user);
  }
  refreshUserData() async {
    final email = _authRepo.firebaseUser.value?.email;
    if (email != null) {
      return await _userRepo.getUserDetails(email);
    }
    return null; // Return null if the user is not logged in
  }
}
class AuthenticationRepository2 extends GetxController {
  static AuthenticationRepository2 get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Rx<User?> firebaseUser = Rx<User?>(_auth.currentUser);

  @override
  void onReady() {
    super.onReady(); // Gọi super trước khi thực hiện các thao tác khác
    firebaseUser.bindStream(_auth.userChanges());
  }

}
