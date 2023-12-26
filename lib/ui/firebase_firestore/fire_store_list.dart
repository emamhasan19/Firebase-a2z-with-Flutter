import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_a2z/ui/auth/login_screen.dart';
import 'package:flutter_firebase_a2z/ui/firebase_firestore/add_firestore.dart';
import 'package:flutter_firebase_a2z/utils/utils.dart';

class FireStorePostScreen extends StatefulWidget {
  const FireStorePostScreen({Key? key}) : super(key: key);

  @override
  State<FireStorePostScreen> createState() => _FireStorePostScreenState();
}

class _FireStorePostScreenState extends State<FireStorePostScreen> {
  final auth = FirebaseAuth.instance;

  final fireStore = FirebaseFirestore.instance.collection('users').snapshots();

  CollectionReference ref = FirebaseFirestore.instance.collection('users');

  final editController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FireStore Post'),
        actions: [
          IconButton(
            onPressed: () {
              auth.signOut().then((value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              }).onError((error, stackTrace) {
                Utils().toastMessage(error.toString());
              });
            },
            icon: const Icon(Icons.logout_outlined),
          ),
          const SizedBox(width: 10)
        ],
      ),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: fireStore,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading");
              }

              return Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    editController.text = snapshot.data!.docs[index]['title'];

                    return ListTile(
                      title: Text(snapshot.data!.docs[index]['title']),
                      subtitle: Text(snapshot.data!.docs[index]['id']),
                      trailing: PopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem(
                              child: ListTile(
                                leading: const Icon(Icons.edit),
                                title: const Text('Edit'),
                                onTap: () {
                                  Navigator.pop(context);

                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      String documentId =
                                          snapshot.data!.docs[index]['id'];

                                      editController.text =
                                          snapshot.data!.docs[index]['title'];

                                      return AlertDialog(
                                        title: const Text('Update'),
                                        content: TextField(
                                          controller: editController,
                                          decoration: const InputDecoration(
                                            hintText: 'Edit',
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);

                                              ref.doc(documentId).update({
                                                'title': editController.text
                                                    .toString()
                                              }).then((value) {
                                                Utils().toastMessage(
                                                    'Post Updated');
                                              }).onError((error, stackTrace) {
                                                Utils().toastMessage(
                                                    error.toString());
                                              });
                                            },
                                            child: const Text('Update'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            PopupMenuItem(
                              child: ListTile(
                                leading: const Icon(Icons.delete),
                                title: const Text('Delete'),
                                onTap: () {
                                  Navigator.pop(context);
                                  ref
                                      .doc(snapshot.data!.docs[index]['id'])
                                      .delete();
                                },
                              ),
                            ),
                          ];
                        },
                      ),
                    );
                  },
                ),
              );
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddFireStorePostScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
