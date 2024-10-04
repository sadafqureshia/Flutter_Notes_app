import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/utilts/Routes.dart';

class Registerpage extends StatefulWidget {
  const Registerpage({super.key});

  @override
  State<Registerpage> createState() => _RegisterpageState();
}

class _RegisterpageState extends State<Registerpage> {
  String name = "";
  bool changeButton = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  final _formkey = GlobalKey<FormState>();

  // Firebase sign-up function
  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } catch (e) {
      // Show error if sign-up fails
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      return null;
    }
  }

  Future<void> _signUp() async {
    if (_formkey.currentState?.validate() ?? false) {
      setState(() {
        changeButton = true;
      });
      
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      User? user = await signUpWithEmailAndPassword(email, password);

      if (user != null) {
        print("User is successfully created");
        await Navigator.pushNamed(context, MyRoutes.homeRoute);
      } else {
        print("Some error happened");
      }

      setState(() {
        changeButton = false;
      });
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
            key: _formkey,
            child: Column(
              children: [
                SizedBox(height: height * 0.03),
                Image.asset(
                  "assets/images/signup.jpg",
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
                  padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 32.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          hintText: "Enter Username",
                          labelText: "Username",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),  // Username icon
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return "Username cannot be empty";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          name = value;
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: "Enter email",
                          labelText: "Email",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),  // Email icon
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Email is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30.0),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: "Enter Password",
                          labelText: "Password",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),  // Password icon
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
                      Material(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(changeButton ? 20 : 8),
                        child: InkWell(
                          onTap: _signUp,
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
                                    "Register",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
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
