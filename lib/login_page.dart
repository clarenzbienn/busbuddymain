import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:main/origin_screens/origin_cubao.dart';
import 'package:main/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String identifier = '', password = '';
  bool _obscureText = true;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      var url = 'http://192.168.100.185/bbydb/login.php'; 
      //var url = 'http://192.168.128.41/bbydb/login.php'; 
      //var url = 'http://localhost/bbydb/login.php';// Change to your local IP or API endpoint

      try {
        var response = await http.post(Uri.parse(url), body: {
          'identifier': identifier,
          'password': password,
        });

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          if (data['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CubaoOrigin(
                  "Your Origin String", 
                  userId: data['user_id'], // Make sure this user_id is valid
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Server error. Status code: ${response.statusCode}')),
          );
        }
      } catch (e) {
        print('Error: $e'); // Print the error for debugging
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not connect to the server. Please check your internet connection.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields")),
      );
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
            image: AssetImage('lib/icons/bg_new.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView( // Add this to enable scrolling
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Image.asset(
                    'lib/icons/logo_new.png',
                    height: 250,
                  ),
                ),

                // White container for text
                Container(
                  width: double.infinity, // Occupy full width
                  height: MediaQuery.of(context).size.height * 0.63, // Adjust height as needed
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9), // Slightly transparent white
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), // Padding inside the container
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start, // Align items at the top
                        children: [
                          // Welcome back text
                          const Padding(
                            padding: EdgeInsets.only(top: 20.0), // Optional: Adjust top padding
                            child: Text(
                              'WELCOME BACK!',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 40,
                                fontFamily: 'GabrielSans',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 0), // Space below the welcome text
                          const Text(
                            'Login to your account.',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontFamily: 'GabrielSans',
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 40), // Space below the subtitle
                          
                          // Email or Username text field
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: "Username", // Hint text
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
                              contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0), // Adjust the vertical padding to control height
                            ),
                            onSaved: (value) => identifier = value!, // Save the identifier value
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email or username'; // Validation message
                              }
                              return null; // Field is valid
                            },
                          ),

                          const SizedBox(height: 5),

                          // Password text field
                          TextFormField(
                            obscureText: _obscureText, // Use the boolean to toggle visibility
                            style: const TextStyle(
                              fontSize: 13.0, // Adjust font size
                              height: 1.5,    // Adjust line height (default is usually 1.0)
                              color: Colors.black, // Customize the content text color if needed
                            ),
                            decoration: InputDecoration(
                              hintText: "Password", // Hint text
                              hintStyle: const TextStyle(
                                fontSize: 13.0,
                                color: Color.fromRGBO(169, 113, 0, 1),
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
                                  _obscureText ? Icons.visibility_off : Icons.visibility,
                                  color: Color.fromRGBO(169, 113, 0, 0.28), // Customize the suffix icon color
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText; // Toggle the password visibility
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
                              contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0), // Adjust the vertical padding to control height
                            ),
                            onSaved: (value) => password = value!, // Save the password value
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password'; // Validation message
                              }
                              return null; // Field is valid
                            },
                          ),

                          const SizedBox(height: 20),

                          // Login button
                          Container(
                            height: 50, // Set the desired height for the container
                            child: ElevatedButton(
                              onPressed: _login,
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white, // Change the color of the login text here
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(70),
                                ),
                                backgroundColor: const Color.fromARGB(255, 236, 33, 40),
                                minimumSize: const Size(350, 0), // Set the minimum width to 350, height will adapt
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Sign up text
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Don\'t have an account? ',
                                style: TextStyle(
                                  color: Colors.black45,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => SignupPage()),
                                  );
                                },
                                child: const Text(
                                  'Sign up',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
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
