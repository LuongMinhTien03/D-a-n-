import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doan/main/waiting%20page/setting_account/setting_profile/setting_profile.dart';
import 'package:doan/main/waiting%20page/waiting_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../Images/stringimage.dart';
import '../../../domains/authentication_repository/entity/user_entity.dart';
import '../../../login/login.dart';

// Tạo màn hình mới để chứa InfoUser
class InfoUserPage extends StatefulWidget {
  final UserEntity userEntity;

  const InfoUserPage({super.key, required this.userEntity});

  @override
  State<StatefulWidget> createState() => _Pagesetting();
}

class _Pagesetting extends State<InfoUserPage> {
  final TextEditingController _passwordController = TextEditingController();

  // Thêm một biến để theo dõi việc cập nhật dữ liệu
  late UserEntity userEntity;

  @override
  void initState() {
    super.initState();
    userEntity = widget.userEntity; // Giữ dữ liệu ban đầu
  }

  // Hàm xác thực và xóa tài khoản
  Future<void> _reauthenticateAndDelete() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _passwordController.text, // Lấy mật khẩu người dùng nhập
        );

        // Xác thực lại tài khoản
        await user.reauthenticateWithCredential(credential);

        // Xóa dữ liệu người dùng trong Firestore
        final firestore = FirebaseFirestore.instance;
        await firestore.collection('Users').doc(widget.userEntity.id).delete();

        // Xóa tài khoản trên Authentication
        await user.delete();

        // Chuyển đến trang đăng nhập sau khi xóa tài khoản thành công
        if (mounted) {
          // Ensure the widget is still mounted before navigation
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }

        // Hiển thị thông báo thành công
        _showErrorSnackBar("Thành công", "Tài khoản và dữ liệu đã bị xóa.",
            ContentType.success);
      } catch (e) {
        // Nếu có lỗi, xác định lỗi và hiển thị thông báo tương ứng
        String? error;
        String? title;
        ContentType contentType;

        if (e
            .toString()
            .contains('We have blocked all requests from this device')) {
          title = "Cảnh báo";
          error = "Vui lòng thử lại sau";
          contentType = ContentType.failure;
        } else {
          title = "Ôi chao!";
          error = "Mật khẩu sai.";
          contentType = ContentType.warning;
        }

        // Hiển thị thông báo lỗi
        _showErrorSnackBar(title, error, contentType);
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
      duration: Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBackgr, // Màu nền tổng thể của trang
      appBar: AppBar(
        backgroundColor: colorBackgr,
        // Màu nền tổng thể của trang
        centerTitle: true,
        title: Text(
          'Cài đặt tài khoản',
          style: TextStyle(
            color: Colors.black.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        scrolledUnderElevation: 0.0,
        leading: IconButton(
          onPressed: () async {
            final result = await Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainPage(),
              ),
            );

            // Update userEntity if needed
            if (result != null) {
              setState(() {
                userEntity = result; // Assign the result to userEntity
              });
            }
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 22,
            color: Colors.black54,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _avatar(),
              _settingAccount(widget.userEntity),
              _settingLast(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatar() {
    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.bottomRight, // Đặt icon ở dưới bên phải
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // Đảm bảo viền bo tròn hoàn toàn
                    gradient: LinearGradient(
                      // Gradient trắng-xanh
                      colors: [
                        Colors.blueAccent,
                        Colors.lightBlueAccent.shade100
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: EdgeInsets.all(4.0), // Độ dày của viền gradient
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white, // Màu nền trắng cho viền trong
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        avatarUser,
                        fit: BoxFit.cover, // Căn chỉnh ảnh
                        width: 150, // Kích thước avatar
                        height: 150,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _settingLast() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingProfile(
                    userEntity:
                        widget.userEntity), // Truyền đối tượng userEntity
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Màu nền của nút
            shape: const StadiumBorder(), // Hình dáng bo tròn
            elevation: 1, // Độ bóng đổ
            shadowColor: Colors.black.withOpacity(0.5),
            // Màu sắc bóng đổ
          ).copyWith(
            backgroundColor:
                WidgetStateProperty.all(Colors.blue), // Nền khi nút được nhấn
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
            child: const Text(
              "Sửa thông tin",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        Divider(
          color: Colors.black45,
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            // Hiển thị hộp thoại nhập mật khẩu
            _showPasswordDialog();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.remove_circle_outline_rounded, // Biểu tượng xóa
                color: Colors.red,
                size: 25,
              ),
              SizedBox(width: 8),
              const Text(
                "Xóa tài khoản",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Hàm hiển thị hộp thoại nhập mật khẩu
  void _showPasswordDialog() {
    FocusNode focusNode =
        FocusNode(); // Tạo FocusNode để theo dõi trạng thái focus

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Bo góc cho dialog
          ),
          title: Text(
            'Yêu cầu xác thực mật khẩu',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black.withOpacity(0.8), // Đổi màu tiêu đề thành đen
            ),
          ),
          backgroundColor: Colors.white,
          content: StatefulBuilder(
            builder: (context, setState) {
              return TextField(
                controller: _passwordController,
                obscureText: true,
                focusNode: focusNode,
                // Gán FocusNode vào TextField
                onChanged: (value) {
                  setState(() {}); // Gọi setState để cập nhật giao diện
                },
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.lightBlue),
                  // Màu xanh cho hintText
                  labelText: 'Mật khẩu hiện tại',
                  labelStyle: TextStyle(
                    color: focusNode.hasFocus
                        ? Colors.lightBlue // Khi focus, màu chữ là đỏ
                        : Colors.grey.withOpacity(
                            0.8), // Khi không focus, màu chữ là xám
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    // Bo góc cho TextField
                    borderSide: BorderSide(color: Colors.grey), // Viền xám nhẹ
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Colors.lightBlue), // Màu viền khi focus là xanh
                  ),
                  prefixIcon: Icon(
                    Icons.lock,
                    color: focusNode.hasFocus ? Colors.lightBlue : Colors.grey,
                  ), // Thay đổi màu dựa trên trạng thái focus
                ),
              );
            },
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[200],
                // Màu nền xám nhẹ cho nút Hủy
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                _passwordController.clear();
                Navigator.pop(context);
              },
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: Colors.black
                      .withOpacity(0.75), // Đổi màu tiêu đề thành đen
                ), // Màu chữ đen cho nút Hủy
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                // Màu nền xanh cho nút Xác nhận
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                _reauthenticateAndDelete();
                _passwordController.clear();
                Navigator.pop(context);
              },
              child: Text(
                'Xác nhận',
                style: TextStyle(
                    color: Colors.white), // Màu chữ trắng cho nút Xác nhận
              ),
            ),
          ],
        );
      },
    ).then((_) {
      focusNode
          .dispose(); // Hủy FocusNode sau khi đóng dialog để tránh rò rỉ tài nguyên
    });
  }
}

Widget _settingAccount(UserEntity userEntity) {
  return Center(child: InfoUser(userEntity: userEntity));
}

class InfoUser extends StatelessWidget {
  final UserEntity userEntity;

  const InfoUser({super.key, required this.userEntity});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Trả về false để vô hiệu hóa nút back của thiết bị
        return false;
      },
      child: Column(
        children: [
          Text(
            userEntity.name ?? 'Default Name',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            userEntity.email ?? 'Default Email',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false; // Luôn trả về false để không nhận focus
}
