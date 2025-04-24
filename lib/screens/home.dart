import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storia/common.dart';
import 'package:storia/models/story.dart';
import 'package:storia/models/user.dart';
import 'package:storia/providers/state.dart';
import 'package:storia/providers/stories.dart';
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
  @override
  void initState() {
    super.initState();
    final StoriesProvider storiesProvider = Provider.of<StoriesProvider>(
      context,
      listen: false,
    );
    storiesProvider.token = widget.user.token;
    storiesProvider.all();
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
      body: Consumer<StoriesProvider>(
        builder: (context, value, child) {
          return switch (value.state) {
            LoadingState() => const Center(child: CircularProgressIndicator()),
            ErrorState(error: String message) => Center(
              child: Text(
                message,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            LoadedState(data: final List<Story> stories) => ListView.builder(
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
            ),
            (_) => const SizedBox(),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.toUpload,
        child: const Icon(Icons.add_a_photo_outlined),
      ),
    );
  }
}
