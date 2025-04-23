import 'package:flutter/material.dart';
import 'package:storia/apis/stories.dart';
import 'package:storia/common.dart';
import 'package:storia/models/story.dart';
import 'package:storia/widgets/language_button.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  final Function(String) toStory;

  const HomeScreen({super.key, required this.token, required this.toStory});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StoriesApi _storiesApi;
  late Future<List<Story>> _stories;

  @override
  void initState() {
    super.initState();
    _storiesApi = StoriesApi(widget.token);
    _stories = _storiesApi.all();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.home,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        forceMaterialTransparency: true,
        actions: [const LanguageButton(), const SizedBox(width: 16)],
      ),
      body: FutureBuilder(
        future: _stories,
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

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                AppLocalizations.of(context)!.notFound,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final List<Story> stories = snapshot.data!;

          return ListView.builder(
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final Story story = stories[index];
              return GestureDetector(
                onTap: () {
                  widget.toStory(story.id);
                },
                child: Card(
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
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
                            height: 480,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
