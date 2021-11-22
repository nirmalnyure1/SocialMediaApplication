import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:socialapp/screens/post.dart';
import 'package:socialapp/widgets/custom_image.dart';

class PostTile extends StatelessWidget {
  final Post? post;
  PostTile(this.post);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("showing post");
      },
      child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: cachedNetworkImage(post!.mediaUrl)),
    );
  }
}
