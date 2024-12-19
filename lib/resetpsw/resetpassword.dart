import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _resetPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _emailFocusNode = FocusNode();
  var _autoValidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    // Đăng ký listener cho focusNode
    _emailFocusNode.addListener(() {
      setState(() {}); // Gọi setState khi focus thay đổi
    });
  }

  @override
  void dispose() {
    _resetPassword.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future passwordRSet() async {
    ContentType contentType;
    String? error;
    String? title;

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _resetPassword.text.trim());
      title = "Thành công";
      error = "Kiểm tra email để khôi phục mật khẩu";
      contentType = ContentType.success;
    } on FirebaseAuthException {
      title = "Ôi chao!";
      error = "Vui lòng thử lại sau";
      contentType = ContentType.warning;
    }
    _showErrorSnackBar(title, error, contentType);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_outlined,
                color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidateMode: _autoValidateMode,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 150,
                    child: Image.asset(
                      'assets/images/gmal_pixian_ai.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Quên Mật Khẩu?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Đừng lo lắng! Điều này là bình thường.Vui lòng nhập địa chỉ email liên kết với tài khoản của bạn.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _resetPassword,
                    focusNode: _emailFocusNode,
                    // Gắn FocusNode vào TextFormField
                    decoration: InputDecoration(
                      hintText: 'Nhập email...',
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: _emailFocusNode.hasFocus
                            ? Colors.blue // Màu khi focus
                            : Colors.grey, // Màu khi không focus
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                      hintStyle: const TextStyle(
                        color: Colors.black38,
                        fontSize: 16,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.lightBlue,
                          width: 1.5,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.redAccent,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email!';
                      }
                      final bool emailValid = RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value);
                      if (!emailValid) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _onHandResetPasswordSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Tiếp theo',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onHandResetPasswordSubmit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (_autoValidateMode == AutovalidateMode.disabled) {
      setState(() {
        _autoValidateMode = AutovalidateMode.always;
      });
    }
    if (isValid) {
      passwordRSet();
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
        message: message,
        contentType: contentType,
      ),
      duration: const Duration(milliseconds: 2500),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
