import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_a2z/utils/utils.dart';
import 'package:flutter_firebase_a2z/widgets/round_button.dart';

class AddFireStorePostScreen extends StatefulWidget {
  const AddFireStorePostScreen({Key? key}) : super(key: key);

  @override
  State<AddFireStorePostScreen> createState() => _AddFireStorePostScreenState();
}

class _AddFireStorePostScreenState extends State<AddFireStorePostScreen> {
  final postController = TextEditingController();
  bool loading = false;

  final fireStore = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add FireStore Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            TextFormField(
              maxLines: 4,
              controller: postController,
              decoration: const InputDecoration(
                hintText: 'What is in your mind?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            RoundButton(
              title: 'Add',
              loading: loading,
              onTap: () {
                setState(() {
                  loading = true;
                });

                String id = DateTime.now().millisecondsSinceEpoch.toString();

                fireStore.doc(id).set({
                  'title': postController.text.toString(),
                  'id': id
                }).then((value) {
                  setState(() {
                    loading = false;
                  });
                  Utils().toastMessage('Post added');
                }).onError((error, stackTrace) {
                  Utils().toastMessage(error.toString());
                  setState(() {
                    loading = false;
                  });
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
