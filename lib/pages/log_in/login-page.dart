import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/utilts/Routes.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  String name = "";
  bool changeButton = false;
  bool _passwordVisible = false; // For toggling password visibility
  bool _isLoggedIn = false; // Track if the user is logged in

  final _formKey = GlobalKey<FormState>();

  // Controllers for email and password input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _logIn() async {
    if (_isLoggedIn) {
      // If already logged in, show a message and return
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are already logged in.')),
      );
      return;
    }

    if (_formKey.currentState?.validate () ?? false) {
      setState(() {
        changeButton = true;
      });

      try {
        // Perform Firebase login
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Set login state to true
        setState(() {
          _isLoggedIn = true; // Mark user as logged in
        });

        // Navigate to the home route on successful login
        await Future.delayed(const Duration(seconds: 1));
        await Navigator.pushNamed(context, MyRoutes.homeRoute);

        setState(() {
          changeButton = false;
        });
      } catch (e) {
        // Show error if login fails (e.g., wrong password or user doesn't exist)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${_handleFirebaseError(e.toString())}')),
        );
        setState(() {
          changeButton = false;
        });
      }
    }
  }

  String _handleFirebaseError(String error) {
    // A more user-friendly error handling function
    if (error.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (error.contains('user-not-found')) {
      return 'No account found for that email.';
    } else if (error.contains('invalid-email')) {
      return 'Invalid email format.';
    } else {
      return 'An unknown error occurred.';
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: height * 0.03),
                Image.asset(
                  "assets/images/Login Image.png",
                  height: height * 0.3,
                  width: 150,
                ),
                const SizedBox(height: 20.0),
                const Text(
                  "Welcome",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20.0),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15.0, horizontal: 32.0),
                  child: Column(
                    children: [
                      // Email Input Field
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: "Enter Email",
                          labelText: "Email",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email), // Email icon
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return "Email cannot be empty";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20.0),

                      // Password Input Field with Eye Icon
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_passwordVisible, // Toggle visibility
                        decoration: InputDecoration(
                          hintText: "Enter Password",
                          labelText: "Password",
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock), // Password icon
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Password is required';
                          } else if (value!.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30.0),

                      // Login Button
                      Material(
                        color: Colors.deepPurple,
                        borderRadius:
                            BorderRadius.circular(changeButton ? 20 : 8),
                        child: InkWell(
                          onTap: _logIn,
                          child: AnimatedContainer(
                            duration: const Duration(seconds: 1),
                            width: changeButton ? 80 : 150,
                            height: 40,
                            alignment: Alignment.center,
                            child: changeButton
                                ? const Icon(
                                    Icons.done,
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Log In",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Register Button
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, MyRoutes.registerRoute);
                        },
                        child: const Text(
                          "Don't have an account? Register here",
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
