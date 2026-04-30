import 'dart:io';
import 'package:background_downloader/background_downloader.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smacredit/client/downloads/uploadHelper.dart';
import 'package:smacredit/src/content-creator/controller/creator_controller.dart';
import 'package:smacredit/src/content-creator/controller/upload_manager.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/content-creator/models/tag_model.dart';
import 'package:smacredit/src/content-creator/models/upload_response.dart';
import 'package:smacredit/src/content-creator/widgets/success_dialog.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/utils/xhelper.dart';
import 'package:smacredit/src/widgets/CustomButtons.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path/path.dart' as p;

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

  // Controllers initialized in initState to avoid null issues
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _priceController;

  File? _videoFile;
  String _accessType = 'free';
  late List<TagModel> _selectedTags;
  String _contentRating = 'G';
  String _selectedCurrency = 'USD';
  String fileName = "";
  String taskId = "";
  File? _logoImage;
  bool visibility = false;

  final ImagePicker _picker = ImagePicker();
  final Color brandGreen = const Color(0xFF679E4F);

  @override
  void initState() {
    super.initState();
    final c = widget.video;
    _con.listenForTags();
    _selectedTags = List<TagModel>.from(widget.video.tags);
    _titleController = TextEditingController(text: c.title ?? '');
    _descController = TextEditingController(text: c.description ?? '');
    _priceController = TextEditingController(text: c.price?.toString() ?? '');
    _accessType = c.accessType ?? 'free';
    _selectedCurrency = c.currency ?? 'USD';
    visibility = widget.video.visibility?.toLowerCase() == 'visible';
  }

  // --- Logic Blocks ---

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      File file = File(result.files.single.path!);
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: brandGreen,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: brandGreen,
          ),
          IOSUiSettings(title: 'Crop Image'),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _logoImage = File(croppedFile.path);
          _con.updateVideoThumb(_logoImage!, widget.video.id);
        });
      }
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      File originalFile = File(video.path);
      setState(() => _con.loading = true);
      var appDir = await getApplicationDocumentsDirectory();
      String newPath = p.join(appDir.path, p.basename(video.path));
      File newvideo = await originalFile.copy(newPath);
      await originalFile.delete();
      setState(() {
        _videoFile = File(newvideo.path);
        _con.loading = false;
      });
    }
  }

  Future<bool> isTrailerValid(File videoFile) async {
    final controller = VideoPlayerController.file(videoFile);
    try {
      await controller.initialize();
      final duration = controller.value.duration;
      await controller.dispose();
      return duration.inSeconds <= 20;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // VISIBILITY FIX: Define explicit colors based on Theme
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subTextColor = isDark ? Colors.white70 : Colors.black54;
    final Color inputBg = isDark ? Colors.white10 : const Color(0xFFF0F2F5);

    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        key: _con.scaffoldKey,
        backgroundColor: isDark ? Colors.black : Colors.white,
        appBar: AppBar(
          backgroundColor: isDark ? Colors.black : Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: Icon(Icons.close, color: textColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Update Content",
            style: TextStyle(
              color: textColor,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                bool? confirmed = await _showDeleteConfirmation(context);
                if (confirmed == true) {
                  Video? channel = await _con.deleteVideo({
                    "id": widget.video.id,
                  });
                  if (channel != null) _showSuccess(context);
                }
              },
              child: const Text(
                "Delete Content",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TITLE
                      TextFormField(
                        controller: _titleController,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: "Video Title",
                          hintStyle: TextStyle(color: subTextColor),
                          border: InputBorder.none,
                        ),
                      ),
                      const Divider(),
                      // DESCRIPTION
                      TextFormField(
                        controller: _descController,
                        maxLines: 3,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: "What's this video about?",
                          hintStyle: TextStyle(color: subTextColor),
                          border: InputBorder.none,
                        ),
                      ),
                      const Divider(),
                      // DROP DOWNS
                      _buildListTileDropdown(
                        icon: Icons.subtitles_outlined,
                        label: "Content Rating",
                        value: _contentRating,
                        items: ['G', 'PG', 'PG-13', 'R'],
                        textColor: textColor,
                        onChanged: (val) =>
                            setState(() => _contentRating = val!),
                      ),
                      _buildListTileDropdown(
                        icon: Icons.lock_open,
                        label: "Access Type",
                        value: _accessType,
                        items: ['free', 'paid'],
                        textColor: textColor,
                        onChanged: (val) => setState(() => _accessType = val!),
                      ),
                      if (_accessType == 'paid') ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildGreyInput(
                                "Price",
                                _priceController,
                                inputBg,
                                textColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildCurrencyDropdown(inputBg, textColor),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                      _buildTagsSection(isDark),
                      const SizedBox(height: 24),
                      CustomButtons.filledButton(
                        text: 'Update Info',
                        callback: _handleUpdate,
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.blueGrey),
                // VISIBILITY
                SwitchListTile(
                  title: Text(
                    widget.video.isAudio == true
                        ? "Audio Visibility"
                        : 'Video Visibility',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    visibility
                        ? "Visible to users"
                        : widget.video.thumbnailUrl == null
                        ? "Update thumbnail first"
                        : "Content is not visible to users",
                    style: TextStyle(color: subTextColor),
                  ),
                  value: visibility,
                  activeColor: brandGreen,
                  onChanged: (bool value) async {
                    if (widget.video.thumbnailUrl == null) {
                      CustomMessageHandler().showErrorSnakeBar(
                        context,
                        "Update thumbanil first to update content",
                      );
                      return;
                    }
                    if (widget.video.thumbnailUrl == null) {
                      CustomMessageHandler().showErrorSnakeBar(
                        context,
                        "Update thumbanil first to update content",
                      );
                      return;
                    }
                    Video? channel = await _con.updateVideoVisibility({
                      "visibility": value,
                      "id": widget.video.id,
                    });
                    if (channel != null) setState(() => visibility = value);
                  },
                ),
                const Divider(color: Colors.blueGrey),
                // THUMBNAIL
                ListTile(
                  leading: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: _logoImage != null
                            ? FileImage(_logoImage!)
                            : NetworkImage(widget.video.thumbnailUrl ?? "")
                                  as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  onTap: _pickFile,
                  title: Text(
                    "Update Content thumbnail",
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    _logoImage != null ? "Thumbnail picked" : "Click to update",
                    style: TextStyle(color: subTextColor),
                  ),
                ),
                const Divider(color: Colors.blueGrey),

                if (widget.video.isAudio == false) ...[
                  TrailerDisclaimerCard(onPickTrailer: _pickVideo),
                  ListTile(
                    title: Text(
                      "Video trailer",
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      widget.video.trailer != null
                          ? "Trailer set"
                          : "No trailer set: Tap to select",
                      style: TextStyle(color: subTextColor),
                    ),
                    trailing: widget.video.trailer != null
                        ? Icon(Icons.play_circle_fill, color: brandGreen)
                        : null,
                    onTap: () {
                      if (widget.video.trailer != null) {
                        Navigator.pushNamed(
                          context,
                          '/VideoTrailer',
                          arguments: {
                            'video': widget.video,
                            'playlist': widget.playlist,
                            'channel': widget.channel,
                          },
                        );
                      }
                    },
                  ),
                ],

                // TRAILER
                if (_videoFile != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CustomButtons.filledButton(
                      text: 'Upload Selected Trailer',
                      callback: _handleTrailerUpload,
                    ),
                  ),
                const Divider(color: Colors.blueGrey),
                // DETAILS
                ListTile(
                  title: Text(
                    "Content details",
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        "Duration: ${UtilsHelper.formatLongDuration(widget.video.durationSeconds ?? 0)}",
                        style: TextStyle(color: subTextColor),
                      ),
                      Text(
                        "Resolution: ${widget.video.resolutionMax ?? '-'}",
                        style: TextStyle(color: subTextColor),
                      ),
                      Text(
                        "Created: ${widget.video.createdAt?.toLocal().toString().split(' ')[0] ?? '-'}",
                        style: TextStyle(color: subTextColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Helpers with Visibility Fixes ---

  Widget _buildTagsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "TAGS",
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        if (_con.tags.isEmpty)
          Text(
            "No tags available",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _con.tags.map((tag) {
              final isSelected = _selectedTags.any((t) => t.id == tag.id);
              return FilterChip(
                label: Text(tag.name),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.removeWhere((t) => t.id == tag.id);
                    }
                  });
                },
                selectedColor: brandGreen.withOpacity(0.2),
                checkmarkColor: brandGreen,
                labelStyle: TextStyle(
                  color: isSelected ? brandGreen : (isDark ? Colors.white70 : Colors.black87),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: isDark ? Colors.white10 : Colors.white,
                side: BorderSide(
                  color: isSelected ? brandGreen : Colors.grey.shade300,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildListTileDropdown({
    required IconData icon,
    required String label,
    required String value,
    required List<String> items,
    required Color textColor,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: brandGreen.withOpacity(0.1),
        child: Icon(icon, color: brandGreen, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
      trailing: DropdownButton<String>(
        value: value,
        dropdownColor: Theme.of(
          context,
        ).cardColor, // Fix for dropdown visibility
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
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
    TextEditingController controller,
    Color bg,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: textColor),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12, color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown(Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCurrency,
          dropdownColor: Theme.of(context).cardColor,
          isExpanded: true,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
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

  // --- Logic Handlers ---

  void _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      Video? channel = await _con.updateVideo({
        "title": _titleController.text,
        "id": widget.video.id,
        "description": _descController.text,
        "content_rating": _contentRating,
        "access_type": _accessType,
        "price": _priceController.text.isEmpty ? 0 : _priceController.text,
        "currency": _selectedCurrency,
        "tag_ids": _selectedTags.map((t) => t.id).toList(),
      });
      if (channel != null) _showSuccess(context);
    }
  }

  void _handleTrailerUpload() async {
    bool isValid = await isTrailerValid(_videoFile!);
    if (!isValid) {
      CustomMessageHandler().showErrorSnakeBar(
        context,
        "Trailer too long (Max 20s)",
      );
      return;
    }
    S3UploadResponse? response = await _con.generateTrailerUploadLink({
      "id": widget.video.id,
      "extension": _videoFile?.path.split(".").last,
    });
    if (response != null) {
      fileName = response.fileName;
      taskId = "${widget.video.id}${DateTime.now().millisecond}";
      await _con.uploadTrailerVideoToS3(response, _videoFile!, taskId);
      TeseUploadManager.instance.uploads.addListener(listener);
      _showLoadingModal(context, taskId);
    }
  }

  void listener() async {
    final record = TeseUploadManager.instance.uploads.value[taskId];
    if (record != null && record.status == TaskStatus.complete) {
      TeseUploadManager.instance.uploads.removeListener(listener);
      Video? video = await _con.saveVideoTrailer({
        'id': widget.video.id,
        "fileName": fileName,
      });
      if (video != null) {
        setState(() => _videoFile = null);
        if (context.mounted) {
          Navigator.pop(context);
          Navigator.pop(context);
        }
      }
    }
  }

  void _showSuccess(BuildContext dialogContext) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => SuccessDialog(
        message: "Video details updated successfully",
        onDismiss: () {
          Navigator.pop(context);
          Navigator.pop(dialogContext);
        },
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Video?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showLoadingModal(BuildContext context, String taskId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text("Finalizing Trailer"),
          content: ValueListenableBuilder<Map<String, TaskRecord>>(
            valueListenable: TeseUploadManager.instance.uploads,
            builder: (context, allUploads, child) {
              final progress = allUploads[taskId]?.progress ?? 0.0;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Uploading and securing your trailer..."),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    color: brandGreen,
                  ),
                  const SizedBox(height: 10),
                  Text("${(progress * 100).toInt()}%"),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}

// RESTORED TRAILER CARD
class TrailerDisclaimerCard extends StatelessWidget {
  final VoidCallback onPickTrailer;
  const TrailerDisclaimerCard({super.key, required this.onPickTrailer});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF0F9EF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: const Color(0xFF679E4F).withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.video_library_rounded,
                  color: Color(0xFF679E4F),
                ),
                const SizedBox(width: 12),
                Text(
                  "Trailer Requirements",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1B3D13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "• Max duration: 20 seconds\n• Formats: MP4, MOV\n• Purpose: Preview for paid content",
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onPickTrailer,
                icon: const Icon(Icons.add, size: 18),
                label: const Text("SELECT TRAILER"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF679E4F),
                  side: const BorderSide(color: Color(0xFF679E4F)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
