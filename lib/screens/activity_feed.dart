import 'package:flutter/material.dart';
import 'package:socialapp/screens/homePage.dart';
import 'package:socialapp/screens/post_screen.dart';
import 'package:socialapp/screens/profile.dart';
import 'package:socialapp/utils/colors.dart';
import 'package:socialapp/widgets/customAppBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialapp/widgets/progressbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  getActivityFeed() async {
    QuerySnapshot snapshot = await activityFeedReference
        .doc(currentUser!.id)
        .collection("feedItems")
        .orderBy("timestamp", descending: true)
        .limit(50)
        .get();

    List<ActivityFeedItem> feedItems = [];

    snapshot.docs.forEach((valu) {
      feedItems.add(ActivityFeedItem.fromDocument(valu));
    });
    return feedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, title: "Activity Feed"),
      body: Container(
        child: FutureBuilder(
          future: getActivityFeed(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }
            return ListView(children: snapshot.data);
          },
        ),
      ),
    );
  }
}

Widget? mediaPreview;
String? activityItemText;

class ActivityFeedItem extends StatelessWidget {
  final String? mediaUrl;
  final String? postId;
  final Timestamp? timestamp;
  final String? type; //like , follow and comment
  final String? userProfileImage;
  final String? userId;
  final String? username;
  final String? commentData;

  ActivityFeedItem({
    this.mediaUrl,
    this.postId,
    this.timestamp,
    this.type,
    this.userProfileImage,
    this.userId,
    this.username,
    this.commentData,
  });
  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      mediaUrl: doc["mediaUrl"],
      postId: doc["postId"],
      timestamp: doc["timestamp"],
      type: doc["type"],
      userProfileImage: doc["userProfileImage"],
      userId: doc["userId"],
      username: doc["username"],
      commentData: doc["commentData"],
    );
  }

  showPost(context) {
    if (postId != null && userId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostScreen(postId: postId!, userId: userId!),
        ),
      );
    } else {
      print(
          "--------------post id is null or userId is null-------------------");
    }
  }

  configureMediaPreview(context) {
    if (type == "like" || type == "comment") {
      mediaPreview = GestureDetector(
        onTap: () => showPost(context),
        child: Container(
          height: 50,
          width: 50,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: CachedNetworkImage(
                imageUrl: mediaUrl.toString(),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text("");
    }
    if (type == "like") {
      activityItemText = "liked your post";
    } else if (type == "follow") {
      activityItemText = "is following you ";
    } else if (type == "comment") {
      activityItemText = "comment: $commentData";
    } else {
      activityItemText = "error :unknown type $type";
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);
    return Container(
        padding: EdgeInsets.only(left: 5, right: 5, top: 15, bottom: 15),
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: MyColors.color2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100.0),
                    child: CachedNetworkImage(
                      imageUrl: userProfileImage.toString(),
                      height: 60,
                      width: 60,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$username",
                          style: TextStyle(
                              fontSize: 15,
                              color: MyColors.textBlack,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "$activityItemText sdjflasjdflsjdfljd",
                          // maxLines: 5,
                          style: TextStyle(
                            fontSize: 15,
                            color: MyColors.textBlack,
                          ),
                        ),
                        Text(
                          timeago.format(timestamp!.toDate()),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
                decoration: BoxDecoration(
                  border: Border.all(color: MyColors.color1, width: 3.0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: mediaPreview),
          ],
        ));
  }
}

showProfile(BuildContext context, {String? profileId}) {
  if (profileId != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Profile(
          profileId: profileId,
        ),
      ),
    );
  } else {
    print("--------profile id is null--------");
  }
}
