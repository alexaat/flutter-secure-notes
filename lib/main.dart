import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_notes/pages/home.dart';
import 'package:flutter_secure_notes/pages/new_note.dart';
import 'l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
void main() {
  runApp(MaterialApp(
    initialRoute: '/home',
    routes: {
      '/home': (context) => const Home(),
      '/new_note': (context) => const NewNote(),
    },
    supportedLocales: L10n.all,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate
    ],
  ));
}