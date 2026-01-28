import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smacredit/src/content-creator/controller/creator_controller.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/content-creator/widgets/success_dialog.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/utils/xhelper.dart';
import 'package:smacredit/src/widgets/CustomButtons.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class UpdateVideoScreen extends StatefulWidget {
  final Video video;
  final Playlist playlist;
  final Channel channel;
  const UpdateVideoScreen({
    super.key,
    required this.video,
    required this.channel,
    required this.playlist,
  });

  @override
  StateMVC<UpdateVideoScreen> createState() => _UpdateVideoScreenState();
}

class _UpdateVideoScreenState extends StateMVC<UpdateVideoScreen> {
  final _formKey = GlobalKey<FormState>();

  late CreatorController _con;

  _UpdateVideoScreenState() : super(CreatorController()) {
    _con = controller as CreatorController;
  }

  TextEditingController _titleController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  TextEditingController _priceController = TextEditingController();

  File? _videoFile;
  String _accessType = 'free';
  String _contentRating = 'G';
  String _selectedCurrency = 'USD';
  File? _thumbNail;
  int durationInSeconds = 0;
  int sizeInBytes = 0;
  final ImagePicker _picker = ImagePicker();
  File? _logoImage;

  bool visibility = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    bool isLogo = true;
    final Color brandGreen = const Color(0xFF00D285);
    if (result != null) {
      File file = File(result.files.single.path!);
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: brandGreen,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: brandGreen,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
            ],
          ),
          IOSUiSettings(
            title: 'Crop Image',

            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
            ],
          ),
        ],
      );

      if (croppedFile != null) {
        if (isLogo) {
          setState(() {
            _logoImage = File(croppedFile.path);

            _con.updateVideoThumb(_logoImage!, widget.video.id);
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final c = widget.video;

    // Pre-fill controllers with existing data or empty strings
    _titleController = TextEditingController(text: c.title ?? '');
    _descController = TextEditingController(text: c.description ?? '');
    _priceController = TextEditingController(text: c.price?.toString() ?? '');

    _accessType = c.accessType ?? 'free';
    _selectedCurrency = c.currency ?? 'USD';
    visibility = widget.video.visibility?.toLowerCase() == 'visible';
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      // String? path = await generateThumbnail(File(video.path));
      setState(() {
        _videoFile = File(video.path);
      });
    }

    Future.delayed(Duration(seconds: 1)).then((v) {
      setState(() {});
    });
  }

  Future<String?> generateThumbnail(File videoFile) async {
    try {
      // 1. Get a temporary directory to store the thumbnail
      final tempDir = await getTemporaryDirectory();

      // 2. Generate the thumbnail
      final String? thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoFile.path,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 200, // Scale the thumbnail height
        quality: 75, // Compression quality
        timeMs: 1000, // Extract frame at 1 second mark
      );

      return thumbnailPath;
    } catch (e) {
      print("Error generating thumbnail: $e");
      return null;
    }
  }

  void _showSuccess(BuildContext dialogContext) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must click the button
      builder: (BuildContext context) {
        return SuccessDialog(
          message: "Your video details have been updated successfully",
          onDismiss: () {
            Navigator.of(dialogContext).pop();
            Navigator.of(context).pop(); // Close Dialog
            // Navigate to the Channel Detail screen or List
          },
        );
      },
    );
  }

  Future<String> getVideoResolution(File videoFile) async {
    final VideoPlayerController controller = VideoPlayerController.file(
      videoFile,
    );

    try {
      await controller.initialize();

      // Get natural dimensions
      final double width = controller.value.size.width;
      final double height = controller.value.size.height;

      await controller.dispose();

      // Standardize the output (e.g., 1080p, 720p, 4K)
      if (height >= 2160) return "4K";
      if (height >= 1080) return "1080p";
      if (height >= 720) return "720p";
      if (height >= 480) return "480p";

      return "${height.toInt()}p";
    } catch (e) {
      print("Error getting resolution: $e");
      return "Unknown";
    }
  }

  Future<int> getVideoDuration(File videoFile) async {
    // 1. Create the controller
    final VideoPlayerController controller = VideoPlayerController.file(
      videoFile,
    );

    try {
      // 2. Initialize it (this loads the metadata)
      await controller.initialize();

      // 3. Get duration in seconds (matching your Sequelize model)
      final int durationInSeconds = controller.value.duration.inSeconds;
      sizeInBytes = await videoFile.length();
      // 4. Dispose to free up memory
      await controller.dispose();

      return durationInSeconds;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting video duration: $e");
      }
      return 0;
    }
  }

  Future<int> getSize(File videoFile) async {
    // 1. Create the controller
    final VideoPlayerController controller = VideoPlayerController.file(
      videoFile,
    );

    try {
      // 2. Initialize it (this loads the metadata)
      await controller.initialize();

      // 3. Get duration in seconds (matching your Sequelize model)
      sizeInBytes = await videoFile.length();
      // 4. Dispose to free up memory
      await controller.dispose();

      return sizeInBytes;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting video duration: $e");
      }
      return 0;
    }
  }

  Future<bool?> showDeleteConfirmation(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Video?'),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // Cancel
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              }, // Confirm
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        key: _con.scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: false,
          title: const Text(
            "Update Video",
            style: TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                bool? confirmed = await showDeleteConfirmation(context);

                // 2. If confirmed is true, call your API
                if (confirmed == true) {
                  Map map = {"id": widget.video.id};

                  Video? channel = await _con.deleteVideo(map);
                  if (channel != null) {
                    _showSuccess(context);
                  } else {
                    CustomMessageHandler().showErrorSnakeBar(
                      context,
                      "Something went wrong.Try again",
                    );
                  }
                }
              },
              child: Text(
                "Delete Video",
                style: TextStyle(
                  color: _videoFile == null ? Colors.grey : Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // 1. VIDEO SELECTION BOX (FB POST STYLE)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 2. TITLE (FB TITLE STYLE)
                        TextFormField(
                          controller: _titleController,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'required';
                            }

                            return null;
                          },
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: const InputDecoration(
                            hintText: "Video Title",
                            border: InputBorder.none,
                          ),
                        ),
                        const Divider(),

                        // 3. DESCRIPTION
                        TextFormField(
                          controller: _descController,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'required';
                            }

                            return null;
                          },
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: "What's this video about?",
                            border: InputBorder.none,
                          ),
                        ),
                        const Divider(),

                        // 4. CONTENT RATING DROPDOWN
                        _buildListTileDropdown(
                          icon: Icons.subtitles_outlined,
                          label: "Content Rating",
                          value: _contentRating,
                          items: ['G', 'PG', 'PG-13', 'R'],
                          onChanged: (val) =>
                              setState(() => _contentRating = val!),
                        ),

                        // 5. ACCESS TYPE (FREE/PAID)
                        _buildListTileDropdown(
                          icon: Icons.lock_open,
                          label: "Access Type",
                          value: _accessType,
                          items: ['free', 'paid'],
                          onChanged: (val) =>
                              setState(() => _accessType = val!),
                        ),

                        // 6. CONDITIONAL PRICING
                        if (_accessType == 'paid') ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildGreyInput(
                                  "Price",
                                  _priceController,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: _buildCurrencyDropdown()),
                            ],
                          ),
                        ],
                        const SizedBox(height: 24),
                        CustomButtons.filledButton(
                          text: 'Update',
                          callback: () async {
                            if (_formKey.currentState!.validate()) {
                              Map map = {
                                "title": _titleController.text,
                                "id": widget.video.id,
                                "description": _descController.text,
                                "content_rating": _contentRating,
                                "access_type": _accessType,
                                "price": _priceController.text.isEmpty
                                    ? 0
                                    : _priceController.text,
                                "currency": _selectedCurrency,
                              };

                              Video? channel = await _con.updateVideo(map);

                              if (channel != null) {
                                // ignore: use_build_context_synchronously
                                _showSuccess(context);
                              } else {
                                CustomMessageHandler().showErrorSnakeBar(
                                  // ignore: use_build_context_synchronously
                                  context,
                                  "Something went wrong.Try again",
                                );
                              }
                            } else {
                              CustomMessageHandler().showErrorSnakeBar(
                                context,
                                "Please fill in all fields",
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Colors.blueGrey),

                  // ListTile(
                  //   title: Text(
                  //     "Video Visibility ",
                  //     style: TextStyle(
                  //       fontWeight: FontWeight.bold,
                  //       // fontSize: 12.0,
                  //     ),
                  //   ),

                  //   subtitle: Text(
                  //     widget.video.visibility?.toLowerCase() == 'visible'
                  //         ? "Visible to users"
                  //         : "Video is not visible to users",
                  //   ),
                  // ),
                  SwitchListTile(
                    title: const Text('Video Visibility'),
                    subtitle: Text(
                      widget.video.visibility?.toLowerCase() == 'visible'
                          ? "Visible to users"
                          : "Video is not visible to users",
                    ), // Icon on the left
                    value: visibility, // A boolean variable
                    onChanged: (bool value) async {
                      Map map = {
                        "visibility": value ? "VISIBLE" : "NOT_VISIBLE",
                        "id": widget.video.id,
                      };
                      Video? channel = await _con.updateVideoVisibility(map);
                      if (channel != null) {
                        // ignore: use_build_context_synchronously
                        // _showSuccess(context);
                        setState(() {
                          visibility = value;
                        });
                      } else {
                        CustomMessageHandler().showErrorSnakeBar(
                          // ignore: use_build_context_synchronously
                          context,
                          "Something went wrong.Try again",
                        );
                      }
                    },
                  ),

                  Divider(color: Colors.blueGrey),

                  ListTile(
                    leading: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: _con.profileImage != null && _logoImage != null
                              ? FileImage(_logoImage!)
                              : NetworkImage(widget.video.thumbnailUrl ?? ""),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    onTap: () {
                      _pickFile();
                    },
                    title: Text(
                      "Update Video thumbnail",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        // fontSize: 12.0,
                      ),
                    ),

                    subtitle: Text(
                      _logoImage != null
                          ? "Thumbanail picked"
                          : "Click to update",
                    ),
                  ),

                  Divider(color: Colors.blueGrey),

                  ListTile(
                    onTap: () {
                      _pickVideo();
                    },
                    title: Text(
                      "Video trailer",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        // fontSize: 12.0,
                      ),
                    ),

                    trailing: widget.video.trailer != null
                        ? InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/VideoDetails',
                                arguments: {
                                  'video': widget.video,
                                  'playlist': widget.playlist,
                                  'channel': widget.channel,
                                },
                              );
                            },

                            child: Icon(Icons.play_arrow_outlined),
                          )
                        : null,

                    subtitle: Text(
                      widget.video.trailer != null
                          ? "Trailer set"
                          : "trailer not set:Tap to select trailer video",
                    ),
                  ),
                  const SizedBox(height: 10),
                  _videoFile != null
                      ? CustomButtons.filledButton(
                          text: 'Upload',
                          callback: () async {
                            Video? channel = await _con.uploadVideoTrailer(
                              _videoFile!,
                              widget.video.id,
                            );

                            if (channel != null) {
                              _showSuccess(context);
                            } else {
                              CustomMessageHandler().showErrorSnakeBar(
                                context,
                                "Something went wrong.Try again",
                              );
                            }
                          },
                        )
                      : SizedBox.shrink(),
                  Divider(color: Colors.blueGrey),

                  ListTile(
                    title: Text(
                      "Video details",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        // fontSize: 12.0,
                      ),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Duration:${UtilsHelper.formatLongDuration(widget.video.durationSeconds ?? 0)}",
                        ),
                        SizedBox(height: 8),
                        Text("Resolution:${widget.video.resolutionMax ?? '-'}"),
                        SizedBox(height: 8),

                        Text(
                          "Date created:${widget.video.createdAt?.toIso8601String() ?? '-'}",
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- UI BUILDERS ---

  Widget _buildListTileDropdown({
    required IconData icon,
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFF0F2F5),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: items
            .map(
              (e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase())),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildGreyInput(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        validator: (v) {
          if (v == null || v.isEmpty) {
            return 'required';
          }

          if (num.tryParse(v) == null) {
            return 'Enter a valid amount';
          }

          if (num.tryParse(v)! <= 0) {
            return 'Enter a valid amount';
          }
          return null;
        },
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          labelStyle: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCurrency,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: "USD", child: Text("USD")),
            DropdownMenuItem(value: "EUR", child: Text("EUR")),
            DropdownMenuItem(value: "GBP", child: Text("GBP")),
          ],
          onChanged: (val) => setState(() => _selectedCurrency = val!),
        ),
      ),
    );
  }
}
