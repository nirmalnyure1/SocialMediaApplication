import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/screens/activity_feed.dart';
import 'package:socialapp/screens/create_account.dart';
import 'package:socialapp/screens/profile.dart';
import 'package:socialapp/screens/search.dart';
import 'package:socialapp/screens/timeline.dart';
import 'package:socialapp/screens/upload.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

final firebase_storage.Reference storageReference =
    firebase_storage.FirebaseStorage.instance.ref();
final userReference = FirebaseFirestore.instance.collection('users');
final postReference = FirebaseFirestore.instance.collection('post');
final commentReference = FirebaseFirestore.instance.collection("comment");
final activityFeedReference = FirebaseFirestore.instance.collection("feed");
final followersRef = FirebaseFirestore.instance.collection('followers');
final followingRef = FirebaseFirestore.instance.collection('following');
final timelineRef = FirebaseFirestore.instance.collection('timeline');
final GoogleSignIn googleSignIn = GoogleSignIn();
final DateTime timeStamp = DateTime.now();
//currentUser store the user data which will be user all over the application
//UserModel is the model that we created for storing all the data
UserModel? currentUser;
final DateTime timestamp = DateTime.now();


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool accountAuth = false;
  late PageController pageController = PageController();
  int pageIndex = 0;

  @override
  void initState() {
    pageController = PageController(
      initialPage: 0,
      // viewportFraction: 0.8,
    );
    super.initState();
    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      handlingSignIn(account);
    }, onError: (error) {
      print('the error occur while signin  is $error');
    });
    //if user is already login the this will directly move to homepage
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handlingSignIn(account);
    }).catchError((err) {
      print('Error signing in: $err');
    });
  }

  //to check user is logedIn or not
  handlingSignIn(GoogleSignInAccount? accountt) async {
    if (accountt != null) {
      await createUserInFlutterFirestore();
      print('User sign in: $accountt');
      setState(() {
        accountAuth = true;
      });
    } else {
      print('on sign in');
      setState(() {
        accountAuth = false;
      });
    }
  }

  //method for creating user in firebase database ..firestore
  createUserInFlutterFirestore() async {
    //check if the user exist in user collectiton in firestore (associated to their id)
    final GoogleSignInAccount? user = googleSignIn.currentUser;
    DocumentSnapshot doc = await userReference.doc(user?.id).get();

    //if user is not exist then navigate them to the create account page
    if (!doc.exists) {
      final username = await Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return CreateAccount();
      }));

      //get username from create account page and use it to make new user document in user collection
      userReference.doc(user!.id).set({
        "id": user.id,
        "username": username,
        'photoUrl': user.photoUrl,
        'email': user.email,
        'displayName': user.displayName,
        "bio": '',
        "timestamp": timeStamp
      });

      doc = await userReference.doc(user.id).get();
    }
//des
    currentUser = UserModel.fromDocument(doc);
    print(currentUser);
    print(currentUser!.username);
  }

  @override
  void dispose() {
    pageController.dispose();

    super.dispose();
  }

  handelingUser(area) {
    if (area != null) {
      print('hello buddy');
    }
  }

// function for login using google sign in
  login() async {
    //  circularProgress();
    await googleSignIn.signIn();
  }

// function for logout
  signOut() async {
    accountAuth = false;
    await googleSignIn.signOut();

    setState(() {});
  }

//function for page Change on PageView
  onPagechange(int index) {
    setState(() {
      this.pageIndex = index;
    });
  }

//function to Change Page using bottomNavigationBar
  onTap(int index) {
    setState(() {
      this.pageIndex = index;
      pageController.jumpToPage(
        pageIndex,
      );
      // pageController.animateToPage(pageIndex,
      //     duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
    });
  }

//if accountAuth=true i.e user is logedIn
  buildScreen() {
    return SafeArea(
        child: Scaffold(
      body: PageView(
        children: [
          Timeline(
            currentUser: currentUser,
          ),
          // TextButton(
          //   onPressed: () {
          //     signOut();
          //   },
          //   child: Text('signout'),
          // ),
          ActivityFeed(),
          Upload(currentUser: currentUser),
          Search(),
          Profile(profileId: currentUser?.id),
        ],
        controller: pageController,
        onPageChanged: onPagechange,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 30,
        type: BottomNavigationBarType.shifting,
        elevation: 30,
        selectedFontSize: 10,
        currentIndex: pageIndex,
        onTap: onTap,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.feed_rounded), label: "home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_activity_rounded), label: "activityfeed"),
          BottomNavigationBarItem(
              icon: Icon(Icons.photo_camera), label: "upload"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "search"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_box_rounded), label: "profile"),
        ],
      ),
    ));
  }

//if accountAuth=false i.e user is not logedIn
  unAuthScreen() {
    return SafeArea(
      child: Scaffold(
          body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor,
            ],
          ),
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Photo Lab',
                style: TextStyle(
                  letterSpacing: 2,
                  fontWeight: FontWeight.w500,
                  fontSize: 100,
                  fontFamily: "Signatra",
                  color: Colors.white,
                ),
              ),
              SizedBox(height: .0),
              GestureDetector(
                onTap: login,
                child: Container(
                  height: 40.0,
                  width: 210,
                  child: Image(
                    image: AssetImage("assets/images/googlesignin.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            ]),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return accountAuth ? buildScreen() : unAuthScreen();
  }
}
