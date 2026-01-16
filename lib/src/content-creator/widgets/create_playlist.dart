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

  String _accessType = 'free'; // 'free' or 'paid'
  String _selectedCurrency = 'USD';
  bool _isPublic = true;
  File? _thumbnailFile;
  final Color brandGreen = const Color(0xFF00D285);

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickThumbnail() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File file = File(image.path!);
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
        setState(() => _thumbnailFile = File(croppedFile.path));

        _con.uploadPlayListThumb(_thumbnailFile!);
      }
    }
  }

  void _showSuccess(BuildContext dialogContext) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must click the button
      builder: (BuildContext context) {
        return SuccessDialog(
          message: "Your new playlist is ready for videos!",
          onDismiss: () {
            Navigator.of(dialogContext).pop();
            Navigator.of(context).pop(); // Close Dialog
            // Navigate to the Channel Detail screen or List
          },
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
          title: const Text(
            "Create Playlist",
            style: TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                print("create_pressed");
                if (_formKey.currentState!.validate() &&
                    _con.playlistThumb != null) {
                  Map map = {
                    "channel_id": widget.channel.id,
                    "title": _titleController.text,
                    "description": _descriptionController.text,
                    "type": _accessType,
                    "price": _priceController.text.isEmpty
                        ? 0.00
                        : _priceController.text,
                    "currency": _selectedCurrency,
                    "thumbnail_url": _con.playlistThumb?.fileLink,
                    "is_public": _isPublic,
                  };
                  Playlist? channel = await _con.createPlaylist(map);

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
                    "Please fill in all fields including a thumbnail",
                  );
                }
              },
              child: const Text(
                "CREATE",
                style: TextStyle(
                  color: Colors.blueAccent,
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
                  // 1. Thumbnail / Cover Section
                  GestureDetector(
                    onTap: _pickThumbnail,
                    child: Container(
                      height: 220,
                      width: double.infinity,
                      color: Colors.grey.shade100,
                      child:
                          _thumbnailFile != null && _con.playlistThumb != null
                          ? Image.file(_thumbnailFile!, fit: BoxFit.cover)
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 50,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Add Playlist Thumbnail",
                                  style: TextStyle(color: Colors.grey),
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
                        // 2. Title Input
                        TextFormField(
                          controller: _titleController,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'required';
                            }

                            return null;
                          },
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            hintText: "Playlist title",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                        const Divider(),

                        // 3. Description Input
                        TextFormField(
                          controller: _descriptionController,

                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'required';
                            }

                            return null;
                          },
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: "Give your playlist a description...",
                            border: InputBorder.none,
                          ),
                        ),
                        const Divider(),

                        // 4. Privacy/Visibility (The Facebook "Audience Selector" style)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey.shade200,
                            child: Icon(
                              _isPublic ? Icons.public : Icons.lock,
                              color: Colors.black87,
                            ),
                          ),
                          title: const Text("Who can see this?"),
                          subtitle: Text(_isPublic ? "Public" : "Only Me"),
                          trailing: Switch(
                            value: _isPublic,
                            onChanged: (val) => setState(() => _isPublic = val),
                            activeColor: Colors.blueAccent,
                          ),
                        ),
                        const Divider(),

                        // 5. Access Type (Free vs Paid)
                        _buildAccessDropdown(),

                        if (_accessType == 'paid') ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(child: _buildPriceField()),
                              const SizedBox(width: 15),
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

  // --- Facebook Style Dropdown Methods ---

  Widget _buildAccessDropdown() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        child: const Icon(Icons.monetization_on, color: Colors.black87),
      ),
      title: const Text("Access Type"),
      trailing: DropdownButton<String>(
        value: _accessType,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: 'free', child: Text("Free")),
          DropdownMenuItem(value: 'paid', child: Text("Paid")),
        ],
        onChanged: (val) => setState(() => _accessType = val!),
      ),
    );
  }

  Widget _buildCurrencyDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
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

  Widget _buildPriceField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: _priceController,
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
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: "0.00",
          border: InputBorder.none,
          labelText: "Price",
        ),
      ),
    );
  }
}
