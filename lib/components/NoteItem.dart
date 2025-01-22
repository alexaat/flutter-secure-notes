import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_notes/models/Note.dart';

class NoteItem extends StatelessWidget {
  final Note note;
  final Function(int id) onSwipe;
  const NoteItem({required this.note, super.key, required this.onSwipe});
  @override
  Widget build(BuildContext context) {
    var dt = DateTime.fromMillisecondsSinceEpoch(note.date);
    final formatted = DateFormat.yMd().format(dt);
    return Dismissible(
      key: ValueKey('${note.date}'),
      onDismissed: (direction) => onSwipe(note.id),
      child: Container(
        padding:  const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            border: Border.all(
                color: Colors.grey.shade400,
                width: 1.0
            ),
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                offset: const Offset(
                  4.0,
                  4.0,
                ),
                blurRadius: 4.0,
                spreadRadius: 2.0,
              ),
            ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  note.title,
                  style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0
                  ),
                ),
                Text(
                  formatted,
                  style: const TextStyle(
                      fontSize: 14.0
                  ),
                )
              ],
            ),
            const SizedBox(height: 4.0),
            Text(
                note.description,
                style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.grey.shade500
                )
            )
          ],
        ),
      ),
    );
  }
}
