import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreDbHelper {
  FireStoreDbHelper._();

  static final FireStoreDbHelper fireStoreDbHelper = FireStoreDbHelper._();

  static final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> insert({required Map<String, dynamic> data}) async {
    DocumentSnapshot<Map<String, dynamic>> counter =
    await db.collection('counter').doc('task_counter').get();
    int id = counter['id'];
    int length = counter['length'];

    await db.collection('task').doc('${++id}').set(data);

    await db.collection('counter').doc('task_counter').update({'id': id});

    await db
        .collection('counter')
        .doc('task_counter')
        .update({'length': ++length});
  }

  Future<void> delete({required String id}) async {
    await db.collection('task').doc(id).delete();

    DocumentSnapshot<Map<String, dynamic>> counter =
    await db.collection('counter').doc('task_counter').get();
    int length = counter['length'];

    await db
        .collection('counter')
        .doc('task_counter')
        .update({'length': --length});
  }

  Future<void> update(
  Map<String, dynamic> data,{required String id}) async {
    await db.collection('task').doc(id).update(data);
  }
}
