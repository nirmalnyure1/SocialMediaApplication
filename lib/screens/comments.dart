import 'package:flutter/material.dart';
import 'package:socialapp/screens/homePage.dart';
import 'package:socialapp/utils/colors.dart';
import 'package:socialapp/widgets/customAppBar.dart';
import 'package:socialapp/widgets/progressbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final String? postId;
  final String? postOwnerId;
  final String? postMediaUrl;

  const Comments({
    this.postId,
    this.postOwnerId,
    this.postMediaUrl,
  });

  @override
  CommentsState createState() => CommentsState(
        postId: this.postId,
        postOwnerId: this.postOwnerId,
        postMediaUrl: this.postMediaUrl,
      );
}

class CommentsState extends State<Comments> {
  final String? postId;
  final String? postOwnerId;
  final String? postMediaUrl;
  TextEditingController commentController = TextEditingController();

  CommentsState({
    this.postId,
    this.postOwnerId,
    this.postMediaUrl,
  });

  buildComment() {
    return StreamBuilder(
      stream: commentReference
          .doc(postId)
          .collection("comments")
          .orderBy("timestamp", descending: false)
          .snapshots(),
      builder: (context, AsyncSnapshot<dynamic>? snapshot) {
        if (!snapshot!.hasData) {
          return circularProgress();
        }
        List<Comment> comments = [];
        snapshot.data.docs.forEach((value) {
          comments.add(Comment.fromDocument(value));
        });
        return ListView(
          children: comments,
        );
      },
    );
  }

  commentAdded() {
    commentReference.doc(postId).collection("comments").add({
      "username": currentUser!.username,
      "comment": commentController.text,
      "timestamp": timeStamp,
      "avatarUrl": currentUser!.photoUrl,
      "userId": currentUser!.id,
    });
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: customAppBar(
          context,
          title: "Comment Box",
        ),
        body: Column(children: [
          Expanded(child: buildComment()),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: InputDecoration(labelText: "write a  comment"),
            ),
            trailing: IconButton(
              onPressed: () => commentAdded(),
              icon: Icon(Icons.send, color: MyColors.color1),
            ),
          )
        ]),
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String? username;
  final String? userId;
  final String? avatarUrl;
  final String? comment;
  final Timestamp? timestamp;

  Comment({
    this.username,
    this.userId,
    this.avatarUrl,
    this.comment,
    this.timestamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc["username"],
      userId: doc["userId"],
      avatarUrl: doc["avatarUrl"],
      comment: doc["comment"],
      timestamp: doc["timestamp"],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(comment!),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl!),
          ),
          subtitle: Text(
            timeago.format(
              timestamp!.toDate(),
            ),
          ),
        ),
        Divider()
      ],
    );
  }
}
