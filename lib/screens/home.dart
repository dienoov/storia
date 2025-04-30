import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storia/common.dart';
import 'package:storia/models/story.dart';
import 'package:storia/models/user.dart';
import 'package:storia/providers/state.dart';
import 'package:storia/providers/stories.dart';
import 'package:storia/widgets/language_button.dart';
import 'package:storia/widgets/loading_indicator.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    final StoriesProvider storiesProvider = context.read<StoriesProvider>();
    storiesProvider.token = widget.user.token;
    storiesProvider.init();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !storiesProvider.isLast) {
        storiesProvider.load();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
            LoadedState(data: final List<Story> stories) => ListView.builder(
              controller: _scrollController,
              itemCount: stories.length + (value.isLast ? 0 : 1),
              itemBuilder: (context, index) {
                if (index == stories.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: LoadingIndicator()),
                  );
                }

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
            LoadingState() => const Center(child: LoadingIndicator()),
            ErrorState(error: String message) => Center(
              child: Text(
                message,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
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
