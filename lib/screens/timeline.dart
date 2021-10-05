import 'package:flutter/material.dart';
import 'package:socialapp/widgets/customAppBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialapp/widgets/progressbar.dart';

//FirebaseFirestore firestoreinstance = FirebaseFirestore.instance;
final userData = FirebaseFirestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List? user = [];
  @override
  void initState() {
   
    super.initState();
  }

  // createUser() {
  //   userData.doc('abcdekjl').set({
  //     "username": 'ram',
  //     'postCount': 2,
  //     "isAdmin": true,
  //   });
  // }

  // updateUser() async {
  //   final DocumentSnapshot user = await userData.doc('abcdef').get();
  //   if (user.exists) {
  //     user.reference.update({
  //       "username": 'ram sita',
  //       'postCount': 2,
  //       "isAdmin": true,
  //     });
  //   } else {
  //     print('user not exist');
  //   }
  // }

  // deleteUser() async {
  //   final DocumentSnapshot user = await userData.doc('abcdef').get();
  //   if (user.exists) {
  //     user.reference.delete();
  //   } else {
  //     print('user not exist');
  //   }
  // }

  // getUser() async {
  //   final QuerySnapshot snapshot = await userData.get();
  //   setState(() {
  //     user = snapshot.docs;
  //   });
  // }

  // getDocument() async {
  //   try {
  //     await userData.get().then((snapshot) {
  //       snapshot.docs.forEach((result) {
  //         print(result.data());
  //         print(result.id);
  //       });
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  // getUserByRole() async {
  //   final QuerySnapshot doc = await userData
  //       .where("postCount", isGreaterThan: 4)
  //       .where("username", isEqualTo: 'janu')
  //       .get();
  //   doc.docs.forEach((snapshot) {
  //     print(snapshot.data());
  //   });

  //   // doc.data();
  // }

  // getDocumentById() async {
  //   final id = 'OEFvlcWGVNJef1UcWKZF';
  //   final DocumentSnapshot doc = await userData.doc(id).get();
  //   print(doc.exists);
  // }

  // getUsersByOrder() async {
  //   final QuerySnapshot document =
  //       await userData.orderBy("postCount", descending: true).get();
  //   document.docs.forEach((element) {
  //     print(element.data());
  //   });
  // }

  @override
  Widget build(context) {
    return Scaffold(
        appBar: customAppBar(context, ifAppTitle: true),
        body: StreamBuilder<QuerySnapshot>(
          stream: userData.snapshots(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            } else {
              final List<DocumentSnapshot> documents = snapshot.data.docs;
              return ListView(
                  children: documents
                      .map((doc) => Card(
                            child: ListTile(
                              title: Text(doc['username']),
                              subtitle: Text(doc['postCount'].toString()),
                            ),
                          ))
                      .toList());
            }
          },
        ));
  }
}
