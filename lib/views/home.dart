import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tech_blog_app/views/update_blog.dart';

import '../services/crud.dart';
import 'create_blog.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CrudMethods crudMethods = CrudMethods();

  Stream? blogsStream;

  Widget BlogsList() {
    return Container(
      child: blogsStream != null
          ? SingleChildScrollView(
              child: StreamBuilder(
                stream: blogsStream,
                builder: (context, snapshot) {
                  print('********************start');

                  if (!snapshot.hasData) {
                    return Center(
                        child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          SizedBox(
                              height: MediaQuery.sizeOf(context).height * 0.35),
                          const CircularProgressIndicator(),
                        ],
                      ),
                    ));
                  } else {
                    final doc = snapshot.data.docs;
                    return doc.length == 0
                        ? Center(
                            child: Column(
                              children: [
                                SizedBox(
                                    height: MediaQuery.sizeOf(context).height *
                                        0.35),
                                const Text(
                                  "No Blogs Found here",
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: doc.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  print(
                                      '***********2*********${snapshot.data.docs.length}');
                                  return BlogsTile(
                                    authorName: doc[index]['author'],
                                    title: doc[index]["title"],
                                    description: doc[index]['description'],
                                    imgUrl: doc[index]['image'],
                                    date: doc[index]['date'],
                                    id: doc[index].id,
                                  );
                                }),
                          );
                  }
                },
              ),
            )
          : Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.35),
                  const CircularProgressIndicator(),
                ],
              ),
            ),
    );
  }

  @override
  void initState() {
    crudMethods.getData().then((result) {
      setState(() {
        blogsStream = result;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Tech",
              style: TextStyle(fontSize: 22, color: Colors.white),
            ),
            Text(
              "Blogs",
              style: TextStyle(fontSize: 22, color: Colors.blue),
            )
          ],
        ),
        backgroundColor: Colors.indigo.shade900,
        elevation: 0.0,
      ),
      body: BlogsList(),
      floatingActionButton: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FloatingActionButton(
              backgroundColor: Colors.indigo.shade900,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CreateBlog()));
              },
              child: const Icon(Icons.add,color: Colors.white,),
            )
          ],
        ),
      ),
    );
  }
}

class BlogsTile extends StatelessWidget {
  String imgUrl, title, description, authorName, date;
  String id;
  BlogsTile({
    required this.imgUrl,
    required this.title,
    required this.description,
    required this.authorName,
    required this.date,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    CrudMethods crudMethods = CrudMethods();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 180,
      child: Stack(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(
              imageUrl: imgUrl,
              placeholder: (context, url) => Container(
                color: Colors.indigo.shade900.withOpacity(0.2),
                height: 180,
                width: MediaQuery.of(context).size.width,
              ),
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            height: 35,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.indigo.shade600,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6), topRight: Radius.circular(6)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: () {
                      print('******************$id');
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => UpdateBlog(id:id,authorName: authorName,title: title,desc: description,imgUrl: imgUrl,selectedDate: DateTime.parse(date),)));


                    },
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    )),
                IconButton(
                    onPressed: () {
                      print('******************$id');

                      crudMethods.deleteBlog(id);
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 20,
                    )),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  height: 10,
                ),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  description,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  authorName,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  DateFormat('dd-MM-yyyy').format(DateTime.parse(date)),
                  style: const TextStyle(color: Colors.white),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
