// import '';

// class PostModel{
//    final String? postId;
//   final String? ownerId;
//   final String? username;
//   final String? description;
//   final String? mediaUrl;
//   final String? location;
//   final dynamic likes;

//   PostModel(
//       {this.postId,
//       this.ownerId,
//       this.username,
//       this.description,
//       this.mediaUrl,
//       this.location,
//       this.likes});


//    factory PostModel.fromDocument(DocumentSnapshot doc){
//      return PostModel(
       
//          postId:doc["postId"],
//          ownerId: doc["ownerId"],
//          username: doc["username"],
//          description: doc["description"],
//          mediaUrl: doc["mediaUrl"],
//          location: doc["location"],
//          likes: doc["likes"],
       
//      );
//    }   
//   int getLikeCount(){
//      //if like no like, likeCount=0
//      if(likes==null){return 0;}
//      int count=0;
//      likes.values.forEach((val){
//         if(val==true){
//           count+=1;
//         }
//      });
//      return count;
//    }
// }