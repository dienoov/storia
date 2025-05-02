import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:storia/apis/stories.dart';
import 'package:storia/common.dart';
import 'package:storia/models/story.dart';
import 'package:storia/models/user.dart';
import 'package:storia/widgets/language_button.dart';
import 'package:storia/widgets/loading_indicator.dart';
import 'package:storia/widgets/user_button.dart';

class StoryScreen extends StatefulWidget {
  final User user;
  final String id;
  final Function() refresh;

  const StoryScreen({
    super.key,
    required this.user,
    required this.id,
    required this.refresh,
  });

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  late StoriesApi _storiesApi;
  late Future<Story> _story;

  @override
  void initState() {
    super.initState();
    _storiesApi = StoriesApi(widget.user.token);
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
        actions: [
          const LanguageButton(),
          UserButton(name: widget.user.name, onLogout: widget.refresh),
          const SizedBox(width: 16),
        ],
      ),
      body: FutureBuilder(
        future: _story,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator());
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
            return Center(child: Text(AppLocalizations.of(context)!.notFound));
          }

          final Story story = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  child: Image.network(
                    story.photoUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    story.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 16),
                if (story.lat != null && story.lon != null) ...[
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withAlpha(25),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 56,
                          child: Icon(
                            Icons.location_on,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Expanded(
                          child: Flexible(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                [
                                  story.address?.street,
                                  story.address?.subLocality,
                                  story.address?.locality,
                                  story.address?.administrativeArea,
                                  story.address?.country,
                                ].where((e) => e != '').join(", "),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 320,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(story.lat!, story.lon!),
                            zoom: 16,
                          ),
                          markers: {
                            Marker(
                              markerId: MarkerId(story.id),
                              position: LatLng(story.lat!, story.lon!),
                              infoWindow: InfoWindow(
                                title: story.address?.street,
                                snippet: [
                                  story.address?.subLocality,
                                  story.address?.locality,
                                  story.address?.administrativeArea,
                                  story.address?.country,
                                ].where((e) => e != '').join(", "),
                              ),
                            ),
                          },
                          myLocationEnabled: false,
                          myLocationButtonEnabled: false,
                          mapToolbarEnabled: false,
                          zoomControlsEnabled: false,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
    );
  }
}
