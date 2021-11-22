import 'package:flutter/material.dart';
import 'package:socialapp/screens/homePage.dart';
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
            return ListView(
              children: snapshot.data,
            );
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
  configureMediaPreview() {
    if (type == "like" || type == "comment") {
      mediaPreview = GestureDetector(
        onTap: () => print("media preview pressed"),
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
    configureMediaPreview();
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: MyColors.color2,
        ),
        child: ListTile(
            title: GestureDetector(
              onTap: () => print("title pressed"),
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                    style: TextStyle(
                      fontSize: 15,
                      color: MyColors.textBlack,
                    ),
                    children: [
                      TextSpan(
                        text: username,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: "  $activityItemText",
                      ),
                    ]),
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50.0),
                child: CachedNetworkImage(
                  imageUrl: userProfileImage.toString(),
                ),
              ),
            ),
            subtitle: Text(
              timeago.format(timestamp!.toDate()),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: MyColors.color1, width: 3.0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: mediaPreview)),
      ),
    );
  }
}
