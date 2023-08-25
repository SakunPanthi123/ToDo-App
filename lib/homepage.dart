// ignore_for_file: prefer_const_constructors, unnecessary_cast

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp2/api.dart';
import 'package:myapp2/toDopage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CollectionReference get toDoPage => API.firestore.collection('toDoPages');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo pages'),
      ),
      body: FutureBuilder(
          future: API.firestore.collection('toDoPages').get(),
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error'),
              );
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text('No data'),
              );
            }
            return Center(
              child: SizedBox(
                height: 500,
                child: ListView(
                  children: snapshot.data!.docs.map((document) {
                    Future<int> toDoCount(String docId) async {
                      QuerySnapshot toDoCount = await API.firestore
                          .collection('toDoPages')
                          .doc(docId)
                          .collection('toDos')
                          .get();
                      return toDoCount.size;
                    }

                    Map<String, dynamic> toDoPages =
                        document.data() as Map<String, dynamic>;
                    return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) => ToDoPage(
                                    toDoPageId: document.id,
                                    toDoPageTitle: toDoPages['title'],
                                  )));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                color: Colors.green[100],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      toDoPages['title'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        FutureBuilder(
                                            future: toDoCount(document.id),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return CircularProgressIndicator();
                                              }
                                              return Text(
                                                  '${snapshot.data.toString()}  ToDos');
                                            }),
                                        Row(
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                final updatePageController =
                                                    TextEditingController();
                                                updatePageController.text =
                                                    toDoPages['title'];
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return Dialog(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(15),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Text(
                                                                  'Change Page Name'),
                                                              TextField(
                                                                controller:
                                                                    updatePageController,
                                                              ),
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  toDoPage
                                                                      .doc(document
                                                                          .id)
                                                                      .update({
                                                                    'title':
                                                                        updatePageController
                                                                            .text,
                                                                  });
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  updatePageController
                                                                      .text = '';
                                                                  setState(
                                                                      () {});
                                                                },
                                                                child: Text(
                                                                    'Confirm'),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    });
                                              },
                                              child: Text('Update Title'),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return Dialog(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(15),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Text(
                                                                  'Confirm delete?'),
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  toDoPage
                                                                      .doc(document
                                                                          .id)
                                                                      .delete();
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  setState(
                                                                      () {});
                                                                },
                                                                child: Text(
                                                                    'Confirm'),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    });
                                              },
                                              child: Icon(Icons.delete),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )),
                        ));
                  }).toList(),
                ),
              ),
            );
          })),
      floatingActionButton: FloatingActionButton(
        heroTag: "btn1",
        onPressed: () {
          final toDoPageController = TextEditingController();
          showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Create a new todo page'),
                      TextField(
                        controller: toDoPageController,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          toDoPage.add({"title": toDoPageController.text});
                          Navigator.of(context).pop();
                          toDoPageController.text = '';
                          setState(() {});
                        },
                        child: Text('Create this page'),
                      )
                    ],
                  ),
                );
              });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
