import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_notes/models/Note.dart';
import 'package:flutter_secure_notes/components/NoteItem.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../database/database.dart';
class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}
class _HomeState extends State<Home> {
  @override
  void initState() {
    _getAuthenticated();
    super.initState();
  }
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticated = false;
  final db = Database.instance;
  List<Note> notes = [];
  void _updateNotes(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final Note note = notes.removeAt(oldIndex);
      notes.insert(newIndex, note);
      db.deleteAllNotes();
      for (Note note in notes) {
        db.addNote(note.title, note.description, note.date);
      }
    });
  }
  void _swipeHandler(int id) {
    setState(() {
      for (int i = 0; i < notes.length; i++) {
        if (notes[i].id == id) {
          db.deleteNote(notes[i]);
          break;
        }
      }
    });
  }
  Widget _floatingButtonAuth(AppLocalizations? locale) {
    return FloatingActionButton(
      onPressed: () async {
        if (!_isAuthenticated) {
          final bool canAuthWithBiometrics = await _auth.canCheckBiometrics;
          if (canAuthWithBiometrics) {
            try {
              final bool didAuthenticate = await _auth.authenticate(
                  localizedReason: locale?.authenticate_to_see_hidden_notes ?? 'Authenticate to see hidden notes',
                  options: const AuthenticationOptions(biometricOnly: false));
              _setAuthenticated(didAuthenticate);
            } catch (e) {
              String msg = e.toString();
              if(msg.contains('Authentication canceled')){
                msg = 'Authentication canceled';
              }
              if (mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(msg)));
              }
            }
          }
        } else {
          _setAuthenticated(false);
        }
      },
      backgroundColor: Colors.blueAccent,
      child: Icon(
        _isAuthenticated ? Icons.lock : Icons.lock_open,
        color: Colors.white,
      ),
    );
  }
  Future<void> _navigateToNewScreen(BuildContext context) async {
    final bool result = await Navigator.pushNamed(context, '/new_note') as bool;
    if (result) {
      setState(() {
      });
    }
  }
  Future<void> _navigateToEditScreen(BuildContext context, Note note) async {
    final bool result =
    await Navigator.pushNamed(context, '/new_note', arguments: note)
    as bool;
    if (result) {
      setState(() {
      });
    }
  }
  void _deleteAll() async {
    setState(() {
      db.deleteAllNotes();
    });
  }
  Future<void> _getAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    bool? isAuth = prefs.getBool('SECURE_NOTES_IS_AUTHENTICATED');
    isAuth ??= false;
    setState(() {
      _isAuthenticated = isAuth!;
    });
  }
  Future<void> _setAuthenticated(bool isAuth) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('SECURE_NOTES_IS_AUTHENTICATED', isAuth);
    setState(() {
      _isAuthenticated = isAuth;
    });
  }
  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'SecureNotes',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.blueAccent,
              actions: [
                if (_isAuthenticated)
                  PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Row(children: [
                            const Icon(Icons.note_add),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                  locale?.new_note ?? 'New'
                              ),
                            )
                          ]),
                          onTap: (){
                            _navigateToNewScreen(context);
                          },
                        ),
                        PopupMenuItem(
                          onTap: _deleteAll,
                          child: Row(children: [
                            const Icon(Icons.delete),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                  locale?.delete_all ?? 'Delete All'
                              ),
                            )
                          ]),
                        ),
                      ])
              ],
            ),
            body: Padding(
                padding: const EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 0.0),
                child: FutureBuilder(
                    future: db.getAllNotes(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      }
                      notes = snapshot.data as List<Note>;
                      return _isAuthenticated
                          ? notes.isNotEmpty
                          ? ReorderableListView(
                          proxyDecorator: (child, index, animation) =>
                          child,
                          children: [
                            for (final note
                            in snapshot.data as List<Note>)
                              GestureDetector(
                                key: ValueKey(note.id),
                                onTap: () {
                                  _navigateToEditScreen(context, note);
                                },
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 24.0),
                                    child: NoteItem(
                                        note: note,
                                        onSwipe: _swipeHandler)),
                              )
                          ],
                          onReorder: (oldIndex, newIndex) {
                            _updateNotes(oldIndex, newIndex);
                          })
                          : Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 32.0),
                          child: Text(
                            locale?.add_some_notes ?? 'Add some notes!',
                            style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800]),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                          : Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 32.0),
                          child: Text(
                            locale?.authentication_required ?? "Authentication required",
                            style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800]),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    })),
            floatingActionButton: _floatingButtonAuth(locale)));
  }
}