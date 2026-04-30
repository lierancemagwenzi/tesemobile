import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smacredit/src/content-creator/controller/creator_controller.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/content-creator/models/content_rating.dart';
import 'package:smacredit/src/content-creator/models/tag_model.dart';
import 'package:smacredit/src/content-creator/models/upload_response.dart';
import 'package:smacredit/src/content-creator/widgets/success_dialog.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:smacredit/client/models/dashboard_model.dart' as dash;
import 'package:path/path.dart' as p;

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
  dash.Category? category;
  File? _videoFile;
  String _accessType = 'free';
  ContentRating? _contentRating;
  String _selectedCurrency = 'USD';
  bool isAudo = false;
  bool isAlbum = false;
  final List<TagModel> _selectedTags = [];
  File? _thumbNail;
  String? loadingText;
  final ImagePicker _picker = ImagePicker();

  @override
  initState() {
    super.initState();
    _con.listenForMusicCategories();
    _con.listenForContentRatings();
    _con.listenForTags();
  }

  // Logic: Exactly as provided, adding brand colors to generating state
  Future<void> _pickVideo() async {
    try {
      setState(() => _con.loading = true);
      final XFile? filex = await _picker.pickVideo(source: ImageSource.gallery);

      if (filex != null) {
        File originalFile = File(filex.path);
        var appDir = await getApplicationDocumentsDirectory();
        String newPath = p.join(appDir.path, p.basename(filex.path));
        File video = await originalFile.copy(newPath);
        await originalFile.delete();

        String? path = await generateThumbnail(File(video.path));

        if (path != null) {
          setState(() {
            _videoFile = video;
            _thumbNail = File(path);
          });
          _con.uploadVideoThumb(File(path));
        }
      } else {
        setState(() => _con.loading = false);
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() => _con.loading = false);
    }
  }

  pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav'],
    );

    if (result != null) {
      _videoFile = File(result.files.single.path!);
      // Access the file path (Mobile/Desktop)
      String? filePath = result.files.single.path;

      // Access the file name
      String fileName = result.files.single.name;

      if (kDebugMode) {
        print("Selected: $fileName at $filePath");
      }

      setState(() {});
    } else {
      // User canceled the picker
      if (kDebugMode) {
        print("No file selected");
      }
    }
  }

  Future<String?> generateThumbnail(File videoFile) async {
    try {
      setState(() => loadingText = "Generating thumbnail...");
      final tempDir = await getTemporaryDirectory();
      final String? thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoFile.path,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 200,
        quality: 75,
        timeMs: 1000,
      );
      setState(() => loadingText = null);
      return thumbnailPath;
    } catch (e) {
      debugPrint("Error generating thumbnail: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomOverlay(
      loading: _con.loading,
      text: loadingText,
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : const Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: isDark ? Colors.black : Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: Icon(
              Icons.close,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.playlist.isAudio == true ? "Add Audio" : "Add Video",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          bottom: _con.uploadingVideo ? _buildUploadProgress() : null,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const UploadInfoCard(),
              _buildVideoPickerArea(isDark),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Content Details"),
                      _buildTextField(
                        widget.playlist.isAudio == true
                            ? "Audio title"
                            : "Video Title",
                        _titleController,
                        widget.playlist.isAudio == true
                            ? Icons.music_note
                            : Icons.movie_outlined,
                        isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        "Description",
                        _descController,
                        Icons.description_outlined,
                        isDark,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle("Content Rating"),
                      _buildContentRatingDropdownField(
                        "Rating",
                        _contentRating,
                        _con.contentRatings,
                        (val) => setState(() {}),
                        isDark,
                        icon: Icons.subtitles_outlined,
                      ),

                      if (widget.playlist.isAudio == true) ...[
                        const SizedBox(height: 24),
                        _buildSectionTitle("Genre"),
                        _buildCategoryDropdownField(
                          "Genre",
                          category,
                          _con.musicCategories,
                          (val) => setState(() {}),
                          isDark,
                          icon: Icons.category,
                        ),
                      ],

                      const SizedBox(height: 24),
                      _buildSectionTitle("Monetization"),
                      _buildDropdownField(
                        "Access",
                        _accessType,
                        ['free', 'paid'],
                        (val) => setState(() => _accessType = val!),
                        isDark,
                        icon: Icons.lock_open,
                      ),

                      if (_accessType == 'paid') ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                "Price",
                                _priceController,
                                Icons.payments_outlined,
                                isDark,
                                isNumber: true,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildDropdownField(
                                "Currency",
                                _selectedCurrency,
                                ['USD', 'EUR', 'GBP'],
                                (val) =>
                                    setState(() => _selectedCurrency = val!),
                                isDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                      _buildSectionTitle("Tags"),
                      _buildTagsSection(isDark),
                      const SizedBox(height: 40),
                      _buildPostButton(),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Components ---

  PreferredSize _buildUploadProgress() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(6),
      child: _con.uploadProgress > 0 && _con.uploadProgress < 1
          ? LinearProgressIndicator(
              value: _con.uploadProgress,
              minHeight: 6,
              color: const Color(0xFF679E4F),
              backgroundColor: Colors.grey.shade200,
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildVideoPickerArea(bool isDark) {
    return GestureDetector(
      onTap: widget.playlist.isAudio == true ? pickAudio : _pickVideo,
      child: Container(
        width: double.infinity,
        height: 220,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
            style: BorderStyle.solid,
          ),
        ),
        child: _videoFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_thumbNail != null)
                      Image.file(_thumbNail!, fit: BoxFit.cover),
                    Container(color: Colors.black26),
                    const Center(
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.play_arrow, color: Color(0xFF679E4F)),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.playlist.isAudio == true
                        ? Icons.music_note
                        : Icons.video_call_rounded,
                    size: 50,
                    color: Color(0xFF679E4F),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.playlist.isAudio == true
                        ? "Select Audio file"
                        : "Select Video from Gallery",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    widget.playlist.isAudio == true
                        ? "MP3 files"
                        : "MP4, MOV up to 500MB",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 1.2,
      ),
    ),
  );

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool isDark, {
    int maxLines = 1,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF679E4F)),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
    bool isDark, {
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(icon, size: 20, color: const Color(0xFF679E4F)),
            ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                items: items
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e.toUpperCase(),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdownField(
    String label,
    dash.Category? value,
    List<dash.Category> items,
    Function(String?) onChanged,
    bool isDark, {
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(icon, size: 20, color: const Color(0xFF679E4F)),
            ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<dash.Category>(
                value: value,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                items: items
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          (e.name ?? '').toUpperCase(),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    category = v;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentRatingDropdownField(
    String label,
    ContentRating? value,
    List<ContentRating> items,
    Function(String?) onChanged,
    bool isDark, {
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(icon, size: 20, color: const Color(0xFF679E4F)),
            ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ContentRating>(
                value: value,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                items: items
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          (e.name ?? '').toUpperCase(),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _contentRating = v;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(bool isDark) {
    if (_con.tags.isEmpty) {
      return Text(
        "No tags available",
        style: TextStyle(color: Colors.grey, fontSize: 13),
      );
    }
    return Wrap(
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
          selectedColor: const Color(0xFF679E4F).withOpacity(0.2),
          checkmarkColor: const Color(0xFF679E4F),
          labelStyle: TextStyle(
            color: isSelected
                ? const Color(0xFF679E4F)
                : (isDark ? Colors.white70 : Colors.black87),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          backgroundColor: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.white,
          side: BorderSide(
            color: isSelected ? const Color(0xFF679E4F) : Colors.grey.shade300,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        );
      }).toList(),
    );
  }

  Widget _buildPostButton() {
    bool canPost = widget.playlist.isAudio == true
        ? _videoFile != null && category != null && _contentRating != null
        : _videoFile != null &&
              _con.videoThumb != null &&
              _contentRating != null;
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: canPost
            ? const LinearGradient(
                colors: [Color(0xFF679E4F), Color(0xFFBCCB4F)],
              )
            : null,
        color: canPost ? null : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: canPost ? _handlePost : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Text(
          widget.playlist.isAudio == true ? "POST AUDIO" : "POST VIDEO",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Future<void> _handlePost() async {
    if (_formKey.currentState!.validate()) {
      // Resolution and Duration logic exactly as provided
      String resolution = await getVideoResolution(_videoFile!);
      int durationInSeconds = await getVideoDuration(_videoFile!);
      int size = await videoFileSize(_videoFile!);

      Map map = {
        "title": _titleController.text,
        "playlist_id": widget.playlist.id,
        "channel_id": widget.playlist.channelId,
        "description": _descController.text,
        "content_rating_id": _contentRating?.id,
        "access_type": _accessType,
        "price": _priceController.text.isEmpty ? 0 : _priceController.text,
        "currency": _selectedCurrency,
        "source_file_url": _con.video?.fileLink,
        "thumbnail_url": _con.videoThumb?.fileLink,
        "duration_seconds": durationInSeconds,
        "file_size_bytes": size,
        "resolution_max": widget.playlist.isAudio == true ? "mp3" : resolution,
        "is_audio": widget.playlist.isAudio == true,
        "extension": _videoFile?.path.split(".").last,
        "music_category_id": category?.id,
        "tag_ids": _selectedTags.map((t) => t.id).toList(),
      };

      S3UploadResponse? res = await _con.createVideoWithoutFile(
        map,
        _videoFile!,
      );
      if (res != null) {
        _showSuccess(context);
      } else {
        CustomMessageHandler().showErrorSnakeBar(
          context,
          "Upload failed. Please try again.",
        );
      }
    }
  }

  // Helper logic extracted from your provided methods
  Future<int> videoFileSize(File file) async => await file.length();

  Future<String> getVideoResolution(File videoFile) async {
    final VideoPlayerController controller = VideoPlayerController.file(
      videoFile,
    );
    try {
      await controller.initialize();
      final double h = controller.value.size.height;
      await controller.dispose();
      if (h >= 2160) return "4K";
      if (h >= 1080) return "1080p";
      if (h >= 720) return "720p";
      return "${h.toInt()}p";
    } catch (e) {
      return "Unknown";
    }
  }

  Future<int> getVideoDuration(File videoFile) async {
    final VideoPlayerController controller = VideoPlayerController.file(
      videoFile,
    );
    try {
      await controller.initialize();
      final int d = controller.value.duration.inSeconds;
      await controller.dispose();
      return d;
    } catch (e) {
      return 0;
    }
  }

  void _showSuccess(BuildContext dialogContext) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => SuccessDialog(
        message:
            "Your video has been added! Check the 'Uploads' section for progress. You will be notified when processing is complete.",
        onDismiss: () {
          Navigator.of(dialogContext).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

// RESTORED INFO CARD
class UploadInfoCard extends StatelessWidget {
  const UploadInfoCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF679E4F).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF679E4F).withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF679E4F), size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Videos/Audios are hidden by default after upload. You must manually make them visible once processing is complete.",
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
