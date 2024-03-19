import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import '../services/crud.dart';

class UpdateBlog extends StatefulWidget {
  String? id, authorName, title, desc;
  String? imgUrl;
  DateTime selectedDate;
  UpdateBlog(
      {super.key,
      this.id,
      this.authorName,
      this.title,
      this.desc,
      this.imgUrl,
      required this.selectedDate});

  @override
  State<UpdateBlog> createState() => _UpdateBlogState();
}

class _UpdateBlogState extends State<UpdateBlog> {
  final ImagePicker picker = ImagePicker();
  File? selectedImage;
  bool _isLoading = false;

  CrudMethods crudMethods = CrudMethods();

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
        initialDate: widget.selectedDate,
        firstDate: DateTime(2024, 1),
        lastDate: DateTime(2101));
    if (picked != null && picked != widget.selectedDate) {
      setState(() {
        widget.selectedDate = picked;
      });
    }
  }

  updateBlog() async {
    setState(() {
      _isLoading = true;
    });

    Map<String, String> blogMap;

    if (selectedImage == null) {
      blogMap = {
        "author": widget.authorName!,
        "title": widget.title!,
        "description": widget.desc!,
        "date": widget.selectedDate.toString()
      };
    } else {
      /// uploading image to firebase storage
      Reference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child("image")
          .child("${randomAlphaNumeric(9)}.jpg");

      final UploadTask task = firebaseStorageRef.putFile(selectedImage!);

      var downloadUrl =
          await (await task.whenComplete(() => null)).ref.getDownloadURL();

      print("this is url $downloadUrl");

      blogMap = {
        "image": downloadUrl,
        "author": widget.authorName!,
        "title": widget.title!,
        "description": widget.desc!,
        "date": widget.selectedDate.toString()
      };
    }

    crudMethods.updateBlog(widget.id!, blogMap).then((result) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    print("${widget.imgUrl}");

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
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 16),
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
                            : widget.imgUrl != null
                                ? Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    height: 170,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            widget.imgUrl.toString(),
                                          ),
                                          fit: BoxFit.cover,
                                        )),
                                    width: MediaQuery.of(context).size.width,
                                    child: const Icon(
                                      Icons.add_a_photo,
                                      color: Colors.white,
                                    ),
                                  )
                                : Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16),
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
                            controller:
                                TextEditingController(text: widget.authorName),
                            decoration:
                                const InputDecoration(hintText: "Author Name"),
                            onChanged: (val) {
                              widget.authorName = val;
                            },
                          ),
                          TextField(
                            controller:
                                TextEditingController(text: widget.title),
                            decoration:
                                const InputDecoration(hintText: "Title"),
                            onChanged: (val) {
                              widget.title = val;
                            },
                          ),
                          TextField(
                            controller:
                                TextEditingController(text: widget.desc),
                            decoration: const InputDecoration(hintText: "Desc"),
                            onChanged: (val) {
                              widget.desc = val;
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${widget.selectedDate.toLocal()}"
                                    .split(' ')[0]),
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
                          const SizedBox(
                            height: 60,
                          ),
                          Container(
                            width: 200,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                updateBlog();
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Update",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Icon(
                                    Icons.file_upload,
                                    color: Colors.white,
                                  ),
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
