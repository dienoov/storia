import 'package:flutter/material.dart';
import 'package:storia/common.dart';
import 'package:storia/models/user.dart';
import 'package:storia/widgets/language_button.dart';
import 'package:storia/widgets/user_button.dart';

class UploadScreen extends StatelessWidget {
  final User user;
  final Function() refresh;

  const UploadScreen({super.key, required this.user, required this.refresh});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.upload,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        forceMaterialTransparency: true,
        actions: [
          const LanguageButton(),
          UserButton(name: user.name, onLogout: refresh),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(child: Text(AppLocalizations.of(context)!.upload)),
    );
  }
}
