import 'package:flutter/material.dart';

import '../../../Images/stringimage.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: colorBackgr, // Màu nền tổng thể của trang
        appBar: AppBar(
          backgroundColor: colorBackgr, // Màu nền tổng thể của trang
          title: Text(
            "Trợ giúp",
            style: TextStyle(
              color: Colors.black.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.black54,
              size: 25,
            ),
            onPressed: () {
              Navigator.pop(context); // Đóng trang
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15),
              Text(
                "Thông tin hỗ trợ",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Email",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  Text(
                    "Minhtien03@gmail.com",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.8)),
                  ),
                ],
              ),
              Divider(color: Colors.black26),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Facebook",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  Text(
                    "Lương Minh Tiến",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.black26),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Số điện thoại",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  Text(
                    "0334 2835 99",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
