import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/screens/homePage.dart';
import 'package:socialapp/widgets/progressbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Imge;
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocode/geocode.dart';

class Upload extends StatefulWidget {
  final UserModel? currentUser;

  Upload({this.currentUser});
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  final ImagePicker _picker = ImagePicker();
  var image;
  bool isUploading = false;
  String postId = Uuid().v4();
  TextEditingController captionController = TextEditingController();

  TextEditingController locationController = TextEditingController();
  //methods
  handledTakePhoto() async {
    print("camera pressed");
    Navigator.pop(context);
    final image = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxHeight: 500, maxWidth: 800);
    setState(() {
      this.image = File(image!.path);
    });
  }

  handledGaleryPhoto() async {
    print("galery pressed");
    Navigator.pop(context);
    final image = await _picker.pickImage(
        source: ImageSource.gallery, maxHeight: 500, maxWidth: 800);
    setState(() {
      this.image = File(image!.path);
    });
  }

  selectImage(BuildContext parent) {
    return showDialog(
        context: parent,
        builder: (context) {
          return SimpleDialog(
            title: Text("create post"),
            children: [
              SimpleDialogOption(
                child: Text(
                  "photo with camera ",
                ),
                onPressed: handledTakePhoto,
              ),
              SimpleDialogOption(
                child: Text("Image from galery"),
                onPressed: handledGaleryPhoto,
              ),
              SimpleDialogOption(
                child: Text("cancle"),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  Container noContent() {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/images/upload.svg",
            height: 200,
          ),
          ElevatedButton(
            onPressed: () {
              selectImage(context);
            },
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Theme.of(context).primaryColor)),
            child: Text(
              "Up load",
              style: TextStyle(fontSize: 25.0),
            ),
          )
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      image = null;
      isUploading = false;
    });
  }

  compressImage() async {
    //path provider for geting path
    final tempData = await getTemporaryDirectory();
    final path = tempData.path;
    //image package for compressing image
    Imge.Image? imageFile = Imge.decodeImage(image.readAsBytesSync());
    final compressedImage = File("$path/img_$postId.jpg")
      ..writeAsBytesSync(Imge.encodeJpg(imageFile!, quality: 85));
    setState(() {
      image = compressedImage;
    });
  }

  //uploading file to firebase storage
  Future<String> upLoadImage(imageFile) async {
    // File file = File(imageFile);

    var data = await ref.child('"post_$postId.jpg"').putFile(imageFile);
    print("sucess");
    String downloadUrl = await data.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore({String? mediaUrl, String? caption, String? location}) {
    postReference.doc(currentUser!.id).collection("userPost").doc(postId).set({
      "postId": postId,
      "ownerId": currentUser!.id,
      "userName": currentUser!.username,
      "mediaUrl": mediaUrl,
      "location": location,
      "description": caption,
      "timestamp": timeStamp,
      "likes": {},
    });
  }

  handelSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String medioUrl = await upLoadImage(image);

    createPostInFirestore(
        mediaUrl: medioUrl,
        caption: captionController.text,
        location: locationController.text);
    captionController.clear();
    locationController.clear();
    setState(() {
      image = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  getUserLocation() async {
  
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);

      GeoCode geoCode = GeoCode();
      Address address = await geoCode.reverseGeocoding(
          latitude: position.latitude, longitude: position.longitude);
      print(address.toString());
      print(
          "${address.streetAddress}, ${address.city}, ${address.countryName}");
      locationController.text =
          "${address.streetAddress}, ${address.city},${address.countryName}";
    } catch (e) {
      print("e");
    }
  }

  buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          onPressed: clearImage,
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        title: Text(
          "Caption Post",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: isUploading ? null : () => handelSubmit(),
            child: Text(
              "post",
              style: TextStyle(fontSize: 20.0),
            ),
          )
        ],
      ),
      body: ListView(
        children: [
          isUploading ? linearProgress() : Text(""),
          Container(
            padding: EdgeInsets.all(10.0),
            decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                child: Image.file(
                  image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 20.0)),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  NetworkImage(widget.currentUser!.photoUrl.toString()),
            ),
            title: TextField(
              controller: captionController,
              decoration: InputDecoration(
                  hintText: "write a caption",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: InputBorder.none),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35.0,
            ),
            title: TextField(
              controller: locationController,
              decoration: InputDecoration(
                  hintText: "where was the photo taken",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: InputBorder.none),
            ),
          ),
          Center(
            child: TextButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Theme.of(context).primaryColor),
              ),
              onPressed: () {
                print("button is pressed");
                getUserLocation();
              },
              child: Text(
                "choose your location",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return image == null ? noContent() : buildUploadForm();
  }
}
