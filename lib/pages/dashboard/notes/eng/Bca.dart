import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class BcaNotesPage extends StatefulWidget {
  const BcaNotesPage({super.key});

  @override
  State<BcaNotesPage> createState() => _BcaNotesPageState();
}

class _BcaNotesPageState extends State<BcaNotesPage> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _hashtagController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  bool isAddingNote = false;
  File? selectedFile;

  final CollectionReference notesCollection =
      FirebaseFirestore.instance.collection('bca_notes');
  final FirebaseStorage storage = FirebaseStorage.instance;

  // Method to pick a PDF file
  Future<void> pickPDFFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      selectedFile = File(result.files.single.path!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF file selected successfully')),
      );
    }
  }

  // Method to upload the PDF to Firebase Storage
  Future<String?> uploadFile(File file) async {
    try {
      String fileName = file.path.split('/').last;
      Reference storageRef = storage.ref().child('bca_notes/$fileName');
      await storageRef.putFile(file);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print("File upload error: $e");
      return null;
    }
  }

  // Method to add a note or file URL to Firestore
  Future<void> addNote() async {
    if (_noteController.text.isNotEmpty || selectedFile != null) {
      String? fileURL;
      if (selectedFile != null) {
        fileURL = await uploadFile(selectedFile!);
      }

      await notesCollection.add({
        'note': _noteController.text.isNotEmpty ? _noteController.text : null,
        'fileURL': fileURL,
        'timestamp': FieldValue.serverTimestamp(),
        'hashtags': _hashtagController.text.isNotEmpty
            ? _hashtagController.text.split(',')
            : [],
      });

      _noteController.clear();
      _hashtagController.clear();
      selectedFile = null;

      setState(() {
        isAddingNote = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a note or select a file')),
      );
    }
  }

  // Method to download the PDF from Firebase Storage and open using flutter_pdfview
  Future<void> openPDFInApp(BuildContext context, String url) async {
    try {
      // Download the PDF file
      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;

      // Get the directory to save the PDF temporarily
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/temp.pdf');

      // Write the PDF to file
      await file.writeAsBytes(bytes, flush: true);

      // Navigate to the PDF Viewer screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerScreen(filePath: file.path),
        ),
      );
    } catch (e) {
      print("Error opening PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to open PDF')),
      );
    }
  }

  // Method to open the PDF externally
  Future<void> openPDFExternally(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Method to delete a note (and file if present)
  Future<void> deleteNote(String documentId, String? fileURL) async {
    try {
      await notesCollection.doc(documentId).delete();
      if (fileURL != null) {
        Reference storageRef = storage.refFromURL(fileURL);
        await storageRef.delete();
      }
    } catch (e) {
      print("Error deleting note or file: $e");
    }
  }

  List<DocumentSnapshot> filterNotes(List<DocumentSnapshot> documents) {
    if (_searchController.text.isEmpty) {
      return documents;
    } else {
      String searchText = _searchController.text.toLowerCase();
      return documents.where((doc) {
        Map<String, dynamic> noteData = doc.data()! as Map<String, dynamic>;
        String? noteText = noteData['note']?.toLowerCase();
        List<dynamic> hashtags = noteData['hashtags'] ?? [];

        return (noteText != null && noteText.contains(searchText)) ||
            hashtags.any((tag) => tag.toString().toLowerCase().contains(searchText));
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BCA Notes"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Search bar for filtering notes
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Search notes or hashtags",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 20),
            if (isAddingNote)
              Column(
                children: [
                  // Input field for adding notes
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: "Add a new note",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  // Input field for hashtags
                  TextField(
                    controller: _hashtagController,
                    decoration: const InputDecoration(
                      labelText: "Add hashtags (comma separated)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: pickPDFFile,
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Select PDF File"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: addNote,
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Add Note or PDF"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: notesCollection.orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Something went wrong"));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final List<DocumentSnapshot> documents = filterNotes(snapshot.data!.docs);

                  if (documents.isEmpty) {
                    return const Center(child: Text("No notes found"));
                  }

                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> noteData =
                          documents[index].data()! as Map<String, dynamic>;

                      String? noteText = noteData['note'];
                      String? fileURL = noteData['fileURL'];
                      Timestamp? timestamp = noteData['timestamp'];
                      List<dynamic> hashtags = noteData['hashtags'] ?? [];
                      String documentId = documents[index].id;

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(noteText ?? 'No note'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(timestamp != null
                                  ? 'Added on: ${timestamp.toDate()}'
                                  : 'No timestamp'),
                              if (hashtags.isNotEmpty)
                                Wrap(
                                  children: hashtags
                                      .map((tag) => Chip(label: Text(tag.toString())))
                                      .toList(),
                                ),
                              if (fileURL != null)
                                Row(
                                  children: [
                                    const Icon(Icons.picture_as_pdf, color: Colors.red),
                                    const SizedBox(width: 8),
                                    TextButton(
                                      onPressed: () => openPDFInApp(context, fileURL),
                                      child: const Text("Open PDF"),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.open_in_new),
                                      onPressed: () => openPDFExternally(fileURL),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              deleteNote(documentId, fileURL);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isAddingNote = !isAddingNote;
          });
        },
        child: Icon(isAddingNote ? Icons.close : Icons.add),
      ),
    );
  }
}

// PDF Viewer Screen
class PDFViewerScreen extends StatelessWidget {
  final String filePath;

  const PDFViewerScreen({required this.filePath, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("View PDF")),
      body: PDFView(
        filePath: filePath,
      ),
    );
  }
}
