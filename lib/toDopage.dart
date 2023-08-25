// ignore_for_file: prefer_const_constructors, unnecessary_cast

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp2/api.dart';

class ToDoPage extends StatefulWidget {
  const ToDoPage(
      {super.key, required this.toDoPageId, required this.toDoPageTitle});
  final String toDoPageId;
  final String toDoPageTitle;
  @override
  State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  final toDoController = TextEditingController();
  final updateController = TextEditingController();
  CollectionReference get getTodo => API.firestore
      .collection('toDoPages')
      .doc(widget.toDoPageId)
      .collection('toDos');

  void addToDo() {
    getTodo.add({
      'title': toDoController.text,
      'time': DateTime.now().microsecondsSinceEpoch,
    });
  }

  void updateToDo(docId) {
    getTodo.doc(docId).update({
      'title': updateController.text,
    });
  }

  void removeToDo(docId) {
    getTodo.doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.toDoPageTitle),
        centerTitle: true,
      ),
      body: Center(
        child: FutureBuilder(
            future: getTodo.orderBy('time', descending: true).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                return Text('No data');
              } else if (snapshot.hasError) {
                return Text('Error');
              }
              return SizedBox(
                height: 400,
                child: ListView(
                  children: snapshot.data!.docs.map((document) {
                    Map<String, dynamic> toDos =
                        document.data() as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            toDos['title'],
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  updateController.text = toDos['title'];
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('Update the title'),
                                              TextField(
                                                controller: updateController,
                                              ),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    updateToDo(document.id);
                                                    Navigator.of(context).pop();
                                                    updateController.text = '';
                                                    setState(() {});
                                                  },
                                                  child: Text('Update'))
                                            ],
                                          ),
                                        );
                                      });
                                },
                                child: Text('Update'),
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
                                            padding: const EdgeInsets.all(15),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text('Are you sure'),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    removeToDo(document.id);
                                                    Navigator.of(context).pop();
                                                    setState(() {});
                                                  },
                                                  child: Text('Confirm'),
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
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "btn2",
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Add todo'),
                        TextField(
                          controller: toDoController,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            addToDo();
                            toDoController.text = '';
                            Navigator.of(context).pop();
                            setState(() {});
                          },
                          child: Text('Add this todo'),
                        ),
                      ],
                    ),
                  ),
                );
              });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
