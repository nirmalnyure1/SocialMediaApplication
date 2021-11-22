import 'package:flutter/material.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/screens/edit_profile.dart';
import 'package:socialapp/screens/homePage.dart';
import 'package:socialapp/screens/post.dart';
import 'package:socialapp/widgets/customAppBar.dart';
import 'package:socialapp/widgets/post_tile.dart';
import 'package:socialapp/widgets/progressbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Profile extends StatefulWidget {
  final String? profileId;

  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentUserId = currentUser!.id.toString();
  bool isLoadingPost = false;
  int postCount = 0;
  List<Post>? posts = [];

  //post orientation
  String postOrientation = "grid";
  @override
  void initState() {
    super.initState();
    getProfilePost();
  }

  getProfilePost() async {
    setState(() {
      isLoadingPost = true;
    });

    QuerySnapshot snapshot = await postReference
        .doc(widget.profileId)
        .collection("userPost")
        .orderBy("timestamp", descending: true)
        .get();
    setState(() {
      isLoadingPost = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((e) => Post.fromDocument(e)).toList();
      print(posts);
    });
  }

//edit profile function
  editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfile(
          currentUserId: currentUserId,
        ),
      ),
    );
  }

//build button for profile
  buildButton({String? text, function}) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: GestureDetector(
        onTap: function,
        child: Container(
          padding: EdgeInsets.all(8.0),
          width: MediaQuery.of(context).copyWith().size.width / 3,
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(5.0)),
          child: Center(
            child: Text(
              text!,
              //textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

//to show edit profile button
  buildProfileButton() {
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(text: "Edit  Profile", function: editProfile);
    }
    return Text("profile button");
  }

  //to show post level and count
  Column buildCountColumn(String lavel, int count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 22.0),
        ),
        Container(
          child: Text(
            lavel.toString(),
            style: TextStyle(
                fontWeight: FontWeight.w400, fontSize: 17, color: Colors.grey),
          ),
        )
      ],
    );
  }

//to show profile header
  buildProfileHeader() {
    return FutureBuilder(
      future: userReference.doc(widget.profileId).get(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        UserModel user = UserModel.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey,
                    backgroundImage: NetworkImage(user.photoUrl.toString()),
                  ),
                  Expanded(
                      child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          buildCountColumn("post", postCount),
                          buildCountColumn("followers", 0),
                          buildCountColumn("following", 1),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [buildProfileButton()],
                      )
                    ],
                  ))
                ],
              ),
              Container(
                padding: EdgeInsets.only(top: 15.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  user.username.toString(),
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 8.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  user.displayname.toString(),
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  buildProfilePost() {
    if (isLoadingPost) {
      return circularProgress();
    } else if (posts!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(30),
        child: Container(
          child: Center(
            child: Text("no post avilable \n   upload post",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          ),
        ),
      );
    } else if (postOrientation == "grid") {
      List<GridTile>? gridTile = [];
      posts!.forEach((val) {
        gridTile.add(
          GridTile(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: PostTile(val),
            ),
          ),
        );
      });

      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 2,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTile,
      );
    } else if (postOrientation == "list") {
      return Column(
        children: posts!,
      );
    }
  }

  setPostOrientation(String orientation) {
    setState(() {
      this.postOrientation = orientation;
    });
  }

  buildTooglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          onPressed: () => setPostOrientation("grid"),
          icon: Icon(Icons.grid_on),
          color: postOrientation == "grid"
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
     
        IconButton(
          onPressed: () => setPostOrientation("list"),
          icon: Icon(Icons.list),
          color: postOrientation == "list"
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, ifAppTitle: false, title: 'Profile'),
      body: ListView(
        children: [
          buildProfileHeader(),
          Divider(
            height: 10.0,
            color: Colors.grey,
          ),
          buildTooglePostOrientation(),
          Divider(
            height: 10.0,
            color: Colors.grey,
          ),
          buildProfilePost(),
        ],
      ),
    );
  }
}
