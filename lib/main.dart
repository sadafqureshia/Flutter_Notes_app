import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/pages/dashboard/Home-page.dart';
import 'package:flutter_app/pages/log_in/login-page.dart';
import 'package:flutter_app/pages/log_in/signup-page.dart';
import 'package:flutter_app/utilts/Routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const Myapp());
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.light,
      theme: ThemeData(primarySwatch: Colors.deepPurple,
      fontFamily: GoogleFonts.lato().fontFamily,),


      debugShowCheckedModeBanner: false,//debug

      darkTheme: ThemeData(brightness: Brightness.dark),

     initialRoute: MyRoutes.loginRoute,
      routes: {
        "/":(context)=>LogInPage(),
        MyRoutes.loginRoute: (context) => LogInPage(),
        MyRoutes.homeRoute: (context) => Homepage(),
        MyRoutes.registerRoute: (context) => Registerpage(),
      },
    );
  }
}