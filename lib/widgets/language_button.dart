import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storia/common.dart';
import 'package:storia/providers/localization.dart';

class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.language),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (_) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.selectLanguage,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.selectLanguageDescription,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(190),
                    ),
                  ),
                  const SizedBox(height: 32),
                  RadioListTile(
                    title: Text('English'),
                    value: 'en',
                    groupValue:
                        context
                            .read<LocalizationProvider>()
                            .locale
                            .languageCode,
                    onChanged: (value) {
                      context.read<LocalizationProvider>().locale = Locale(
                        value!,
                      );
                      Navigator.pop(context);
                    },
                  ),
                  RadioListTile(
                    title: Text('Bahasa Indonesia'),
                    value: 'id',
                    groupValue:
                        context
                            .read<LocalizationProvider>()
                            .locale
                            .languageCode,
                    onChanged: (value) {
                      context.read<LocalizationProvider>().locale = Locale(
                        value!,
                      );
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
