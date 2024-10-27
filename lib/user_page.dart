import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:main/login_page.dart';

class UserPage extends StatefulWidget {
  final String userId;

  const UserPage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool _isLoading = false; // To track loading state
  Map<String, dynamic>? userDetails;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    // Replace with your actual API URL
    final url = Uri.parse('http://192.168.100.185/bbydb/getUserDetails.php?userId=${widget.userId}');
    //final url = Uri.parse('http://192.168.128.41/bbydb/getUserDetails.php?userId=${widget.userId}');


    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('error')) {
          // Handle error (e.g., user not found)
          print(data['error']);
        } else {
          // Set user details from the response
          setState(() {
            userDetails = data;
          });
        }
      } else {
        print('Failed to load user details');
      }
    } catch (e) {
      print('Error: $e');
    }

    setState(() {
      _isLoading = false; // Stop loading
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
        backgroundColor: Colors.red,
      ),
      body: Center( // Centers the entire body
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center, // Centers vertically
            crossAxisAlignment: CrossAxisAlignment.center, // Centers horizontally
            children: [
              if (userDetails != null) ...[
                Text(
                  'Name: ${userDetails!['fullname']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'User ID: ${widget.userId}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 5),
                Text(
                  'Username: ${userDetails!['username']}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 5),
                Text(
                  'Email: ${userDetails!['email']}',
                  style: TextStyle(fontSize: 16),
                ),
              ] else if (_isLoading) ...[
                CircularProgressIndicator(),
              ] else ...[
                Text(
                  'User details will be displayed here.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : () => _logout(context), // Disable button when loading
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text('Logout'),
              ),
              if (_isLoading) // Show loading indicator
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });

    // Clear user data from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId'); // Clear userId

    // Navigate to the login page
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false, // Remove all previous routes
    );

    setState(() {
      _isLoading = false; // Reset loading state
    });
  }
}



//timestamp -- final