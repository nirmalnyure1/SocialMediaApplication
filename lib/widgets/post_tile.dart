import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:socialapp/widgets/post.dart';
import 'package:socialapp/widgets/custom_image.dart';

import '../screens/post_screen.dart';

class PostTile extends StatelessWidget {
  final Post? post;
  PostTile(this.post);

  showPost(context) {
    if (post?.postId != null && post?.ownerId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostScreen(
            postId: post!.postId!,
            userId: post!.ownerId!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showPost(context);
        print("showing post");
      },
      child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: cachedNetworkImage(post!.mediaUrl)),
    );
  }
}
