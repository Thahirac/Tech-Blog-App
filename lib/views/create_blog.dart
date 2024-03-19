import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import '../services/crud.dart';


class CreateBlog extends StatefulWidget {
  @override
  _CreateBlogState createState() => _CreateBlogState();
}

class _CreateBlogState extends State<CreateBlog> {
  String? authorName, title, desc;
  DateTime selectedDate = DateTime.now();

  final ImagePicker picker = ImagePicker();
  File? selectedImage;
  bool _isLoading = false;

  CrudMethods crudMethods =  CrudMethods();

  Future getImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2024, 1),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  uploadBlog() async {
    if (selectedImage != null) {
      setState(() {
        _isLoading = true;
      });

      /// uploading image to firebase storage
      Reference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child("image")
          .child("${randomAlphaNumeric(9)}.jpg");

      final UploadTask task = firebaseStorageRef.putFile(selectedImage!);

      var downloadUrl = await (await task.whenComplete(() => null)).ref.getDownloadURL();


      Map<String, String> blogMap = {
        "image": downloadUrl,
        "author": authorName!,
        "title": title!,
        "description": desc!,
        "date": selectedDate.toString()
      };
      crudMethods.addData(blogMap).then((result) {
        Navigator.pop(context);
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _isLoading
          ? Container(
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      )
          : SingleChildScrollView(
            child: Container(
                    child: Column(
            children: <Widget>[
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                  onTap: () {
                    getImage();
                  },
                  child: selectedImage != null
                      ? Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    height: 170,
                    width: MediaQuery.of(context).size.width,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(
                        selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                      : Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    height: 170,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6)),
                    width: MediaQuery.of(context).size.width,
                    child: const Icon(
                      Icons.add_a_photo,
                      color: Colors.black45,
                    ),
                  )),
              const SizedBox(
                height: 8,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: <Widget>[
                    TextField(
                      decoration: const InputDecoration(hintText: "Author Name"),
                      onChanged: (val) {
                        authorName = val;
                      },
                    ),
                    TextField(
                      decoration: const InputDecoration(hintText: "Title"),
                      onChanged: (val) {
                        title = val;
                      },
                    ),
                    TextField(
                      decoration: const InputDecoration(hintText: "Desc"),
                      onChanged: (val) {
                        desc = val;
                      },
                    ),




                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          Text("${selectedDate.toLocal()}".split(' ')[0]),
                          ElevatedButton(
                            onPressed: () => _selectDate(context),
                            child: const Row(
                              children: [
                                Text('Select date'),
                              ],
                            ),
                          ),

                        ],
                      ),
                    ),




                    const SizedBox(height: 60,),


                    Container(
                      width: 200,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {

                          uploadBlog();
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Upload",style: TextStyle(color: Colors.white),),
                            SizedBox(width: 8,),
                            Icon(Icons.file_upload,color: Colors.white,),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.shade900,
                        ),
                      ),
                    ),




                  ],
                ),
              )
            ],
                    ),
                  ),
          ),
    );
  }
}