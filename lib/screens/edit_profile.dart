import "package:flutter/material.dart";
import 'package:socialapp/models/user.dart';
import 'package:socialapp/screens/homePage.dart';
import 'package:socialapp/widgets/progressbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfile extends StatefulWidget {
  final String? currentUserId;
  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool isLoading = false;
  UserModel? userModel;
  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  final _scaffoldkey = GlobalKey<ScaffoldState>();

  bool _displayNameValid = true;
  bool _bioValid = true;
  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });

    DocumentSnapshot doc = await userReference.doc(widget.currentUserId).get();
    userModel = UserModel.fromDocument(doc);
    print(userModel!.username);
    nameController.text = userModel!.displayname!;
    bioController.text = userModel!.bio!;
    setState(() {
      isLoading = false;
    });
  }

  buildDisplayName() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
      child: TextFormField(
        controller: nameController,
        decoration: InputDecoration(
            filled: true,
            border: InputBorder.none,
            hintText: "enter display name",
            label: Text("Display Name"),
            prefixIcon: Icon(Icons.verified_user_rounded),
            errorText: _displayNameValid ? null : "display name to short"),
      ),
    );
  }

  buildBio() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.0),
      child: TextFormField(
        controller: bioController,
        decoration: InputDecoration(
            filled: true,
            border: InputBorder.none,
            hintText: "enter your bio",
            label: Text("Bio"),
            prefixIcon: Icon(Icons.description),
            errorText: _bioValid ? null : "bio is too long"),
      ),
    );
  }

  updateProfileData() {
    setState(() {
      nameController.text.trim().length < 3 || nameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;
      bioController.text.trim().length > 100
          ? _bioValid = false
          : _bioValid = true;
    });

    if (_displayNameValid && _bioValid) {
      userReference.doc(widget.currentUserId).update({
        "displayName": nameController.text,
        "bio": bioController.text,
      });
      SnackBar snackbar = SnackBar(content: Text("profile updated"));
      _scaffoldkey.currentState!.showSnackBar(snackbar);
    }
  }

  logout() async {
    //accountAuth = false;
    await googleSignIn.signOut();

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () => Navigator.pop(context), icon: Icon(Icons.done)),
        ],
      ),
      body: isLoading
          ? circularProgress()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20.0),
                      child: CircleAvatar(
                        radius: 50.0,
                        backgroundColor: Colors.grey,
                        backgroundImage:
                            NetworkImage(userModel!.photoUrl.toString()),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    buildDisplayName(),
                    buildBio(),
                  ],
                ),
                Container(
                    padding: EdgeInsets.only(top: 20.0),
                    //color: Colors.green,
                    margin: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            print("update profile pressed");
                            updateProfileData();
                          },
                          child: Text("update profile"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            print("logout pressed");
                            logout();
                          },
                          child: Text("logout"),
                        )
                      ],
                    )),
              ],
            ),
    ));
  }
}
