import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doan/domains/authentication_repository/authentication_repository.dart';
import 'package:doan/domains/authentication_repository/entity/user_entity.dart';
import 'package:doan/domains/authentication_repository/user_repository/user_responsitory.dart';
import '../Images/stringimage.dart';
import '../login/login.dart';
import '../main/waiting page/waiting_page.dart';
import 'bloc/register_cubit.dart';
import 'package:get/get.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

final ScrollController _scrollController = ScrollController();
final _formKey = GlobalKey<FormState>();
final _confirmPassTextController = TextEditingController();
var _autoValidateMode = AutovalidateMode.disabled;
final userRepo = Get.put(UserRepository());

class _RegisterState extends State<Register> {
  @override
  void initState() {
    super.initState();
    // Tự động cuộn sau 1 giây
    Future.delayed(const Duration(milliseconds: 1000), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
    _confirmPassTextController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        body: BlocProvider(
            create: (BuildContext context) {
              final authenticationRepository =
                  context.read<AuthenticationRepository>();
              return RegisterCubit(
                  authenticationRepository: authenticationRepository);
            },
            child: const RegisterView()),
      ),
    );
  }
}

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _emailTextController = TextEditingController();
  final _passTextController = TextEditingController();
  final _teacherTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterCubit, RegisterState>(
      listener: (context, state) async {
        if (state is RegisterEmailExists) {
          final snackBar = SnackBar(
            width: double.infinity,
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Ôi chao!',
              message: 'Email đã tồn tại!',
              contentType: ContentType.failure,
            ),
            duration: Duration(seconds: 2),
          );

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        } else if (state is RegisterFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        } else if (state is RegisterSuccess) {
          // Tách context thành biến cục bộ
          final user2 = UserEntity(
            email: _emailTextController.text.trim(),
            password: _passTextController.text.trim(),
            name: _teacherTextController.text.trim(),
          );

          Future<void> handleRegistration() async {
            try {
              await userRepo.createUser(user2, context); // Lưu dữ liệu lên
              // Chuyển hướng sau khi lưu thành công
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MainPage()),
              );
            } catch (_) {}
          }

          // Chờ hoàn thành đăng ký trước khi tiếp tục
          await handleRegistration();
        }
      },
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPageTitle(),
              _buildFormRegister(),
              _buildOrSplitDivider(),
              _buildSocialRegister(),
              _buildHaveAccount(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageTitle() {
    return Column(
      children: [
        SizedBox(
          child: Image.asset(
            backgroundRegister,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.symmetric(horizontal: 25)
              .copyWith(top: 10, bottom: 5),
          child: const Text(
            'Đăng ký',
            style: TextStyle(
              fontSize: 32,
              color: Colors.black87,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildFormRegister() {
    return Form(
      autovalidateMode: _autoValidateMode,
      key: _formKey,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 25,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUsernameField(),
            _buildPasswordField(),
            _buildConfirmPasswordField(),
            _buildRegisterButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildUsernameField() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Tạo tài khoản cho giáo viên',
              style: TextStyle(
                fontSize: 17,
                color: Colors.black54,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _hotenGV(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _logoVN(),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.only(top: 0), // Điều chỉnh giá
                  // trị này cho khoảng cách phù hợp
                  child: _emailtxt(),
                ),
              )
            ],
          ),
        ]);
  }

  Widget _hotenGV() {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      child: TextFormField(
        controller: _teacherTextController,
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return "Vui lòng nhập họ tên";
          }
          if (value.contains(RegExp(r'\d'))) {
            return "Họ tên không được chứa số";
          }
          if (value.contains(
              RegExp(r'[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:\' ",<>\./\?\\|`~]"))) {
            return "Họ tên không được chứa ký tự đặc biệt";
          }
          return null;
        },
        // Xử lý chuẩn hóa khi người dùng nhập
        onChanged: (value) {
          _teacherTextController.text =
              capitalizeWords(value); // Áp dụng hàm chuẩn hóa
          _teacherTextController.selection = TextSelection.fromPosition(
            TextPosition(offset: _teacherTextController.text.length),
          ); // Đặt con trỏ sau chữ vừa nhập
        },
        decoration: const InputDecoration(
          hintText: 'Nhập tên giáo viên...',
          contentPadding: EdgeInsets.symmetric(horizontal: 0),
          hintStyle: TextStyle(
            color: Colors.black26,
            fontFamily: 'Roboto',
            fontSize: 16,
          ),
          // Thiết lập viền khi "focus" (khi người dùng nhấn vào TextFormField)
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.lightBlue, width: 2)),
          border: UnderlineInputBorder(
              borderSide: BorderSide(
            color: Colors.grey,
            width: 2,
          )),
          fillColor: Colors.transparent,
          filled: true,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey, // Màu viền
              width: 1.5, // Độ dày viền khi không tương tác
            ),
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Widget _logoVN() {
    return Container(
      padding: const EdgeInsets.only(top: 25.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(),
                child: Image.asset(
                  iconGmail,
                  width: 26,
                  height: 26,
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                'Gmail',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          // Đường gạch chân (Underline)
          const Divider(
            color: Colors.grey,
            thickness: 1.5,
            height: 3,
          ),
        ],
      ),
    );
  }

  Widget _emailtxt() {
    return Container(
      margin: const EdgeInsets.only(top: 14.8),
      child: TextFormField(
        controller: _emailTextController,
        decoration: const InputDecoration(
          hintText: 'Nhập email...',
          contentPadding: EdgeInsets.symmetric(horizontal: 0),
          hintStyle: TextStyle(
            color: Colors.black26,
            fontFamily: 'Roboto',
            fontSize: 16,
          ),
          // Thiết lập viền khi "focus" (khi người dùng nhấn vào TextFormField)
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.lightBlue, width: 2)),
          border: UnderlineInputBorder(
              borderSide: BorderSide(
            color: Colors.grey,
            width: 2,
          )),
          fillColor: Colors.transparent,
          filled: true,
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red,
              width: 1.5,
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey, // Màu viền
              width: 1.5, // Độ dày viền khi không tương tác
            ),
          ),
        ),
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập email!';
          }
          final bool emailValid = RegExp(
                  r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+$")
              .hasMatch(value);
          if (!emailValid) {
            return 'Email không hợp lệ';
          }
          return null;
        },
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _passTextController,
            decoration: const InputDecoration(
              hintText: 'Nhập mật khẩu...',
              contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 12),
              // Thay đổi padding ở đây
              hintStyle: TextStyle(
                color: Colors.black26,
                fontFamily: 'Roboto',
                fontSize: 16,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey, // Màu viền
                  width: 1.5, // Độ dày viền khi không tương tác
                ),
              ),
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 1.5,
                ),
              ),
              // Thiết lập viền khi "focus" (khi người dùng nhấn vào TextFormField)
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlue, width: 2)),
              border: UnderlineInputBorder(
                  borderSide: BorderSide(
                color: Colors.grey,
                width: 2,
              )),
              fillColor: Colors.transparent,
              filled: true,
            ),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontFamily: 'Roboto',
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mật khẩu';
              }
              if (!RegExp(r'(?=.*?[A-Z])').hasMatch(value)) {
                return 'Mật khẩu chứa ít nhất một ký tự hoa';
              }
              if (!RegExp(r'(?=.*?[a-z])').hasMatch(value)) {
                return 'Mật khẩu chứa ít nhất một ký tự thường';
              }
              if (!RegExp(r'(?=.*?[0-9])').hasMatch(value)) {
                return 'Mật khẩu chứa ít nhất một chữ số';
              }
              if (!RegExp(r'(?=.*?[!@#$&*~.])').hasMatch(value)) {
                return 'Mật khẩu chứa ít nhất một ký tự đặc biệt';
              }
              if (value.length < 8) {
                return 'Mật khẩu phải dài ít nhất 8 ký tự';
              }
              return null;
            },
            obscureText: true,
          ),
        ]);
  }

  Widget _buildConfirmPasswordField() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _confirmPassTextController,
            decoration: const InputDecoration(
              hintText: 'Xác nhận mật khẩu...',
              contentPadding: EdgeInsets.symmetric(horizontal: 0),
              hintStyle: TextStyle(
                color: Colors.black26,
                fontFamily: 'Roboto',
                fontSize: 16,
              ),
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 1.5,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey, // Màu viền
                  width: 1.5, // Độ dày viền khi không tương tác
                ),
              ),
              // Thiết lập viền khi "focus" (khi người dùng nhấn vào TextFormField)
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlue, width: 2)),
              border: UnderlineInputBorder(
                  borderSide: BorderSide(
                color: Colors.grey,
                width: 2,
              )),
              fillColor: Colors.transparent,
              filled: true,
            ),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontFamily: 'Roboto',
            ),
            obscureText: true,
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return "Vui lòng nhập xác nhận mật khẩu";
              }
              if (value != _passTextController.text) {
                return 'Mật khẩu không trùng khớp';
              }
              return null;
            },
          ),
        ]);
  }

  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.only(top: 30),
      child: ElevatedButton(
          onPressed: _onHandleRegister,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Đăng ký',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
              fontSize: 18,
            ),
          )),
    );
  }

  Widget _buildOrSplitDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 0.8,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black87,
                  ],
                ),
              ),
            ),
          ),
          const Text(
            ' hoặc ',
            style: TextStyle(
              color: Colors.black87,
              fontFamily: 'Roboto',
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Container(
              height: 0.8,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black87,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialRegister() {
    return Column(
      children: [
        _buildSocialGoogleRegister(),
      ],
    );
  }

  Widget _buildSocialGoogleRegister() {
    return Container(
      width: double.infinity,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      margin: const EdgeInsets.only(top: 10),
      child: ElevatedButton(
        onPressed: () async {
          await signInWithGoogleAndCreateUser(context);
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          side: const BorderSide(
            width: 1.0,
            color: Colors.black87,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadowColor: Colors.transparent,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/google_logo.png",
              width: 24,
              height: 24,
              fit: BoxFit.fill,
            ),
            Container(
              margin: const EdgeInsets.only(left: 15),
              child: const Text(
                'Đăng ký bằng Google',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHaveAccount(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 20, top: 15),
      child: RichText(
          text: TextSpan(
              text: "Đã có tài khoản? ",
              style: const TextStyle(
                color: Colors.black87,
                fontFamily: 'Roboto',
                fontSize: 16,
              ),
              children: [
            TextSpan(
                text: "Đăng nhập",
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.pop(context);
                  }),
          ])),
    );
  }

  void _onHandleRegister() {
    final isvalid = _formKey.currentState?.validate() ?? false;
    if (_autoValidateMode == AutovalidateMode.disabled) {
      setState(() {
        _autoValidateMode = AutovalidateMode.always;
      });
    }
    if (isvalid) {
      return _onTapRegister(context);
    }
  }

  void _onTapRegister(BuildContext context) {
    final registerCubit = context.read<RegisterCubit>();
    final email = _emailTextController.text;
    final password = _passTextController.text;
    registerCubit.register(email, password);
  }

  void saveUserToFirebase() {
    String fullName = capitalizeWords(_teacherTextController.text.trim());
    FirebaseFirestore.instance.collection('users').add({
      'Email': _emailTextController,
      'Password': _passTextController,
      'Name': fullName,
    });
  }

  String capitalizeWords(String? text) {
    if (text == null || text.isEmpty) return ''; // Xử lý chuỗi rỗng
    return text
        .split(' ') // Tách chuỗi thành các từ
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() +
                word.substring(1).toLowerCase() // Viết hoa chữ cái đầu
            : '')
        .join(' '); // Ghép lại thành chuỗi
  }
}
