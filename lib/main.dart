import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storia/common.dart';
import 'package:storia/providers/localization.dart';
import 'package:storia/repositories/auth.dart';
import 'package:storia/router/parser.dart';
import 'package:storia/router/router.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => LocalizationProvider(),
      child: const Storia(),
    ),
  );
}

class Storia extends StatefulWidget {
  const Storia({super.key});

  @override
  State<Storia> createState() => _StoriaState();
}

class _StoriaState extends State<Storia> {
  late StoriaRouter storiaRouter;
  late StoriaRouteParser storiaRouteParser;

  @override
  void initState() {
    super.initState();
    storiaRouter = StoriaRouter(AuthRepository());
    storiaRouteParser = StoriaRouteParser();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Storia',
      locale: context
          .watch<LocalizationProvider>()
          .locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Color(0xFF3A7EB7)
        ),
        textTheme: GoogleFonts.dmSansTextTheme(),
      ),
      routerDelegate: storiaRouter,
      routeInformationParser: storiaRouteParser,
      backButtonDispatcher: RootBackButtonDispatcher(),
    );
  }
}
