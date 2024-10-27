import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:main/login_page.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  String username = '', fullname = '', email = '', password = '', confirmPassword = '';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Passwords do not match")));
        return;
      }

      var url = 'http://192.168.100.185/bbydb/signup.php';
      var response = await http.post(Uri.parse(url), body: {
        'username': username,
        'fullname': fullname,
        'email': email,
        'password': password,
      });

      var data = json.decode(response.body);
      if (data['status'] == 'success') {
        _formKey.currentState!.reset();
        username = '';
        fullname = '';
        email = '';
        password = '';
        confirmPassword = '';

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registered successfully")));
        await Future.delayed(Duration(seconds: 2));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
      } else {
        // Handle specific error messages
        String errorMessage;
        if (data['code'] == 'username_exists') {
          errorMessage = 'Username already exists. Please choose another.';
        } else if (data['code'] == 'email_exists') {
          errorMessage = 'Email already exists. Please use a different email.';
        } else {
          errorMessage = data['message']; // Generic error message
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields correctly.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/icons/bg_new.png'), // Background image
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Image.asset(
                    'lib/icons/logo_new.png', // Logo image
                    height: 250,
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.63,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'CREATE ACCOUNT',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 40,
                              fontFamily: 'GabrielSans',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Username text field
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: "Username",
                              hintStyle: const TextStyle(
                                fontSize: 13.0,
                                color: Color.fromARGB(149, 64, 47, 14),
                              ),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(left: 10.0, right: 0.0),
                                child: Icon(
                                  Icons.person,
                                  color: Color.fromRGBO(169, 113, 0, 1),
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0),
                                borderSide: const BorderSide(color: Color.fromARGB(255, 255, 223, 169)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0),
                                borderSide: const BorderSide(color: Color.fromARGB(255, 255, 223, 169)),
                              ),
                              fillColor: const Color.fromARGB(255, 255, 223, 169),
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0),
                            ),
                            onSaved: (value) => username = value!,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a username';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          // Fullname text field
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: "Full Name",
                              hintStyle: const TextStyle(
                                fontSize: 13.0,
                                color: Color.fromARGB(149, 64, 47, 14),
                              ),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(left: 10.0, right: 0.0),
                                child: Icon(
                                  Icons.person,
                                  color: Color.fromRGBO(169, 113, 0, 1),
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0),
                                borderSide: const BorderSide(color: Color.fromARGB(255, 255, 223, 169)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0),
                                borderSide: const BorderSide(color: Color.fromARGB(255, 255, 223, 169)),
                              ),
                              fillColor: const Color.fromARGB(255, 255, 223, 169),
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0),
                            ),
                            onSaved: (value) => fullname = value!,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          // Email text field
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: "Email",
                              hintStyle: const TextStyle(
                                fontSize: 13.0,
                                color: Color.fromARGB(149, 64, 47, 14),
                              ),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(left: 10.0, right: 0.0),
                                child: Icon(
                                  Icons.email,
                                  color: Color.fromRGBO(169, 113, 0, 1),
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0),
                                borderSide: const BorderSide(color: Color.fromARGB(255, 255, 223, 169)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0),
                                borderSide: const BorderSide(color: Color.fromARGB(255, 255, 223, 169)),
                              ),
                              fillColor: const Color.fromARGB(255, 255, 223, 169),
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0),
                            ),
                            onSaved: (value) => email = value!,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          // Password text field
                          TextFormField(
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              hintText: "Password",
                              hintStyle: const TextStyle(
                                fontSize: 13.0,
                                color: Color.fromARGB(149, 64, 47, 14),
                              ),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(left: 10.0, right: 0.0),
                                child: Icon(
                                  Icons.lock,
                                  color: Color.fromRGBO(169, 113, 0, 1),
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0),
                                borderSide: const BorderSide(color: Color.fromARGB(255, 255, 223, 169)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0),
                                borderSide: const BorderSide(color: Color.fromARGB(255, 255, 223, 169)),
                              ),
                              fillColor: const Color.fromARGB(255, 255, 223, 169),
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0),
                            ),
                            onSaved: (value) => password = value!,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          // Confirm Password text field
                          TextFormField(
                            obscureText: !_isConfirmPasswordVisible,
                            decoration: InputDecoration(
                              hintText: "Confirm Password",
                              hintStyle: const TextStyle(
                                fontSize: 13.0,
                                color: Color.fromARGB(149, 64, 47, 14),
                              ),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(left: 10.0, right: 0.0),
                                child: Icon(
                                  Icons.lock,
                                  color: Color.fromRGBO(169, 113, 0, 1),
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0),
                                borderSide: const BorderSide(color: Color.fromARGB(255, 255, 223, 169)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0),
                                borderSide: const BorderSide(color: Color.fromARGB(255, 255, 223, 169)),
                              ),
                              fillColor: const Color.fromARGB(255, 255, 223, 169),
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0),
                            ),
                            onSaved: (value) => confirmPassword = value!,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // Sign Up button
                          ElevatedButton(
                            onPressed: _signup,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15), backgroundColor: const Color.fromRGBO(169, 113, 0, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'SIGN UP',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Navigate to Login page
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                            },
                            child: const Text(
                              'Already have an account? Log In',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color.fromRGBO(169, 113, 0, 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
