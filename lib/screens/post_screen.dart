import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/screens/homePage.dart';
import 'package:socialapp/widgets/custom_image.dart';
import 'package:socialapp/widgets/progressbar.dart';

class Post extends StatefulWidget {
  final String? postId;
  final String? ownerId;
  final String? userName;
  final String? description;
  final String? mediaUrl;
  final String? location;
  final dynamic likes;

  Post(
      {this.postId,
      this.ownerId,
      this.userName,
      this.description,
      this.mediaUrl,
      this.location,
      this.likes});

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc["postId"],
      ownerId: doc["ownerId"],
      userName: doc["userName"],
      description: doc["description"],
      mediaUrl: doc["mediaUrl"],
      location: doc["location"],
      likes: doc["likes"],
    );
  }
  int getLikeCount(likes) {
    //if like no like, likeCount=0
    if (likes == null) {
      return 0;
    }
    int count = 0;
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  State<Post> createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        userName: this.userName,
        location: this.location,
        description: this.description,
        mediaUrl: this.mediaUrl,
        likes: this.likes,
        likeCounts: getLikeCount(this.likes),
      );
}

class _PostState extends State<Post> {
  final String? postId;
  final String? ownerId;
  final String? userName;
  final String? description;
  final String? mediaUrl;
  final String? location;
  int? likeCounts;
  Map? likes;

  _PostState(
      {this.postId,
      this.ownerId,
      this.userName,
      this.description,
      this.mediaUrl,
      this.location,
      this.likes,
      this.likeCounts});

  buildPostHeader() {
    return FutureBuilder(
      future: userReference.doc(widget.ownerId).get(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        UserModel user = UserModel.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.all(5.0),
          child: ListTile(
            leading: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(user.photoUrl!),
            ),
            title: GestureDetector(
              onTap: () {
                print("username pressed");
              },
              child: Text(
                user.username!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
            trailing: IconButton(
              onPressed: () {
                print("delete post");
              },
              icon: Icon(Icons.delete_sweep_outlined),
              color: Colors.red,
            ),
          ),
        );
      },
    );
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: () {
        print("image is tapped");
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
              padding: const EdgeInsets.all(10.0),
              child: cachedNetworkImage(mediaUrl)),
        ],
      ),
    );
  }

  buildPostFooter() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  print("love pressed");
                },
                icon: Icon(Icons.favorite),
                color: Colors.red,
              ),
              IconButton(
                  onPressed: () {
                    print("comment pressed");
                  },
                  icon: Icon(Icons.chat),
                  color: Colors.blue),
            ],
          ),
          Text("$likeCounts likes"),
          Text("name:$userName des:$description")
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
        Divider(height: 10.0, color: Colors.blue)
      ],
    );
  }
}
