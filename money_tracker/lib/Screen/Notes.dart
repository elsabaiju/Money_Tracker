import 'package:money_tracker/Screen/addNotes.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Notes extends StatefulWidget {
  const Notes({super.key});

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  List<Map<String, dynamic>> notes = [];
  late int userid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0075DB),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/dashboard'),
        ),
        title: const Text(
          'Notes',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 255, 255)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: notes.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notes_outlined,
                        size: 64, color: Colors.white.withOpacity(0.8)),
                    const SizedBox(height: 16),
                    Text(
                      'No notes yet',
                      style: TextStyle(
                          fontSize: 20, color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  String formattedDate = notes[index]['date'] != null &&
                          notes[index]['date'].isNotEmpty
                      ? DateFormat('yyyy-MM-dd')
                          .format(DateTime.parse(notes[index]['date']))
                      : '';
                  String fullNote = notes[index]['notes'];
                  List<String> words = fullNote.split(' ');
                  String shortNote = words.length > 4
                      ? '${words.sublist(0, 4).join(' ')}...'
                      : fullNote;

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: const EdgeInsets.only(bottom: 12.0),
                    elevation: 5,
                    color: Colors.white,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0288D1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.notes_outlined,
                            color: Color(0xFF0288D1)),
                      ),
                      title: Text(
                        shortNote,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            formattedDate,
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? noteAdded = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const Addnotes()),
          );
          if (noteAdded != null && noteAdded) {
            fetchNotes();
          }
        },
        backgroundColor: const Color(0xFF0075DB),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }

  Future<void> fetchNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userid = prefs.getInt('user_id') ?? 0;

    String url = 'https://localhost:7007/api/Note/byuserid?userId=$userid';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        try {
          List<dynamic> data = jsonDecode(response.body);
          setState(() {
            notes = data
                .map((note) => {
                      'notes': note['notes'].toString(),
                      'date': note['date'] ?? '',
                    })
                .toList();
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error parsing response: $e')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load notes')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }
}
