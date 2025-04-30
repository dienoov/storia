import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:storia/apis/stories.dart';
import 'package:storia/common.dart';
import 'package:storia/flavor.dart';
import 'package:storia/models/user.dart';
import 'package:storia/providers/stories.dart';
import 'package:storia/widgets/language_button.dart';
import 'package:storia/widgets/loading_indicator.dart';
import 'package:storia/widgets/location_picker.dart';
import 'package:storia/widgets/user_button.dart';

class UploadScreen extends StatefulWidget {
  final User user;
  final Function() refresh;
  final Function() toHome;

  const UploadScreen({
    super.key,
    required this.user,
    required this.refresh,
    required this.toHome,
  });

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  File? _path;
  final ImagePicker _picker = ImagePicker();

  LatLng? _position;

  late StoriesApi _storiesApi;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _storiesApi = StoriesApi(widget.user.token);
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _path = File(pickedFile.path);
      });
    }
  }

  Future<void> onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(
            AppLocalizations.of(
              context,
            )!.fieldRequired(AppLocalizations.of(context)!.image),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _storiesApi.add(
        _descriptionController.text,
        _path!.path,
        _position,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.uploadSuccess)),
        );

        context.read<StoriesProvider>().init();
        widget.toHome();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.upload,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            forceMaterialTransparency: true,
            actions: [
              const LanguageButton(),
              UserButton(name: widget.user.name, onLogout: widget.refresh),
              const SizedBox(width: 16),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  if (_path != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _path!,
                        height: 360,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 48),
                        Icon(
                          Icons.image_outlined,
                          size: 80,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(190),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.noImage,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.noImageDescription,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(190),
                          ),
                        ),
                        const SizedBox(height: 56),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: Text(AppLocalizations.of(context)!.gallery),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.add_a_photo_outlined),
                          label: Text(AppLocalizations.of(context)!.camera),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.descriptionHint,
                      hintStyle: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(190),
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.fieldRequired(
                          AppLocalizations.of(context)!.description,
                        );
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  if (FlavorConfig.instance.flavor == FlavorType.paid) ...[
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          enableDrag: false,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          builder:
                              (context) => LocationPicker(
                                onPicked: (position, placemark) {
                                  setState(() {
                                    _position = position;
                                  });
                                  _locationController.text = [
                                    placemark.street,
                                    placemark.subLocality,
                                    placemark.locality,
                                    placemark.administrativeArea,
                                    placemark.postalCode,
                                    placemark.country,
                                  ].where((e) => e != '').join(", ");
                                },
                              ),
                        );
                      },
                      child: TextField(
                        controller: _locationController,
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.location,
                          hintStyle: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(190),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8),
                            ),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  ElevatedButton(
                    onPressed: onSubmit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.upload,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Theme.of(context).colorScheme.surface.withAlpha(200),
              child: const Center(child: LoadingIndicator()),
            ),
          ),
      ],
    );
  }
}
