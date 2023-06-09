import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'note.dart';

class EditScreen extends StatefulWidget {
  final Note? note;
  final bool viewMode;
  final bool addMode;

  // static Route route() => MaterialPageRoute(builder: (_) => EditScreen());

  const EditScreen(
      {Key? key, this.note, this.viewMode = false, this.addMode = false})
      : super(key: key);

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title!;
      _descriptionController.text = widget.note!.content!;
    }
  }

  // update Note based on the input
  Future<void> updateNote(Note note) async {
    User? user = FirebaseAuth.instance.currentUser;
    print(' note ' + note.id);
    try {
      await FirebaseFirestore.instance.collection('notes').doc(note.id).update(
        {
          'tittle': note.title,
          'content': note.content,
          'userId': user!.uid,
        },
      );
    } catch (e) {
      print('Error updating note: $e');
    }
  }

  // add Note based on the input
  Future<void> addNote(Note note) async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      await FirebaseFirestore.instance.collection('notes').add(
        {
          'tittle': note.title,
          'content': note.content,
          'userId': user!.uid,
        },
      );
    } catch (e) {
      print('Error adding note: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        centerTitle: true,
        title: Text(widget.viewMode
            ? 'View Note'
            : widget.addMode
                ? 'Add New Note'
                : 'Edit Note'),
        actions: [
          if (!widget.viewMode)
            IconButton(
                icon: const Icon(
                  Icons.check_circle,
                  size: 30,
                ),
                onPressed: () {
                  if (!widget.addMode && !widget.viewMode) {
                    Note note = Note(
                      id: widget.note!.id,
                      title: _titleController.text,
                      content: _descriptionController.text,
                    );
                    updateNote(note);
                  }
                  if (widget.addMode) {
                    Note note = Note(
                      id: '',
                      title: _titleController.text,
                      content: _descriptionController.text,
                    );
                    addNote(note);
                  }
                  // back to home screen with updated note
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HomeScreen(),
                    ),
                  );
                }),
          IconButton(
              icon: const Icon(
                Icons.cancel_sharp,
                size: 30,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              initialValue: null,
              enabled: !(widget.viewMode),
              decoration: const InputDecoration(
                hintText: 'Type the title here',
              ),
              onChanged: (value) {},
            ),
            const SizedBox(
              height: 5,
            ),
            Expanded(
              child: TextFormField(
                  controller: _descriptionController,
                  enabled: !(widget.viewMode),
                  initialValue: null,
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    hintText: 'Type the description',
                  ),
                  onChanged: (value) {}),
            ),
          ],
        ),
      ),
    );
  }
}
