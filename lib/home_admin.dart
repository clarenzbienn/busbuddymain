import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  final String adminId;

  AdminPage({required this.adminId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
      ),
      body: Center(
        child: Text("Welcome, Admin! ID: $adminId"),
      ),
    );
  }
}
