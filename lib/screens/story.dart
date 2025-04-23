import 'package:flutter/material.dart';
import 'package:storia/apis/stories.dart';
import 'package:storia/common.dart';
import 'package:storia/models/story.dart';
import 'package:storia/widgets/language_button.dart';

class StoryScreen extends StatefulWidget {
  final String token;
  final String id;

  const StoryScreen({super.key, required this.token, required this.id});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  late StoriesApi _storiesApi;
  late Future<Story> _story;

  @override
  void initState() {
    super.initState();
    _storiesApi = StoriesApi(widget.token);
    _story = _storiesApi.detail(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.story,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        forceMaterialTransparency: true,
        actions: const [LanguageButton(), SizedBox(width: 16)],
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: _story,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  snapshot.error.toString(),
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (!snapshot.hasData) {
              return Center(
                child: Text(AppLocalizations.of(context)!.notFound),
              );
            }

            final Story story = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        child: Text(story.name[0].toUpperCase()),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        story.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      story.photoUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    story.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
