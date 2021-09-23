import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:socialapp/screens/activity_feed.dart';
import 'package:socialapp/screens/profile.dart';
import 'package:socialapp/screens/search.dart';
import 'package:socialapp/screens/timeline.dart';
import 'package:socialapp/screens/upload.dart';
import 'package:socialapp/widgets/progress.dart';
import 'package:firebase_auth/firebase_auth.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
FirebaseAuth auth = FirebaseAuth.instance;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool accountAuth = false;
  late PageController pageController = PageController();
  int pageIndex = 0;
  late Hari hari;

  @override
  void initState() {
    pageController = PageController(
      initialPage: 0,
      // viewportFraction: 0.8,
    );
    super.initState();
    googleSignIn.onCurrentUserChanged.listen((account) {
      handlingSignIn(account);
    }, onError: (error) {
      print('the error occur while signin  is $error');
    });
    //if user is already login the this will directly move to homepage
    googleSignIn.signInSilently().whenComplete(() => DismissAction);
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

//to check user is logedIn or not
  handlingSignIn(accountt) {
    if (accountt != null) {
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

// function for login using google sign in
  login() async {
    circularProgress();
    await googleSignIn.signIn();
  }

// function for logout
  signOut() async {
    googleSignIn.signOut();
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
      // pageController.jumpToPage(pageIndex);
      pageController.animateToPage(pageIndex,
          duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
    });
  }

//if accountAuth=true i.e user is logedIn
  buildScreen() {
    return SafeArea(
        child: Scaffold(
      body: PageView(
        children: [
          Timeline(),
          ActivityFeed(),
          Upload(),
          Search(),
          Profile(),
        ],
        controller: pageController,
        onPageChanged: onPagechange,
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
              icon: Icon(Icons.feed_rounded), label: "timeline"),
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

class Hari {}
