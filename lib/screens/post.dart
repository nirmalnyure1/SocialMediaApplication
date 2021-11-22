import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/screens/comments.dart';
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
  final String? currentUserId = currentUser?.id;
  final String? postId;
  final String? ownerId;
  final String? userName;
  final String? description;
  final String? mediaUrl;
  final String? location;
  int? likeCounts;
  Map? likes;
  bool? isLiked = false;
  bool showHeart = false;

  _PostState({
    this.postId,
    this.ownerId,
    this.userName,
    this.description,
    this.mediaUrl,
    this.location,
    this.likes,
    this.likeCounts,
  });

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

  handleLikePost() {
    print("hello buddy");
    bool _isLiked = likes![currentUserId] == true;
    if (_isLiked) {
      postReference
          .doc(ownerId)
          .collection("userPost")
          .doc(postId)
          .update({"likes.$currentUserId": false});
      removeLikeFromActivityFeed();
      setState(() {
        likeCounts = likeCounts! - 1;
        //is liked is user to change the favorite color
        isLiked = false;
        likes![currentUserId] = false;
      });
    } else if (!isLiked!) {
      postReference
          .doc(ownerId)
          .collection("userPost")
          .doc(postId)
          .update({"likes.$currentUserId": true});
      addLikeToActivityFeed();
      setState(() {
        likeCounts = likeCounts! + 1;
        //is liked is user to change the favorite color
        isLiked = true;
        likes![currentUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  addLikeToActivityFeed() {
    bool isNotOwnerPost = currentUser!.id != ownerId;
    if (isNotOwnerPost) {
      activityFeedReference
          .doc(ownerId)
          .collection("feedItems")
          .doc(postId)
          .set({
        "type": "like",
        "username": currentUser!.username,
        "userid": currentUser!.id,
        "userProfileImage": currentUser!.photoUrl,
        "postId": postId,
        "mediaUrl": mediaUrl,
        "timestamp": timeStamp,
      });
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotOwnerPost = currentUser!.id != ownerId;
    if (isNotOwnerPost) {
      activityFeedReference
          .doc(ownerId)
          .collection("feedItems")
          .doc(postId)
          .get()
          .then((value) {
        if (value.exists) {
          value.reference.delete();
        }
      });
    }
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: () {
        handleLikePost();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
              padding: const EdgeInsets.all(10.0),
              child: cachedNetworkImage(mediaUrl)),
          showHeart
              ? TweenAnimationBuilder(
                  duration: Duration(milliseconds: 500),
                  tween: Tween(begin: 4.0, end: 50.0),
                  curve: Curves.easeOut,
                  builder:
                      (BuildContext context, dynamic value, Widget? child) {
                    return Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.red.shade50,
                              offset: Offset(0.0, 1.0),
                              blurRadius: 50.0)
                        ],
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: value,
                      ),
                    );
                  },
                )
              : Text(""),
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
                onPressed: handleLikePost,
                icon: Icon(isLiked! ? Icons.favorite : Icons.favorite_border),
                color: Colors.red,
              ),
              IconButton(
                  onPressed: () => showComment(
                      context: context,
                      postId: postId,
                      mediaUrl: mediaUrl,
                      ownerId: ownerId),
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
    isLiked = (likes![currentUserId]) == true;
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

showComment({context, String? postId, String? ownerId, String? mediaUrl}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
      postId: postId,
      postOwnerId: ownerId,
      postMediaUrl: mediaUrl,
    );
  }));
}
