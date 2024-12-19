import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Images/stringimage.dart';
import '../../../../domains/authentication_repository/entity/user_entity.dart';
import '../../../../domains/authentication_repository/profile_controller/profile_controller.dart';
import '../setting_account.dart';
import 'package:intl/intl.dart'; // Để định dạng ngày

// Tạo màn hình mới để chứa InfoUser
class SettingProfile extends StatefulWidget {
  final UserEntity userEntity;

  const SettingProfile({super.key, required this.userEntity});

  @override
  State<StatefulWidget> createState() => _Pageinfo();
}

final controller = Get.put(ProfileController());

class _Pageinfo extends State<SettingProfile> {
  late UserEntity updatedUserEntity;

  // Khai báo các TextEditingController
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    updatedUserEntity = widget.userEntity;
    // Khởi tạo giá trị cho các controller
    name.text = updatedUserEntity.name!;
    email.text = updatedUserEntity.email!;
    password.text = updatedUserEntity.password!;
    _getUserCreationDate();
  }

  // Lấy ngày tạo tài khoản từ Firebase
  void _getUserCreationDate() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && user.metadata.creationTime != null) {
      // Chuyển đổi ngày tạo tài khoản thành định dạng dd/MM/yyyy
      String formattedDate =
          DateFormat('dd/MM/yyyy').format(user.metadata.creationTime!);
      // Cập nhật TextFormField với ngày tạo
      dateController.text = formattedDate;
    }
  }

  @override
  void dispose() {
    // Giải phóng tài nguyên khi widget bị huỷ
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> updateUserPassword(String newPassword) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.updatePassword(newPassword);
        _showErrorSnackBar("Thành công",
            "Mật khẩu đã được thay đổi thành công.", ContentType.success);
      } else {
        _showErrorSnackBar(
            "Lỗi", "Không tìm thấy người dùng hiện tại.", ContentType.failure);
      }
    } catch (e) {
      if (e.toString().contains("requires-recent-login")) {
        _showErrorSnackBar(
            "Cảnh báo",
            "Bạn cần đăng nhập lại trước khi thay đổi mật khẩu.",
            ContentType.warning);
      } else {
        _showErrorSnackBar(
            "Lỗi", "Lỗi khi thay đổi mật khẩu: $e", ContentType.failure);
      }
    }
  }

  void _showErrorSnackBar(
      String title, String message, ContentType contentType) {
    final snackBar = SnackBar(
      width: double.infinity,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message, // Display the dynamic error message
        contentType: contentType,
      ),
      duration: Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  Future<void> reAuthenticateUser(String email, String password) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }
    } catch (e) {
      // print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    bool isGoogleSignIn =
        user?.providerData.any((info) => info.providerId == 'google.com') ??
            false;
    return PopScope(
      canPop: customLogic(),
      child: Scaffold(
        backgroundColor: colorBackgr,
        appBar: AppBar(
          backgroundColor: colorBackgr,
          centerTitle: true,
          title: Text(
            'Thông tin tài khoản',
            style: TextStyle(
                color: Colors.black.withOpacity(0.8),
                fontWeight: FontWeight.w500),
          ),
          scrolledUnderElevation: 0.0,
          leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      InfoUserPage(userEntity: updatedUserEntity),
                ),
              );
            },
            icon: const Icon(Icons.close, size: 25, color: Colors.black54),
          ),
        ),
        resizeToAvoidBottomInset: true,
        // Bật tính năng tự động điều chỉnh khi bàn phím xuất hiện
        body: SingleChildScrollView(
          // Bọc nội dung trong SingleChildScrollView để tránh tràn
          child: FutureBuilder(
            future: controller.getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return Form(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _avatar(),
                          SizedBox(height: 15),
                          TextFormField(
                            controller: email,
                            focusNode: AlwaysDisabledFocusNode(),
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 14),
                              labelText: "Email",
                              labelStyle: TextStyle(color: Colors.black87),
                              alignLabelWithHint: true,
                              prefixIcon: Icon(Icons.email_outlined,
                                  color: Colors.black.withOpacity(0.75)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide(color: Colors.black87),
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                            ),
                          ),
                          SizedBox(height: 15),
                          TextFormField(
                            controller: name,
                            focusNode: isGoogleSignIn
                                ? AlwaysDisabledFocusNode()
                                : null,
                            // Apply the focusNode based on the login status
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 14),
                              labelText: "Họ tên giáo viên",
                              labelStyle: TextStyle(color: Colors.black87),
                              alignLabelWithHint: true,
                              prefixIcon: Icon(Icons.person_outline_rounded,
                                  color: Colors.black.withOpacity(0.75)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide(color: Colors.black87),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide:
                                    BorderSide(color: Colors.black, width: 1.5),
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                            ),
                          ),
                          SizedBox(height: 15),
                          if (!isGoogleSignIn)
                            TextFormField(
                              controller: password,
                              obscureText: true,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 14),
                                labelText: "Mật khẩu",
                                labelStyle: TextStyle(color: Colors.black87),
                                alignLabelWithHint: true,
                                prefixIcon: Icon(
                                  Icons.fingerprint,
                                  color: Colors.black87,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: BorderSide(color: Colors.black87),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 1.5),
                                ),
                                filled: true,
                                fillColor: Colors.grey[200],
                              ),
                            ),
                          if (isGoogleSignIn)
                            TextFormField(
                              controller: dateController,
                              focusNode: AlwaysDisabledFocusNode(),
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 14),
                                labelText: "Giới tính",
                                labelStyle: TextStyle(color: Colors.black87),
                                alignLabelWithHint: true,
                                prefixIcon: Icon(Icons.date_range_rounded,
                                    color: Colors.black.withOpacity(0.75)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: BorderSide(color: Colors.black87),
                                ),
                                filled: true,
                                fillColor: Colors.grey[200],
                              ),
                            ),
                          SizedBox(height: 10),
                          if (isGoogleSignIn)
                            TextFormField(
                              controller: dateController,
                              focusNode: AlwaysDisabledFocusNode(),
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 14),
                                labelText: "Ngày tạo",
                                labelStyle: TextStyle(color: Colors.black87),
                                alignLabelWithHint: true,
                                prefixIcon: Icon(Icons.date_range_rounded,
                                    color: Colors.black.withOpacity(0.75)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: BorderSide(color: Colors.black87),
                                ),
                                filled: true,
                                fillColor: Colors.grey[200],
                              ),
                            ),
                          SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: isGoogleSignIn
                                ? null
                                : ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        final updatedUser = UserEntity(
                                          id: updatedUserEntity.id,
                                          email: email.text.trim(),
                                          password: password.text.trim(),
                                          name: name.text.trim(),
                                        );

                                        if (updatedUserEntity.name !=
                                                name.text.trim() ||
                                            updatedUserEntity.email !=
                                                password.text.trim()) {
                                          await controller
                                              .updateUserRecord(updatedUser);
                                        }

                                        await reAuthenticateUser(
                                            email.text.trim(), password.text);

                                        if (updatedUserEntity.password !=
                                            password.text.trim()) {
                                          await updateUserPassword(
                                              password.text.trim());
                                        }

                                        // Chỉ gọi setState một lần khi cần thay đổi trạng thái
                                        setState(() {
                                          updatedUserEntity = updatedUser;
                                        });

                                        _showErrorSnackBar(
                                            "Thành công",
                                            "Đã cập nhật thông tin.",
                                            ContentType.success);
                                      } catch (e) {
                                        _showErrorSnackBar(
                                            "Lỗi",
                                            "Đã xảy ra lỗi: $e",
                                            ContentType.failure);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      elevation: 3,
                                      shadowColor:
                                          Colors.lightBlue.withOpacity(0.4),
                                      backgroundColor: Colors.blue,
                                    ),
                                    child: const Text(
                                      'Cập nhật',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const Center(child: Text("Chưa đăng nhập"));
                }
              } else {
                return SizedBox(
                  height: MediaQuery.of(context).size.height /
                      1.3, // Đảm bảo chiều cao đầy đủ
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  bool customLogic() {
    {
      // your logic
      return false;
    }
  }
}

Widget _avatar() {
  return Center(
    child: Column(
      children: [
        SizedBox(height: 10),
        SizedBox(
          width: 130,
          height: 130,
          child: Stack(
            alignment: Alignment.bottomRight, // Đặt icon ở dưới bên phải
            children: [
              InkWell(
                onTap: () {
                  // Thêm logic thay đổi ảnh đại diện tại đây
                },
                borderRadius: BorderRadius.circular(100),
                // Đảm bảo bo tròn cho hiệu ứng
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.lightBlue.shade100,
                        Colors.lightBlue.shade400
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 1,
                        offset: Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 5),
                    shape: BoxShape.circle, // Bo tròn hoàn toàn
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipOval(
                        child: Image.asset(
                          avatarUser, // Đường dẫn ảnh đại diện
                          fit: BoxFit.cover, // Tự động căn chỉnh hình ảnh
                          width: 140,
                          height: 140,
                        ),
                      ),
                      Positioned(
                        bottom: 6,
                        right: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.lightBlue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.lightBlue,
                              width: 1.5,
                              strokeAlign: BorderSide.strokeAlignOutside,
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundColor: Color(0xFFF9F9F9),
                            radius: 17,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.lightBlue,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
      ],
    ),
  );
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false; // Luôn trả về false để không nhận focus
}
