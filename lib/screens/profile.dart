import 'package:flutter/material.dart';
import 'package:socialapp/widgets/customAppBar.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context,ifAppTitle: false,title: 'Profile'),
    );
  }
}
