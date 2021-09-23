import 'package:flutter/material.dart';
import 'package:socialapp/widgets/customAppBar.dart';
import 'package:socialapp/widgets/progress.dart';

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  Widget build(context) {
    return Scaffold(
      appBar: customAppBar(context, ifAppTitle: true),
      body: linearProgress(),
    );
  }
}
