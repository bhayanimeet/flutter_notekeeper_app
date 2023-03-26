import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helper/firebase_db_helper.dart';
import '../../helper/firebase_login_helper.dart';
import '../../helper/localPushNotificationHelper.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<FormState> insertKey = GlobalKey<FormState>();
  GlobalKey<FormState> updateKey = GlobalKey<FormState>();

  TextEditingController titleController = TextEditingController();
  TextEditingController taskController = TextEditingController();

  String? title;
  String? task;
  String? time;
  String? myTime;
  String? myDate;
  bool isCompleted = false;

  String showTime =
      "${DateTime.now().toString().split(':')[0]}:${DateTime.now().toString().split(':')[1]}";

  DateTime picker = DateTime.now();
  int day = DateTime.now().day;
  int month = DateTime.now().month;
  int year = DateTime.now().year;
  int hour = DateTime.now().hour;
  int minute = DateTime.now().minute;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Notekeeper App",
            style: GoogleFonts.arya(color: Colors.white, fontSize: 26)),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () async {
              await FirebaseHelper.firebaseHelper.signOut();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLogged', false);
              setState(() {
                Navigator.pushNamedAndRemoveUntil(
                    context, 'loginPage', (route) => false);
              });
            },
            child: const Icon(
              Icons.power_settings_new_sharp,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 10),
        ],
        backgroundColor: Colors.indigo.shade600,
      ),
      body: StreamBuilder(
        stream: FireStoreDbHelper.db.collection('task').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error : ${snapshot.error}"),
            );
          }
          else if (snapshot.hasData) {
            QuerySnapshot<Map<String, dynamic>> data =
                snapshot.data as QuerySnapshot<Map<String, dynamic>>;
            allDocs = data.docs;
            return ListView.builder(
              itemCount: allDocs.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, i) => Card(
                elevation: 3,
                child: Slidable(
                  startActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    extentRatio: 0.31,
                    children: [
                      const SizedBox(width: 8),
                      Text(
                        "${allDocs[i].data()['date']}",
                        style: GoogleFonts.arya(
                          fontWeight: FontWeight.w500,
                          fontSize: 19,
                        ),
                      ),
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    extentRatio: 0.28,
                    children: [
                      IconButton(
                        onPressed: () {
                          updateData(allDocs: allDocs, index: i);
                        },
                        icon: const Icon(Icons.edit,
                            color: Colors.green, size: 30),
                      ),
                      IconButton(
                        onPressed: () async {
                          await FireStoreDbHelper.fireStoreDbHelper
                              .delete(id: allDocs[i].id);
                        },
                        icon: const Icon(Icons.delete,
                            color: Colors.red, size: 30),
                      ),
                    ],
                  ),
                  child: Container(
                    height: 130,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () async {
                                if (allDocs[i].data()['selected'] == false) {
                                  setState(() {
                                    isCompleted = false;
                                  });
                                  await FireStoreDbHelper.db
                                      .collection('task')
                                      .doc(allDocs[i].id)
                                      .update({'selected': true});
                                } else if (allDocs[i].data()['selected'] ==
                                    true) {
                                  setState(() {
                                    isCompleted = true;
                                  });
                                  await FireStoreDbHelper.db
                                      .collection('task')
                                      .doc(allDocs[i].id)
                                      .update({'selected': false});
                                }
                              },
                              child: (allDocs[i].data()['selected'] == false)
                                  ? Container(
                                      height: 30,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 1,
                                          color: Colors.black,
                                        ),
                                        shape: BoxShape.circle,
                                        color: Colors.transparent,
                                      ),
                                      child: const Icon(
                                        Icons.done,
                                        color: Colors.transparent,
                                        size: 25,
                                      ),
                                    )
                                  : Container(
                                      height: 30,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 1,
                                          color: Colors.transparent,
                                        ),
                                        shape: BoxShape.circle,
                                        color: Colors.green,
                                      ),
                                      child: const Icon(
                                        Icons.done,
                                        color: Colors.white,
                                        size: 25,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 12,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  (allDocs[i].data()['selected'] == false)
                                      ? Text(
                                          "${allDocs[i].data()['title']}",
                                          style: GoogleFonts.lato(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        )
                                      : Text(
                                          "${allDocs[i].data()['title']}",
                                          style: GoogleFonts.lato(
                                            fontSize: 30,
                                            decoration:
                                                TextDecoration.lineThrough,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                  Container(
                                    height: 85,
                                    width: 240,
                                    color: Colors.grey.shade300,
                                    child: (allDocs[i].data()['selected'] ==
                                            false)
                                        ? Text(
                                            "${allDocs[i].data()['task']}",
                                            style: GoogleFonts.lato(
                                              fontSize: 25,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          )
                                        : Text(
                                            "${allDocs[i].data()['task']}",
                                            style: GoogleFonts.lato(
                                              fontSize: 25,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: Text(
                              "${allDocs[i].data()['time']}\n ${(hour <= 12) ? "AM" : 'PM'}",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.arya(
                                fontWeight: FontWeight.w600,
                                fontSize: 19,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          return Center(
            child: LoadingAnimationWidget.discreteCircle(
              color: Colors.indigo,
              size: 40,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: () {
          setState(() {
            showTime =
                "${DateTime.now().toString().split(':')[0]}:${DateTime.now().toString().split(':')[1]}";
          });
          addData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  addData() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        alignment: Alignment.center,
        title: Center(
          child: Text(
            "Add Task",
            style: GoogleFonts.arya(fontSize: 30, fontWeight: FontWeight.w600),
          ),
        ),
        content: StatefulBuilder(builder: (context, setState) {
          return Form(
            key: insertKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                TextFormField(
                  controller: titleController,
                  style: GoogleFonts.play(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  enableSuggestions: true,
                  textInputAction: TextInputAction.next,
                  onSaved: (val) {
                    setState(() {
                      title = val;
                    });
                  },
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Enter your task title...";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1)),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1)),
                    focusColor: Colors.white,
                    hintText: "Enter your task title",
                    hintStyle: GoogleFonts.play(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    labelText: "Title",
                    labelStyle:
                        GoogleFonts.arya(fontSize: 25, color: Colors.black),
                    errorStyle: GoogleFonts.play(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: taskController,
                  style: GoogleFonts.play(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  enableSuggestions: true,
                  textInputAction: TextInputAction.next,
                  onSaved: (val) {
                    setState(() {
                      task = val;
                    });
                  },
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Enter your task...";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1)),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1)),
                    focusColor: Colors.white,
                    hintText: "Enter your task",
                    hintStyle: GoogleFonts.play(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    labelText: "Task",
                    labelStyle:
                        GoogleFonts.arya(fontSize: 25, color: Colors.black),
                    errorStyle: GoogleFonts.play(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (context) => SizedBox(
                          height: 280,
                          child: CupertinoDatePicker(
                            initialDateTime: DateTime.now(),
                            backgroundColor: Colors.grey.shade300,
                            onDateTimeChanged: (DateTime dateTime) {
                              setState(() {
                                picker = dateTime;
                                day = picker.day;
                                month = picker.month;
                                year = picker.year;
                                hour = picker.hour;
                                minute = picker.minute;

                                myTime = "$hour:$minute";
                                myDate = "$day/$month/$year";

                                if (showTime ==
                                    "${DateTime.now().toString().split(':')[0]}:${DateTime.now().toString().split(':')[1]}") {
                                  showTime =
                                      "${DateTime.now().toString().split(':')[0]}:${DateTime.now().toString().split(':')[1]}";
                                } else {
                                  setState(() {
                                    showTime = "$myDate $myTime";
                                  });
                                }
                              });
                            },
                            use24hFormat: true,
                            minimumYear: 2023,
                            maximumYear: 3000,
                          ),
                        ),
                      );
                    });
                  },
                  child: Container(
                    height: 70,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: StatefulBuilder(builder: (context, setState) {
                      return Text(
                        showTime,
                        style: GoogleFonts.play(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        }),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (insertKey.currentState!.validate()) {
                insertKey.currentState!.save();

                Map<String, dynamic> data = {
                  'title': title!,
                  'task': task!,
                  'time': myTime,
                  'date': myDate,
                  'selected': isCompleted,
                };

                FireStoreDbHelper.fireStoreDbHelper.insert(data: data);

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Swipe right to edit or delete",
                      style: GoogleFonts.play(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.indigo,
                    behavior: SnackBarBehavior.floating,
                  ),
                );

                await LocalPushNotificationHelper.localPushNotificationHelper
                    .showSimpleNotification();
              }
              setState(() {
                titleController.clear();
                taskController.clear();
                title = null;
                task = null;
                myTime = null;
                myDate = null;
              });
            },
            child: const Text("Insert"),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                titleController.clear();
                taskController.clear();
                title = null;
                task = null;
                myTime = null;
                myDate = null;
              });
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  updateData(
      {required List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs,
      required int index}) {
    titleController.text = allDocs[index].data()['title'];
    taskController.text = allDocs[index].data()['task'];
    myTime = allDocs[index].data()['time'];
    myDate = allDocs[index].data()['date'];

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text(
            "Update Task",
            style: GoogleFonts.arya(fontSize: 30, fontWeight: FontWeight.w600),
          ),
        ),
        content: StatefulBuilder(builder: (context, setState) {
          return Form(
            key: updateKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                TextFormField(
                  controller: titleController,
                  style: GoogleFonts.play(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  enableSuggestions: true,
                  textInputAction: TextInputAction.next,
                  onSaved: (val) {
                    setState(() {
                      title = val;
                    });
                  },
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Enter your task title...";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1)),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1)),
                    focusColor: Colors.white,
                    hintText: "Enter your task title",
                    hintStyle: GoogleFonts.play(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    labelText: "Title",
                    labelStyle:
                        GoogleFonts.arya(fontSize: 25, color: Colors.black),
                    errorStyle: GoogleFonts.play(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: taskController,
                  style: GoogleFonts.play(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  enableSuggestions: true,
                  textInputAction: TextInputAction.next,
                  onSaved: (val) {
                    setState(() {
                      task = val;
                    });
                  },
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Enter your task...";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1)),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1)),
                    focusColor: Colors.white,
                    hintText: "Enter your task",
                    hintStyle: GoogleFonts.play(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    labelText: "Task",
                    labelStyle:
                        GoogleFonts.arya(fontSize: 25, color: Colors.black),
                    errorStyle: GoogleFonts.play(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (context) => SizedBox(
                          height: 280,
                          child: CupertinoDatePicker(
                            initialDateTime: DateTime.now(),
                            backgroundColor: Colors.grey.shade300,
                            onDateTimeChanged: (DateTime dateTime) {
                              setState(() {
                                picker = dateTime;
                                day = picker.day;
                                month = picker.month;
                                year = picker.year;
                                hour = picker.hour;
                                minute = picker.minute;

                                myTime = "$hour:$minute";
                                myDate = "$day/$month/$year";
                              });
                            },
                            use24hFormat: true,
                            minimumYear: 2023,
                            maximumYear: 3000,
                          ),
                        ),
                      );
                    });
                  },
                  child: Container(
                    height: 70,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Text(
                      "$myDate $myTime",
                      style: GoogleFonts.play(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (updateKey.currentState!.validate()) {
                updateKey.currentState!.save();

                Map<String, dynamic> data = {
                  'title': title!,
                  'task': task!,
                  'time': myTime,
                  'date': myDate,
                  'selected': isCompleted,
                };

                FireStoreDbHelper.fireStoreDbHelper
                    .update(data, id: allDocs[index].id);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Swipe right to edit or delete",
                      style: GoogleFonts.play(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.indigo,
                    behavior: SnackBarBehavior.floating,
                  ),
                );

                await LocalPushNotificationHelper.localPushNotificationHelper
                    .showSimpleNotification1();
              }
              setState(() {
                titleController.clear();
                taskController.clear();
                title = null;
                task = null;
                myTime = null;
                myDate = null;
              });
            },
            child: const Text("Update"),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                titleController.clear();
                taskController.clear();
                title = null;
                task = null;
                myTime = null;
                myDate = null;
              });
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }
}
