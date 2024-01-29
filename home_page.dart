import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tubes2/login_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late QuerySnapshot<Object?> notes; // Change type to QuerySnapshot

  final TextEditingController _textController = TextEditingController();
  late String selectedNoteId;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    // Fetch notes from Cloud Firestore
    final QuerySnapshot<Object?> result =
        await FirebaseFirestore.instance.collection('notes').get();
    setState(() {
      notes = result;
    });
  }

  Future<void> addNote() async {
    // Add a new note to Cloud Firestore
    await FirebaseFirestore.instance.collection('notes').add({
      'text': _textController.text,
    });

    _textController.clear();
    Navigator.of(context).pop(); // Close the add note dialog
    fetchData(); // Refresh the data after adding a new note
  }

  Future<void> deleteNote(String docId) async {
    // Delete a note from Cloud Firestore
    await FirebaseFirestore.instance.collection('notes').doc(docId).delete();
    fetchData(); // Refresh the data after deleting a note
  }

  Future<void> editNote() async {
    // Edit the selected note in Cloud Firestore
    await FirebaseFirestore.instance
        .collection('notes')
        .doc(selectedNoteId)
        .update({
      'text': _textController.text,
    });

    _textController.clear();
    Navigator.of(context).pop(); // Close the edit note dialog
    fetchData(); // Refresh the data after editing a note
  }

  void showEditDialog(String docId, String currentText) {
    selectedNoteId = docId;
    _textController.text = currentText;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Note'),
          content: Column(
            children: [
              TextField(
                controller: _textController,
                decoration: InputDecoration(labelText: 'Note text'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the edit note dialog
              },
              child: Text('Cancel',style: TextStyle(color: Colors.black) ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
              onPressed: editNote,
              child: Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        actions: [
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LoginPage()), // Replace 'YourLoginPage()' with your actual login page instance
                );
              }),
        ],
        centerTitle: true,
        title: const Text("Welcome!"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('notes').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var note =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              return ListTile(
                title: Text(note['text']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        showEditDialog(
                            snapshot.data!.docs[index].id, note['text']);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        deleteNote(snapshot.data!.docs[index].id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Add a new note'),
                content: Column(
                  children: [
                    TextField(
                      controller: _textController,
                      decoration: InputDecoration(labelText: 'Note text'),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the add note dialog
                    },
                    child:
                        Text('Cancel', style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    onPressed: addNote,
                    child: Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: Colors
            .grey, // Set the desired background color for FloatingActionButton
        child: Icon(Icons.add),
      ),
    );
  }
}
