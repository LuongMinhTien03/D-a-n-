import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doan/login/login.dart';
import 'package:doan/main/waiting%20page/setting_account/setting_account.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doan/domains/authentication_repository/entity/user_entity.dart';
import 'package:doan/domains/authentication_repository/profile_controller/profile_controller.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domains/authentication_repository/user_repository/user_responsitory.dart';
import '../../register/register.dart';
import 'help_page/helppage.dart';

final controller = Get.put(ProfileController());

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFF8F8F8), // Màu nền tổng thể của trang
        body: buildFutureBuilder(),
      ),
    );
  }

  FutureBuilder<Object?> buildFutureBuilder() {
    return FutureBuilder(
      future: controller.getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            UserEntity userEntity = snapshot.data as UserEntity;
            return PageHall(userEntity: userEntity); // Truyền UserEntity
          } else {
            return const Center(child: Text("Chưa đăng nhập"));
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.blue), // Đảm bảo màu xanh
            ),
          );
        }
      },
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false; // Luôn trả về false để không nhận focus
}

class PageHall extends StatefulWidget {
  final UserEntity userEntity;

  const PageHall({super.key, required this.userEntity});

  @override
  State<PageHall> createState() => _PageHallState();
}

class _PageHallState extends State<PageHall> {
  final userRepo = Get.put(UserRepository());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: customLogic(),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Container(
            margin:
                const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _avatarUser(context, widget.userEntity),
                _myClass(context, widget.userEntity),
              ],
            ),
          ),
        ),
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

Widget _avatarUser(BuildContext context, UserEntity userEntity) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GestureDetector(
        onTap: () {
          // Mở Bottom Sheet với hiệu ứng xổ xuống
          showModalBottomSheet(
            backgroundColor: Colors.white,
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 400), // Hiệu ứng 400ms
                curve: Curves.easeOut, // Chọn curve mượt mà
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40, // Độ rộng của thanh
                        height: 5, // Chiều cao của thanh
                        decoration: BoxDecoration(
                          color: Colors.blueAccent, // Màu sắc của thanh
                          borderRadius:
                              BorderRadius.circular(12), // Bo tròn hai đầu
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[100]!, Colors.white],
                            // Thêm xám nhạt để tạo độ phản chiếu
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              // Hiệu ứng bóng nhẹ
                              blurRadius: 4,
                              // Độ mờ của bóng
                              offset: Offset(0, 2), // Vị trí bóng
                            ),
                          ],
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.4),
                            width: 0.2,
                          )),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, color: Colors.blue),
                        ),
                        title: Text(
                          userEntity.name ?? 'Tên tài khoản',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[600],
                          ),
                        ),
                        subtitle: const Text("Giáo viên"),
                        trailing:
                            const Icon(Icons.check_circle, color: Colors.blue),
                        onTap: () {
                          Navigator.pop(context); // Đóng Bottom Sheet
                        },
                      ),
                    ),
                    SizedBox(height: 5),
                    Divider(),
                    // Đăng xuất tài khoản
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[50],
                        child: Icon(
                          Icons.logout,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        'Đăng xuất tài khoản',
                        style: TextStyle(color: Colors.black87),
                      ),
                      onTap: () async {
                        try {
                          // Đăng xuất khỏi Firebase
                          await FirebaseAuth.instance.signOut();

                          // Đăng xuất khỏi Google (nếu đang sử dụng Google Sign-In)
                          await GoogleSignIn().signOut();

                          // Thay thế màn hình hiện tại bằng màn hình đăng nhập hoặc trang chủ
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    LoginPage()), // Thay LoginPage() bằng trang của bạn
                          );

                          print("Đăng xuất thành công");
                        } catch (e) {
                          print("Lỗi khi đăng xuất: $e");
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Container(
          width: 45, // Đặt kích thước rộng bằng với đường kính của CircleAvatar
          height: 45, // Đặt kích thước cao bằng với đường kính của CircleAvatar
          decoration: BoxDecoration(
            shape: BoxShape.circle, // Định dạng hình tròn
            border: Border.all(
              color: Colors.blue, // Màu viền
              width: 0.5, // Độ dày viền
            ),
          ),
          child: CircleAvatar(
            backgroundColor: Colors.blue[50], // Màu nền của avatar
            child: Icon(
              Icons.person, // Biểu tượng người dùng
              size: 35, // Kích thước của biểu tượng
              color: Colors.blue, // Màu của biểu tượng
            ),
          ),
        ),
      ),
      const SizedBox(height: 10), // Khoảng cách giữa avatar và chữ
      Text(
        'Xin chào',
        style: TextStyle(
          fontSize: 18, // Cỡ chữ
          color: Colors.black54,
          fontWeight: FontWeight.w500, // Độ đậm của chữ
        ),
      ),
      Text(
        userEntity.name ?? 'Tên tài khoản',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black.withOpacity(0.8),
          fontSize: 24,
        ),
      ),
    ],
  );
}

Widget _myClass(BuildContext context, UserEntity userEntity) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 10),
      Divider(color: Colors.blue),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: const Text(
              'Lớp của bạn',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.blue,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            // Thêm khoảng cách bên trái cho icon
            child: Icon(
              Icons.school, // Biểu tượng lớp học
              color: Colors.lightBlue,
              size: 24,
            ),
          ),
        ],
      ),
      Divider(color: Colors.blue),
      SizedBox(height: 10),
      // Dynamic Class List
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .collection('classes')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.blue));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi!'));
          }

          // List of classes
          final classList = snapshot.data?.docs ?? [];

          if (classList.isEmpty) {
            return Center(child: Text('Không có lớp nào.'));
          }

          return Column(
            children: classList.map((doc) {
              final className = doc['name'];
              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                leading: _iconWithBackground(Icons.class_, Colors.lightBlue),
                title: Text(className),
                trailing: _arrowIcon(),
                // Xóa lớp hiện tại
                onTap: () async {
                  TextStyle dialogTextStyle = TextStyle(
                    color: Colors.black.withOpacity(0.8),
                  );
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: Colors.white,
                        title: Text('Xóa lớp', style: dialogTextStyle),
                        content: Text('Bạn có chắc chắn muốn xóa lớp này?',
                            style: dialogTextStyle),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(
                                  context); // Close the dialog without deleting
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Hủy', style: dialogTextStyle),
                          ),
                          TextButton(
                            onPressed: () async {
                              // Delete the class from Firestore
                              await FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(FirebaseAuth.instance.currentUser?.uid)
                                  .collection('classes')
                                  .doc(doc
                                      .id) // Use the document ID to delete the specific class
                                  .delete();

                              Navigator.pop(
                                  context); // Close the dialog after deletion
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.lightBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Xóa',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            }).toList(),
          );
        },
      ),

      // Add Class Option
      ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 8),
        leading: _iconWithBackground(Icons.add, Colors.blueAccent),
        title: Text('Thêm lớp'),
        trailing: _arrowIcon(),
        onTap: () {
          // Tạo FocusNode để theo dõi trạng thái focus
          TextEditingController classNameController = TextEditingController();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (
              context,
            ) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  top: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    Center(
                      child: Text(
                        "Tên lớp",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: classNameController,
                      decoration: InputDecoration(
                        labelText: "Nhập tên lớp của bạn",
                        // Viền mặc định khi chưa focus
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                          // Viền màu xám khi chưa focus
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 2),
                          // Viền màu xanh khi focus
                          borderRadius: BorderRadius.circular(15),
                        ),

                        // Màu label khi chưa focus (màu xám)
                        labelStyle: TextStyle(
                          color: Colors.grey, // Khi không focus, màu chữ là xám
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          String className = classNameController.text.trim();
                          if (className.isNotEmpty) {
                            Navigator.pop(context);
                            await userRepo.addClassToFirestore(className);
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: Text(
                          "Tạo lớp",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      SizedBox(height: 20),
      Text(
        'Tài khoản',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black.withOpacity(0.8),
        ),
      ),
      ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 8),
        leading: _iconWithBackground(Icons.settings, Colors.lightGreen),
        title: Text('Cài đặt tài khoản'),
        trailing: _arrowIcon(),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InfoUserPage(
                  userEntity: userEntity), // Sử dụng tham số truyền vào
            ),
          );
        },
      ),
      SizedBox(height: 20),
      ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 8),
        // Điều chỉnh khoảng cách
        title: Center(
          child: Text(
            'Trợ giúp',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.blue, // Màu xanh cho chữ
            ),
          ),
        ),
        onTap: () => showHelpPage(context),
      ),
    ],
  );
}

Widget _iconWithBackground(IconData icon, Color backgroundColor) {
  return Container(
    padding: EdgeInsets.all(10), // Adjusted padding to keep the icon centered
    decoration: BoxDecoration(
      gradient: LinearGradient(
        // Soft gradient with bright highlights
        colors: [
          backgroundColor,
          backgroundColor,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          // Stronger shadow to create a more pronounced 3D look
          color: Colors.blue.withOpacity(0.2),
          offset: Offset(0, 1),
          blurRadius: 2,
        ),
      ],
      borderRadius:
          BorderRadius.circular(40), // Rounded corners for a polished look
    ),
    child: Icon(
      icon,
      color: Colors.white,
      size: 24, // Keeping the icon size the same
    ),
  );
}

Widget _arrowIcon() {
  return Icon(
    Icons.arrow_forward_ios_rounded,
    size: 18, // Keeping the arrow size same
    color: Colors.black54,
  );
}

Future<void> signOut() async {}

void showHelpPage(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => HelpPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final opacity = Tween<double>(begin: 0, end: 1).animate(animation);
        return FadeTransition(opacity: opacity, child: child);
      },
    ),
  );
}
