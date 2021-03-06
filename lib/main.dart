import 'package:flutter/material.dart';

import 'package:socialapp/screens/homePage.dart';
import 'package:socialapp/utils/myTheme.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async{
  
  WidgetsFlutterBinding.ensureInitialized();
  
  Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: MyTheme.lighTheme(),

  
    );
  }
}
