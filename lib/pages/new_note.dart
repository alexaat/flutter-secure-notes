import 'package:flutter/material.dart';
import 'package:flutter_secure_notes/database/database.dart';
import 'package:flutter_secure_notes/models/Note.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
class NewNote extends StatefulWidget {
  const NewNote({super.key});
  @override
  State<NewNote> createState() => _NewNoteState();
}
class _NewNoteState extends State<NewNote> {
  final db = Database.instance;
  final _formGlobalKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  void saveNote() async {
    db.addNote(_title, _description, DateTime.now().millisecondsSinceEpoch);
  }
  void updateNote(int id) async {
    db.updateNote(Note(
        id: id,
        title: _title,
        description: _description,
        date: DateTime.now().millisecondsSinceEpoch));
  }
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    final Note? note = args == null ? null : args as Note;
    if (note != null) {
      setState(() {
        _title = note.title;
        _description = note.description;
      });
    }
    final locale = AppLocalizations.of(context);
    final newNoteSubtitle = locale?.new_note ?? "New";
    final editNoteSubtitle = locale?.new_note ?? "Edit";
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              iconTheme: const IconThemeData(
                color: Colors.white, //change your color here
              ),
              title: Text(
                note == null ? 'SecureNotes | $newNoteSubtitle' : 'SecureNotes | $editNoteSubtitle',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.blueAccent,
            ),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 0.0),
              child: Form(
                  key: _formGlobalKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(), label: Text(
                            locale?.title ?? 'Title'
                        )),
                        validator: (v) {
                          if (v.toString().isEmpty) {
                            return locale?.title_is_required ?? 'Title is required';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _title = value!;
                        },
                        initialValue: _title,
                      ),
                      const SizedBox(height: 32.0),
                      TextFormField(
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            label: Text(
                                locale?.description ?? 'Description'
                            )),
                        validator: (v) {
                          if (v.toString().isEmpty) {
                            return locale?.description_is_required ?? 'Description is required';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _description = value!;
                        },
                        initialValue: _description,
                      ),
                      const SizedBox(height: 32.0),
                      FilledButton(
                          onPressed: () {
                            if (_formGlobalKey.currentState!.validate()) {
                              _formGlobalKey.currentState!.save();
                              note == null ? saveNote() : updateNote(note.id);
                              Navigator.pop(context, true);
                            }
                          },
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6.0)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32.0, vertical: 8.0)),
                          child: Text(
                            locale?.save ?? 'SAVE',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ))
                    ],
                  )),
            )));
  }
}