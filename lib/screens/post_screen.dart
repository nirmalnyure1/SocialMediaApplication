import 'package:flutter/material.dart';
import 'package:socialapp/widgets/post.dart';
import 'package:socialapp/widgets/header.dart';

import '../widgets/progressbar.dart';
import 'homePage.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;

  PostScreen({required this.userId, required this.postId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          postReference.doc(userId).collection('userPost').doc(postId).get(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        var data = snapshot.data;
        Post post = Post.fromDocument(snapshot.data);

        return Center(
          child: Scaffold(
            appBar: header(context, titleText: post.description ?? " "),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
