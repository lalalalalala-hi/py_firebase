import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:py_firebase/edit_screen.dart';
import 'package:py_firebase/note.dart';

class HomeScreen extends StatefulWidget {
  static Route route() => MaterialPageRoute(builder: (_) => const HomeScreen());

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  // Variable to track whether to show or hide notes' content
  bool showContent = true;
  Map<String, bool> showEditingTools = {};
  bool showEditTools = false;

  Future<List<Note>> getNotes() async {
    List<Note> notes = [];

    if (user?.uid != null) {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('notes')
              .where('userId', isEqualTo: user!.uid)
              .get();

      notes = querySnapshot.docs
          .map((doc) => Note(
                id: doc.id,
                title: doc['tittle'],
                content: doc['content'],
              ))
          .toList();
    }

    return notes;
  }

  Future<void> deleteNote(String title) async {
    try {
      await FirebaseFirestore.instance
          .collection('notes')
          .where('tittle', isEqualTo: title)
          .get()
          .then((snapshot) {
        snapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });
    } catch (e) {
      print('Error deleteing note: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Note>>(
      future: getNotes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('My Notes'),
              actions: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade200,
                  child: Text(
                    '0',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 22.0),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('My Notes'),
              actions: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade200,
                  child: Text(
                    '0',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 22.0),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasData) {
          List<Note> notes = snapshot.data!;

          return Scaffold(
            appBar: AppBar(
              title: const Text('My Notes'),
              actions: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade200,
                  child: Text(
                    notes.length.toString(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 22.0),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
            body: ListView.separated(
              itemCount: notes.length,
              separatorBuilder: (context, index) => const Divider(
                color: Colors.blueGrey,
              ),
              itemBuilder: (context, index) {
                Note note = notes[index];
                String title = note.title ?? '';
                String content = note.content ?? '';
                String displayedContent = showContent ? content : '';
                bool isEditingToolsVisible = showEditingTools[title] ?? false;

                return ListTile(
                  trailing: isEditingToolsVisible
                      ? SizedBox(
                          width: 110.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  // go to edit screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditScreen(
                                              note: note,
                                              viewMode: false,
                                            )),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.blue),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext dialogContext) {
                                        return AlertDialog(
                                          title: const Text('Delete note?'),
                                          content: const Text(
                                              'Are you sure you want to delete this note?'),
                                          actions: [
                                            TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(dialogContext)
                                                    .pop(); // Dismiss alert dialog
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('Delete'),
                                              onPressed: () {
                                                deleteNote(title).then((_) {
                                                  setState(() {
                                                    getNotes();
                                                  });
                                                }); // Delete note
                                                Navigator.of(dialogContext)
                                                    .pop(); // Dismiss alert dialog
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                },
                              ),
                            ],
                          ))
                      : null,
                  title: GestureDetector(
                    child: Text(title),
                    onTap: () {
                      // view content of note in a new screen
                    },
                    onLongPress: () {
                      setState(() {
                        showEditingTools = {
                          title: !isEditingToolsVisible,
                        }; // Toggle the showContent variable
                      });
                    },
                  ),
                  subtitle: Text(displayedContent),
                  onTap: () {
                    // go to new class
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditScreen(
                          note: note,
                          viewMode: true,
                        ),
                      ),
                    );
                  },
                  onLongPress: () {},
                );
              },
            ),
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'show',
                  child: showContent
                      ? const Icon(Icons.menu)
                      : const Icon(Icons.menu_open),
                  tooltip: showContent
                      ? 'Show less. Hide notes content'
                      : 'Show more. Display notes content',
                  onPressed: () {
                    setState(() {
                      showContent =
                          !showContent; // Toggle the showContent variable
                    });
                  },
                ),
                FloatingActionButton(
                  heroTag: 'add',
                  child: const Icon(Icons.add),
                  tooltip: 'Add a new note',
                  onPressed: () {
                    // go to edit screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditScreen(
                          addMode: true,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }

        // Default return statement
        return const SizedBox();
      },
    );
  }
}
