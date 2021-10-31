import 'package:flutter/material.dart';

AppBar customAppBar(context,
    {bool ifAppTitle = false, title, removeBackButton = false}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Text(
      ifAppTitle ? "PhotoLab" : title,
      style: TextStyle(
        fontFamily: ifAppTitle ? "Signatra" : "",
        fontSize: ifAppTitle ? 50 : 30,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    ),
    backgroundColor: Theme.of(context).primaryColor,
    centerTitle: true,
  );
}
