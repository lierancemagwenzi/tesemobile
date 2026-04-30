import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/content-creator/controller/creator_controller.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/content-creator/widgets/success_dialog.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

class FacebookCreatePlaylist extends StatefulWidget {
  final Channel channel;
  const FacebookCreatePlaylist({super.key, required this.channel});

  @override
  StateMVC<FacebookCreatePlaylist> createState() =>
      _FacebookCreatePlaylistState();
}

class _FacebookCreatePlaylistState extends StateMVC<FacebookCreatePlaylist> {
  final _formKey = GlobalKey<FormState>();
  late CreatorController _con;

  _FacebookCreatePlaylistState() : super(CreatorController()) {
    _con = controller as CreatorController;
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String _accessType = 'free';
  String _selectedCurrency = 'USD';
  bool _isPublic = true;
  bool _isAudio = false;
  bool _isAlbum = false;
  File? _thumbnailFile;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        appBar: AppBar(
          backgroundColor: isDark ? Colors.black : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.close,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "New Playlist",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          actions: [
            TextButton(
              onPressed: _submitPlaylist,
              child: const Text(
                "CREATE",
                style: TextStyle(
                  color: Color(0xFF679E4F),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // 1. Interactive Thumbnail Header
              _buildThumbnailPicker(isDark),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("IDENTITY", isDark),
                      _buildTransparentField(
                        controller: _titleController,
                        hint: "Playlist Name",
                        icon: Icons.auto_awesome_motion,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildTransparentField(
                        controller: _descriptionController,
                        hint: "What is this collection about?",
                        icon: Icons.description_outlined,
                        isDark: isDark,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 32),
                      _buildSectionTitle("CONTENT TYPE", isDark),
                      _buildSettingsTile(
                        title: "Audio playlist",
                        subtitle: _isAudio
                            ? "Audio only playlist"
                            : "Make it an audio playlist",
                        icon: _isAudio ? Icons.mic : Icons.video_camera_front,
                        trailing: Switch(
                          value: _isAudio,
                          onChanged: (val) => setState(() {
                            _isAudio = val;
                            if (_isAudio == false) {
                              _isAlbum = false;
                            }
                          }),
                          activeColor: const Color(0xFF679E4F),
                        ),
                        isDark: isDark,
                      ),

                      if (_isAudio) ...[
                        const SizedBox(height: 32),
                        _buildSectionTitle("", isDark),
                        _buildSettingsTile(
                          title: "Album",
                          subtitle: _isAlbum
                              ? "Album playlist"
                              : "Mark it as an album",
                          icon: _isAudio ? Icons.mic : Icons.video_camera_front,
                          trailing: Switch(
                            value: _isAlbum,
                            onChanged: (val) => setState(() => _isAlbum = val),
                            activeColor: const Color(0xFF679E4F),
                          ),
                          isDark: isDark,
                        ),
                      ],

                      const SizedBox(height: 32),
                      _buildSectionTitle("VISIBILITY & AUDIENCE", isDark),
                      _buildSettingsTile(
                        title: "Public Access",
                        subtitle: _isPublic
                            ? "Visible to everyone"
                            : "Private collection",
                        icon: _isPublic ? Icons.public : Icons.lock_outline,
                        trailing: Switch(
                          value: _isPublic,
                          onChanged: (val) => setState(() => _isPublic = val),
                          activeColor: const Color(0xFF679E4F),
                        ),
                        isDark: isDark,
                      ),

                      const SizedBox(height: 32),
                      _buildSectionTitle("MONETIZATION", isDark),
                      _buildSettingsTile(
                        title: "Access Type",
                        subtitle: "How viewers enter this playlist",
                        icon: Icons.payments_outlined,
                        trailing: _buildAccessDropdown(isDark),
                        isDark: isDark,
                      ),

                      if (_accessType == 'paid') ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildTransparentField(
                                controller: _priceController,
                                hint: "Price",
                                icon: Icons.attach_money,
                                isDark: isDark,
                                isNumber: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: _buildCurrencySelector(isDark)),
                          ],
                        ),
                      ],
                      const SizedBox(height: 60),
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

  // --- UI Logic Helpers ---

  Future<void> _submitPlaylist() async {
    if (_formKey.currentState!.validate() && _con.playlistThumb != null) {
      Map map = {
        "channel_id": widget.channel.id,
        "title": _titleController.text,
        "description": _descriptionController.text,
        "type": _accessType,
        "price": _priceController.text.isEmpty ? 0.00 : _priceController.text,
        "currency": _selectedCurrency,
        "thumbnail_url": _con.playlistThumb?.fileLink,
        "is_public": _isPublic,
        "is_audio": _isAudio,
        "is_album": _isAlbum,
      };
      Playlist? playlist = await _con.createPlaylist(map);
      if (playlist != null) {
        _showSuccess(context);
      } else {
        CustomMessageHandler().showErrorSnakeBar(
          context,
          "Failed to create playlist.",
        );
      }
    } else {
      CustomMessageHandler().showErrorSnakeBar(
        context,
        "Thumbnail and titles are required.",
      );
    }
  }

  Widget _buildThumbnailPicker(bool isDark) {
    return GestureDetector(
      onTap: _pickThumbnail,
      child: Container(
        height: 240,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
          ),
          image: (_thumbnailFile != null && _con.playlistThumb != null)
              ? DecorationImage(
                  image: FileImage(_thumbnailFile!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: (_thumbnailFile == null)
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: isDark ? Colors.white24 : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Add Playlist Thumbnail",
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(12),
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.edit, color: Colors.white, size: 18),
                ),
              ),
      ),
    );
  }

  Widget _buildTransparentField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    int maxLines = 1,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black,
        fontWeight: FontWeight.w600,
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? Colors.white24 : Colors.grey,
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF679E4F)),
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.shade50,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF679E4F)),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget trailing,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF679E4F).withOpacity(0.1),
          child: Icon(icon, color: const Color(0xFF679E4F), size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: trailing,
      ),
    );
  }

  Widget _buildAccessDropdown(bool isDark) {
    return DropdownButton<String>(
      value: _accessType,
      underline: const SizedBox(),
      dropdownColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      items: const [
        DropdownMenuItem(value: 'free', child: Text("Free Access")),
        DropdownMenuItem(value: 'paid', child: Text("Premium")),
      ],
      onChanged: (val) => setState(() => _accessType = val!),
    );
  }

  Widget _buildCurrencySelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCurrency,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
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

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white24 : Colors.grey.shade400,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  // --- Reuse existing crop/pick logic ---
  Future<void> _pickThumbnail() async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(
          ratioX: 16,
          ratioY: 9,
        ), // Playlists usually use 16:9
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Thumbnail',
            toolbarColor: const Color(0xFF679E4F),
            toolbarWidgetColor: Colors.white,
          ),
          IOSUiSettings(title: 'Crop Thumbnail'),
        ],
      );
      if (croppedFile != null) {
        setState(() => _thumbnailFile = File(croppedFile.path));
        _con.uploadPlayListThumb(_thumbnailFile!);
      }
    }
  }

  void _showSuccess(BuildContext dialogContext) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => SuccessDialog(
        message: "Your playlist is ready! Let's add some videos.",
        onDismiss: () {
          Navigator.of(dialogContext).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
