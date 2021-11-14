import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/screens/homePage.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot>? searchResultFuture;
  String? username;
  userSearchFunction(username) {
    Future<QuerySnapshot> userDoc =
        userReference.where("username", isGreaterThanOrEqualTo: username).get();
    setState(() {
      searchResultFuture = userDoc;
      print('submit');
    });
  }

  clearSearch() {
    searchController.clear();
  }

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "search user",
          filled: true,
          fillColor: Colors.grey.shade300,
          prefixIcon: Icon(Icons.account_box),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: userSearchFunction,
      ),
    );
  }

  Container buidNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: ListView(
        children: <Widget>[
          SvgPicture.asset(
            "assets/images/search.svg",
            height: orientation == Orientation.portrait ? 500 : 150,
          ),
          Text(
            "Find User",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: orientation == Orientation.portrait ? 50.0 : 30.0,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Colors.white),
          )
        ],
      ),
    );
  }

  FutureBuilder builSearchResult() {
    return FutureBuilder(
        future: searchResultFuture,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          List<UserResult> searchReslut = [];
          snapshot.data!.docs.forEach((snapshot) {
            UserModel user = UserModel.fromDocument(snapshot);
            UserResult searchRe = UserResult(user);
            searchReslut.add(searchRe);
          });
          return ListView(
            children: searchReslut,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
      appBar: buildSearchField(),
      body: searchResultFuture == null ? buidNoContent() : builSearchResult(),
    );
  }
}

class UserResult extends StatelessWidget {
  final UserModel user;

  UserResult(this.user);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.5),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              print("tapped");
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green,
                backgroundImage: NetworkImage(user.photoUrl.toString()),
              ),
              title: Text(
                user.displayname.toString(),
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                user.username.toString(),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Divider(
            height: 4,
            color: Colors.white54,
          )
        ],
      ),
    );
  }
}
