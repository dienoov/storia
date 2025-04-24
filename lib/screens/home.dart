import 'package:flutter/material.dart';
import 'package:storia/apis/stories.dart';
import 'package:storia/common.dart';
import 'package:storia/models/story.dart';
import 'package:storia/models/user.dart';
import 'package:storia/widgets/language_button.dart';
import 'package:storia/widgets/user_button.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  final Function(String) toStory;
  final Function() refresh;
  final Function() toUpload;

  const HomeScreen({
    super.key,
    required this.user,
    required this.toStory,
    required this.refresh,
    required this.toUpload,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StoriesApi _storiesApi;
  late Future<List<Story>> _stories;

  @override
  void initState() {
    super.initState();
    _storiesApi = StoriesApi(widget.user.token);
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
        actions: [
          const LanguageButton(),
          UserButton(name: widget.user.name, onLogout: widget.refresh),
          const SizedBox(width: 16),
        ],
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
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          story.photoUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 360,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
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
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.toUpload,
        child: const Icon(Icons.add_a_photo_outlined),
      ),
    );
  }
}
