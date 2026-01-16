import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smacredit/src/content-creator/controller/creator_controller.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/content-creator/widgets/success_dialog.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class AddVideoScreen extends StatefulWidget {
  final Playlist playlist;
  const AddVideoScreen({super.key, required this.playlist});

  @override
  StateMVC<AddVideoScreen> createState() => _AddVideoScreenState();
}

class _AddVideoScreenState extends StateMVC<AddVideoScreen> {
  final _formKey = GlobalKey<FormState>();

  late CreatorController _con;

  _AddVideoScreenState() : super(CreatorController()) {
    _con = controller as CreatorController;
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  File? _videoFile;
  String _accessType = 'free';
  String _contentRating = 'G';
  String _selectedCurrency = 'USD';
  File? _thumbNail;
  int durationInSeconds = 0;
  int sizeInBytes = 0;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      String? path = await generateThumbnail(File(video.path));

      if (path != null) {
        setState(() {
          _videoFile = File(video.path);
          _thumbNail = File(path);
        });

        _con.uploadVideo(File(video.path), File(path));
      }
    }
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
          message:
              "Your new video has been added successfully. You will receive a notification when processing is done",
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
          title: const Text(
            "Add Video",
            style: TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: _con.video == null || _con.videoThumb == null
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        String resolution = await getVideoResolution(
                          _videoFile!,
                        );

                        int durationInSeconds = await getVideoDuration(
                          _videoFile!,
                        );

                        int size = await getSize(_videoFile!);

                        Map map = {
                          "title": _titleController.text,
                          "playlist_id": widget.playlist.id,
                          "channel_id": widget.playlist.channelId,
                          "description": _descController.text,
                          "content_rating": _contentRating,
                          "access_type": _accessType,
                          "price": _priceController.text.isEmpty
                              ? 0
                              : _priceController.text,
                          "currency": _selectedCurrency,
                          "source_file_url": _con.video?.fileLink,
                          "thumbnail_url": _con.videoThumb?.fileLink,
                          "duration_seconds": durationInSeconds,
                          "file_size_bytes": size,
                          "resolution_max": resolution,
                        };

                        Video? channel = await _con.createVideo(map);

                        if (channel != null) {
                          _showSuccess(context);
                        } else {
                          CustomMessageHandler().showErrorSnakeBar(
                            context,
                            "Something went wrong.Try again",
                          );
                        }
                      } else {
                        CustomMessageHandler().showErrorSnakeBar(
                          context,
                          "Please fill in all fields including  the video",
                        );
                      }
                    },
              child: Text(
                "POST",
                style: TextStyle(
                  color: _videoFile == null ? Colors.grey : Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

          bottom: _con.uploadingVideo
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(4),
                  child: _con.uploadProgress > 0 && _con.uploadProgress < 1
                      ? LinearProgressIndicator(
                          value: _con.uploadProgress,
                          minHeight: 10,
                          color: Colors.green,
                          backgroundColor: Colors.grey,
                        )
                      : const SizedBox.shrink(),
                )
              : null,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // 1. VIDEO SELECTION BOX (FB POST STYLE)
                  GestureDetector(
                    onTap: _pickVideo,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      color: const Color(0xFFF7F8FA),
                      child: _videoFile != null && _con.video != null
                          ? _con.videoThumb != null && _thumbNail != null
                                ? Image.file(_thumbNail!)
                                : Center(
                                    child: Icon(
                                      Icons.video_library,
                                      size: 50,
                                      color: Colors.green,
                                    ),
                                  )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.video_call,
                                  size: 40,
                                  color: Color(0xFF45BD62),
                                ), // FB Green
                                const SizedBox(height: 8),
                                const Text(
                                  "Select Video from Gallery",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "Tap to browse your files",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

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
