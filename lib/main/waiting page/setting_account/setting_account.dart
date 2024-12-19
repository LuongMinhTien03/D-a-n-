import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doan/main/waiting%20page/setting_account/setting_profile/setting_profile.dart';
import 'package:doan/main/waiting%20page/waiting_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

Widget _buildCurvedHeader() {
  return ClipPath(
    clipper: CurvedClipper(),
    child: Container(
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent.shade700, Colors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ),
  );
}

class CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height); // Góc trái dưới vuông góc
    path.lineTo(size.width - 50, size.height); // Di chuyển đến gần góc phải
    path.quadraticBezierTo(
      size.width, size.height, // Điểm điều khiển cho đường cong
      size.width, size.height - 50, // Điểm cuối của bo tròn
    );
    path.lineTo(size.width, 0); // Đường thẳng lên đến đỉnh
    path.close(); // Đóng đường path
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
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

        // Xóa dữ liệu người dùng trong Firestore, bao gồm cả subcollection
        final firestore = FirebaseFirestore.instance;
        final userDocRef = firestore.collection('Users').doc(user.uid);

        // Lấy tất cả tài liệu trong subcollection 'classes'
        final classesSnapshot = await userDocRef.collection('classes').get();
        for (var doc in classesSnapshot.docs) {
          await doc.reference.delete(); // Xóa từng tài liệu trong 'classes'
        }

        // Sau khi xóa các tài liệu con, xóa tài liệu chính của người dùng
        await userDocRef.delete();

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
      } on FirebaseAuthException catch (_) {
        // Nếu có lỗi xác thực, kiểm tra mã lỗi
        String? error;
        String? title;
        ContentType contentType;

        title = "Lỗi";
        error = "Vui lòng nhập đúng mật khẩu";
        contentType = ContentType.failure;

        // Hiển thị thông báo lỗi
        _showErrorSnackBar(title, error, contentType);
      } catch (e) {
        // Lỗi khác
        _showErrorSnackBar(
            "Lỗi",
            "Đã xảy ra sự cố trong quá trình xóa tài khoản.",
            ContentType.failure);
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
      backgroundColor: colorBackgr,
      body: Stack(
        children: [
          // _buildCurvedHeader() được đặt đầu tiên để phủ lên AppBar
          _buildCurvedHeader(),
          Scaffold(
            backgroundColor: Colors.transparent, // Làm nền Scaffold trong suốt
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              // AppBar trong suốt
              elevation: 0,
              // Bỏ bóng
              centerTitle: true,
              title: Text(
                'Cài đặt tài khoản',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              leading: IconButton(
                onPressed: () async {
                  final result = await Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainPage(),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      userEntity = result;
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
                margin: const EdgeInsets.symmetric(horizontal: 20)
                    .copyWith(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 180),
                    // Khoảng trống để không trùng với _buildCurvedHeader()
                    _buildForm(widget.userEntity),
                    SizedBox(height: 20),
                    _editProfile(),
                    SizedBox(height: 12),
                    _deleteUser(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(UserEntity userEntity) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // Avatar
          SizedBox(height: 10),
          _avatar(),
          SizedBox(height: 5),
          _settingAccount(userEntity),
        ],
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

  Widget _editProfile() {
    final user = FirebaseAuth.instance.currentUser;
    bool isGoogleLogin =
        user?.providerData.any((info) => info.providerId == 'google.com') ??
            false;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SettingProfile(
                  userEntity: widget.userEntity), // Truyền đối tượng userEntity
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // Màu nền của nút
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)), // Hình dáng bo tròn
          elevation: 0.0, // Độ bóng đổ
          shadowColor: Colors.black.withOpacity(0.5),
          // Màu sắc bóng đổ
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color>(
            (states) {
              return Colors.lightBlueAccent
                  .withOpacity(0.1); // Màu hiệu ứng nhấn
            },
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
          child: Text(
            isGoogleLogin ? "Xem thông tin" : "Sửa thông tin",
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.lightBlue,
            ),
          ),
        ),
      ),
    );
  }

  Widget _deleteUser() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        onPressed: () {
          _showDeleteAccountDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // Màu nền của nút
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)), // Hình dáng bo tròn
          elevation: 0.0, // Độ bóng đổ
          shadowColor: Colors.black.withOpacity(0.5),
          // Màu sắc bóng đổ
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color>(
            (states) {
              return Colors.red.withOpacity(0.1); // Màu hiệu ứng nhấn
            },
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
          child: Text(
            "Xóa tài khoản",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }

  //--------------------------------
  Future<void> _deleteAccount() async {
    final user =
        FirebaseAuth.instance.currentUser; // Lấy thông tin user hiện tại
    if (user == null) return;

    try {
      // Xóa dữ liệu người dùng trong Firestore, bao gồm cả subcollection
      final firestore = FirebaseFirestore.instance;
      final userDocRef = firestore.collection('Users').doc(user.uid);

      // Lấy tất cả tài liệu trong subcollection 'classes'
      final classesSnapshot = await userDocRef.collection('classes').get();
      for (var doc in classesSnapshot.docs) {
        await doc.reference.delete(); // Xóa từng tài liệu trong 'classes'
      }

      // Sau khi xóa các tài liệu con, xóa tài liệu chính của người dùng
      await userDocRef.delete();

      // Xóa tài khoản người dùng khỏi Firebase Authentication
      await user.delete();

      // Đăng xuất khỏi Google Sign-In để xóa session
      await GoogleSignIn().signOut();

      if (mounted) {
        // Điều hướng đến màn hình Login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }

      // Hiển thị thông báo thành công
      _showErrorSnackBar("Thành công", "Tài khoản và dữ liệu đã bị xóa.",
          ContentType.success);
    } catch (e) {
      print("Lỗi khi xoá tài khoản hoặc dữ liệu Firestore: $e");
    }
  }

  void _showDeleteAccountDialog() {
    final user = FirebaseAuth.instance.currentUser;

    // Kiểm tra người dùng có đang đăng nhập bằng Google hay không
    bool isGoogleUser = user?.providerData.any(
          (provider) => provider.providerId == "google.com",
        ) ??
        false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Bo góc dialog
          ),
          title: Text(
            'Xác nhận xóa tài khoản',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
          content: Text(
            isGoogleUser
                ? "Bạn có chắc muốn xoá tài khoản không?"
                : "Vui lòng xác minh mật khẩu để xoá tài khoản này.",
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.75),
                ),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                if (isGoogleUser) {
                  await _deleteAccount();
                } else {
                  Navigator.pop(context);
                  _showPasswordDialog(); // Hiển thị hộp thoại nhập mật khẩu
                }
              },
              child: Text(
                'Xoá',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
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
    return PopScope(
      canPop: customLogic(),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                userEntity.name ?? 'Default Name',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 5), // Khoảng cách giữa tên và biểu tượng
              Icon(
                Icons.verified, // Biểu tượng giống dấu tích trong hình
                color: Colors.amber, // Màu vàng cho biểu tượng
                size: 22,
              ),
            ],
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

bool customLogic() {
  {
    // your logic
    return false;
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false; // Luôn trả về false để không nhận focus
}
