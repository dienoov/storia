import 'package:flutter/material.dart';
import 'package:storia/common.dart';
import 'package:storia/repositories/auth.dart';

class UserButton extends StatelessWidget {
  final String name;
  final Function() onLogout;

  const UserButton({super.key, required this.onLogout, required this.name});

  @override
  Widget build(BuildContext context) {
    final AuthRepository authRepository = AuthRepository();

    return PopupMenuButton<String>(
      icon: CircleAvatar(
        radius: 16,
        child: Text(
          name[0].toUpperCase(),
          style: const TextStyle(fontSize: 16),
        ),
      ),
      onSelected: (value) async {
        if (value == 'logout') {
          await authRepository.logout();
          onLogout();
        }
      },
      itemBuilder:
          (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'logout',
              child: Text(AppLocalizations.of(context)!.logout),
            ),
          ],
    );
  }
}
