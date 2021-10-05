import 'package:flutter/material.dart';
import 'package:socialapp/utils/myTheme.dart';
import 'package:socialapp/widgets/customAppBar.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  String? username;
  final _formKey = GlobalKey<FormState>();

  void submit() {
    _formKey.currentState!.save();
    Navigator.pop(context, username);
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
        appBar: customAppBar(context, ifAppTitle: false, title: 'SET PROFILE'),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  'create a username',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 40.0),
                child: Container(
                  child: Form(
                      key: _formKey,
                      child: TextFormField(
                        onSaved: (val) {
                          username = val;
                        },
                        maxLines: 1,
                        maxLength: 40,
                        decoration: InputDecoration(
                          labelText: 'username',
                          labelStyle: TextStyle(color: Colors.green),
                          hintStyle: TextStyle(color: Colors.green),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          hintText: 'username must be unique',
                          fillColor: Colors.red,
                          focusColor: Colors.green,
                          border: OutlineInputBorder(
                              // borderRadius: BorderRadius.circular(20),
                              ),
                          // enabledBorder: OutlineInputBorder(
                          //   borderRadius: BorderRadius.circular(20),
                          // ),
                          // focusedBorder: OutlineInputBorder(
                          //   borderRadius: BorderRadius.circular(20.0),
                          //   borderSide: const BorderSide(
                          //     color: Colors.green,
                          //   ),
                          // ),
                        ),
                      )),
                ),
              ),
              InkWell(
                onTap: submit,
                child: Container(
                  height: 40,
                  width: 100.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.blue.shade900,
                  ),
                  child: Center(
                    child: Text(
                      'submit',
                      style: TextStyle(
                          fontSize: 23.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
