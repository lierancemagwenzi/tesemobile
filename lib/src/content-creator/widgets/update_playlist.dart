// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:mvc_pattern/mvc_pattern.dart';
// import 'package:smacredit/src/content-creator/controller/creator_controller.dart';
// import 'package:smacredit/src/content-creator/models/channel_model.dart';
// import 'package:smacredit/src/content-creator/widgets/success_dialog.dart';
// import 'package:smacredit/src/helpers/Message.dart';
// import 'package:smacredit/src/widgets/CustomOverlay.dart';

// class UpdatePlayListWidget extends StatefulWidget {
//   final Playlist playlist;
//   const UpdatePlayListWidget({super.key, required this.playlist});

//   @override
//   StateMVC<UpdatePlayListWidget> createState() => _UpdatePlayListWidgetState();
// }

// class _UpdatePlayListWidgetState extends StateMVC<UpdatePlayListWidget> {
//   final _formKey = GlobalKey<FormState>();

//   late CreatorController _con;

//   _UpdatePlayListWidgetState() : super(CreatorController()) {
//     _con = controller as CreatorController;
//   }

//   TextEditingController _titleController = TextEditingController();
//   TextEditingController _descriptionController = TextEditingController();
//   TextEditingController _priceController = TextEditingController();

//   String _accessType = 'free'; // 'free' or 'paid'
//   String _selectedCurrency = 'USD';
//   bool _isPublic = false;
//   File? _thumbnailFile;

//   final ImagePicker _picker = ImagePicker();

//   Future<void> _pickThumbnail() async {
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       setState(() => _thumbnailFile = File(image.path));

//       _con.updatePlayListThumb(_thumbnailFile!, widget.playlist.id);
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     final c = widget.playlist;

//     // Pre-fill controllers with existing data or empty strings
//     _titleController = TextEditingController(text: c.title ?? '');
//     _descriptionController = TextEditingController(text: c.description ?? '');
//     _priceController = TextEditingController(text: c.price?.toString() ?? '');

//     // Pre-fill states
//     _accessType = c.type ?? 'free';
//     _isPublic = (c.isPublic == true);
//     _selectedCurrency = c.currency ?? 'USD';
//     // _selectedPeriod = c?.subscriptionPeriod ?? 'Monthly';

//     // print('status  ${c?.status ?? ''}');
//     // _selectedStatus = c?.status ?? 'Active';
//   }

//   void _showSuccess(BuildContext dialogContext) {
//     showDialog(
//       context: context,
//       barrierDismissible: false, // User must click the button
//       builder: (BuildContext context) {
//         return SuccessDialog(
//           message: "Your playlist has been updated successfully!",
//           onDismiss: () {
//             Navigator.of(dialogContext).pop();
//             Navigator.of(context).pop(); // Close Dialog
//             // Navigate to the Channel Detail screen or List
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomOverlay(
//       loading: _con.loading,
//       child: Scaffold(
//         key: _con.scaffoldKey,
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0.5,
//           leading: IconButton(
//             icon: const Icon(Icons.close, color: Colors.black),
//             onPressed: () => Navigator.pop(context),
//           ),
//           title: const Text(
//             "Update Playlist",
//             style: TextStyle(
//               color: Colors.black,
//               fontSize: 17,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () async {
//                 print("update_pressed");
//                 if (_formKey.currentState!.validate()) {
//                   Map map = {
//                     "id": widget.playlist.id,
//                     "title": _titleController.text,
//                     "description": _descriptionController.text,
//                     "type": _accessType,
//                     "price": _priceController.text.isEmpty
//                         ? 0.00
//                         : _priceController.text,
//                     "currency": _selectedCurrency,
//                     // "thumbnail_url": _con.playlistThumb?.fileLink,
//                     "is_public": _isPublic,
//                   };
//                   Playlist? channel = await _con.updatePlaylist(map);

//                   if (channel != null) {
//                     _showSuccess(context);
//                   } else {
//                     CustomMessageHandler().showErrorSnakeBar(
//                       context,
//                       "Something went wrong.Try again",
//                     );
//                   }
//                 } else {
//                   CustomMessageHandler().showErrorSnakeBar(
//                     context,
//                     "Please fill in all fields including a thumbnail",
//                   );
//                 }
//               },
//               child: const Text(
//                 "UPDATE",
//                 style: TextStyle(
//                   color: Colors.blueAccent,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: SingleChildScrollView(
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   // 1. Thumbnail / Cover Section
//                   GestureDetector(
//                     onTap: _pickThumbnail,
//                     child: Container(
//                       height: 220,
//                       width: double.infinity,
//                       color: Colors.grey.shade100,
//                       child:
//                           _thumbnailFile != null && _con.playlistThumb != null
//                           ? Image.file(_thumbnailFile!, fit: BoxFit.cover)
//                           : Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(
//                                   Icons.add_photo_alternate,
//                                   size: 50,
//                                   color: Colors.grey.shade400,
//                                 ),
//                                 const SizedBox(height: 10),
//                                 const Text(
//                                   "Update Playlist Thumbnail",
//                                   style: TextStyle(color: Colors.grey),
//                                 ),
//                               ],
//                             ),
//                     ),
//                   ),

//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // 2. Title Input
//                         TextFormField(
//                           controller: _titleController,
//                           validator: (v) {
//                             if (v == null || v.isEmpty) {
//                               return 'required';
//                             }

//                             return null;
//                           },
//                           style: const TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           decoration: const InputDecoration(
//                             hintText: "Playlist title",
//                             border: InputBorder.none,
//                             hintStyle: TextStyle(color: Colors.grey),
//                           ),
//                         ),
//                         const Divider(),

//                         // 3. Description Input
//                         TextFormField(
//                           controller: _descriptionController,

//                           validator: (v) {
//                             if (v == null || v.isEmpty) {
//                               return 'required';
//                             }

//                             return null;
//                           },
//                           maxLines: 3,
//                           decoration: const InputDecoration(
//                             hintText: "Give your playlist a description...",
//                             border: InputBorder.none,
//                           ),
//                         ),
//                         const Divider(),

//                         // 4. Privacy/Visibility (The Facebook "Audience Selector" style)
//                         ListTile(
//                           contentPadding: EdgeInsets.zero,
//                           leading: CircleAvatar(
//                             backgroundColor: Colors.grey.shade200,
//                             child: Icon(
//                               _isPublic ? Icons.public : Icons.lock,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           title: const Text("Who can see this?"),
//                           subtitle: Text(_isPublic ? "Public" : "Only Me"),
//                           trailing: Switch(
//                             value: _isPublic,
//                             onChanged: (val) => setState(() => _isPublic = val),
//                             activeColor: Colors.blueAccent,
//                           ),
//                         ),
//                         const Divider(),

//                         // 5. Access Type (Free vs Paid)
//                         _buildAccessDropdown(),

//                         if (_accessType == 'paid') ...[
//                           const SizedBox(height: 10),
//                           Row(
//                             children: [
//                               Expanded(child: _buildPriceField()),
//                               const SizedBox(width: 15),
//                               Expanded(child: _buildCurrencyDropdown()),
//                             ],
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // --- Facebook Style Dropdown Methods ---

//   Widget _buildAccessDropdown() {
//     return ListTile(
//       contentPadding: EdgeInsets.zero,
//       leading: CircleAvatar(
//         backgroundColor: Colors.grey.shade200,
//         child: const Icon(Icons.monetization_on, color: Colors.black87),
//       ),
//       title: const Text("Access Type"),
//       trailing: DropdownButton<String>(
//         value: _accessType,
//         underline: const SizedBox(),
//         items: const [
//           DropdownMenuItem(value: 'free', child: Text("Free")),
//           DropdownMenuItem(value: 'paid', child: Text("Paid")),
//         ],
//         onChanged: (val) => setState(() => _accessType = val!),
//       ),
//     );
//   }

//   Widget _buildCurrencyDropdown() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: _selectedCurrency,
//           isExpanded: true,
//           items: const [
//             DropdownMenuItem(value: "USD", child: Text("USD")),
//             DropdownMenuItem(value: "EUR", child: Text("EUR")),
//             DropdownMenuItem(value: "GBP", child: Text("GBP")),
//           ],
//           onChanged: (val) => setState(() => _selectedCurrency = val!),
//         ),
//       ),
//     );
//   }

//   Widget _buildPriceField() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: TextFormField(
//         controller: _priceController,
//         validator: (v) {
//           if (v == null || v.isEmpty) {
//             return 'required';
//           }

//           if (num.tryParse(v) == null) {
//             return 'Enter a valid amount';
//           }

//           if (num.tryParse(v)! <= 0) {
//             return 'Enter a valid amount';
//           }
//           return null;
//         },
//         keyboardType: TextInputType.number,
//         decoration: const InputDecoration(
//           hintText: "0.00",
//           border: InputBorder.none,
//           labelText: "Price",
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/content-creator/controller/creator_controller.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/content-creator/widgets/success_dialog.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

class UpdatePlayListWidget extends StatefulWidget {
  final Playlist playlist;
  const UpdatePlayListWidget({super.key, required this.playlist});

  @override
  StateMVC<UpdatePlayListWidget> createState() => _UpdatePlayListWidgetState();
}

class _UpdatePlayListWidgetState extends StateMVC<UpdatePlayListWidget> {
  final _formKey = GlobalKey<FormState>();
  late CreatorController _con;

  _UpdatePlayListWidgetState() : super(CreatorController()) {
    _con = controller as CreatorController;
  }

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;

  String _accessType = 'free';
  String _selectedCurrency = 'USD';
  bool _isPublic = false;
  File? _thumbnailFile;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final p = widget.playlist;
    _titleController = TextEditingController(text: p.title ?? '');
    _descriptionController = TextEditingController(text: p.description ?? '');
    _priceController = TextEditingController(text: p.price?.toString() ?? '');
    _accessType = p.type ?? 'free';
    _isPublic = (p.isPublic == true);
    _selectedCurrency = p.currency ?? 'USD';
  }

  Future<void> _pickThumbnail() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _thumbnailFile = File(image.path));
      _con.updatePlayListThumb(_thumbnailFile!, widget.playlist.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomOverlay(
      loading: _con.loading,
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
            "Update Playlist",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // 1. Thumbnail Section (Update logic preserved)
              _buildThumbnailPicker(isDark),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("General Info"),
                      _buildTextField(
                        "Playlist Title",
                        _titleController,
                        Icons.title,
                        isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        "Description",
                        _descriptionController,
                        Icons.notes,
                        isDark,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle("Visibility"),
                      _buildSwitchTile(
                        "Public Playlist",
                        _isPublic
                            ? "Visible to everyone"
                            : widget.playlist.thumbnailUrl == null
                            ? "Update thumbanail to update visibility"
                            : "Only you can see this",
                        _isPublic,
                        (val) => setState(() => _isPublic = val),
                        isDark,
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle("Access & Pricing"),
                      _buildDropdownField(
                        "Access Type",
                        _accessType,
                        ['free', 'paid'],
                        (val) => setState(() => _accessType = val!),
                        isDark,
                        icon: Icons.monetization_on_outlined,
                      ),

                      if (_accessType == 'paid') ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                "Price",
                                _priceController,
                                Icons.payments,
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

                      const SizedBox(height: 40),
                      _buildSubmitButton(),
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

  Widget _buildThumbnailPicker(bool isDark) {
    ImageProvider? imageProvider;
    if (_thumbnailFile != null) {
      imageProvider = FileImage(_thumbnailFile!);
    } else if (widget.playlist.thumbnailUrl != null) {
      imageProvider = NetworkImage(widget.playlist.thumbnailUrl!);
    }

    return GestureDetector(
      onTap: _pickThumbnail,
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.grey.shade100,
          image: imageProvider != null
              ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
              : null,
        ),
        child: imageProvider == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 50,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Update Playlist Thumbnail",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              )
            : Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(12),
                child: const CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
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

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        value: value,
        activeColor: const Color(0xFF679E4F),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF679E4F), Color(0xFFBCCB4F)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: _handleUpdate,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: const Text(
          "UPDATE PLAYLIST",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Future<void> _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      Map map = {
        "id": widget.playlist.id,
        "title": _titleController.text,
        "description": _descriptionController.text,
        "type": _accessType,
        "price": _priceController.text.isEmpty ? 0.00 : _priceController.text,
        "currency": _selectedCurrency,
        "is_public": _isPublic,
      };
      Playlist? channel = await _con.updatePlaylist(map);
      if (channel != null) {
        _showSuccess(context);
      } else {
        CustomMessageHandler().showErrorSnakeBar(
          context,
          "Something went wrong. Try again",
        );
      }
    }
  }

  void _showSuccess(BuildContext dialogContext) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => SuccessDialog(
        message: "Your playlist has been updated successfully!",
        onDismiss: () {
          Navigator.of(dialogContext).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
