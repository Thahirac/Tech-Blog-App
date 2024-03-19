import 'package:cloud_firestore/cloud_firestore.dart';

class CrudMethods {
  Future<void> addData(blogData) async {
    FirebaseFirestore.instance
        .collection('blogs')
        .add(blogData)
        .catchError((e) {
      print('Error adding blog: $e');
    });
  }

  getData() async {
    return await FirebaseFirestore.instance.collection("blogs").snapshots();
  }

  Future<void> updateBlog(String id, blogData) async {
    try {
      await FirebaseFirestore.instance
          .collection('blogs')
          .doc(id)
          .update(blogData);
    } catch (e) {
      print('Error updating blog: $e');
    }
  }

  Future<void> deleteBlog(String id) async {
    try {
      await FirebaseFirestore.instance.collection('blogs').doc(id).delete();
    } catch (e) {
      print('Error deleting blog: $e');
    }
  }
}
