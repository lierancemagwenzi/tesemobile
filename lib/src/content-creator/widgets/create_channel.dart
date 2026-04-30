// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'dart:io';

// import 'package:mvc_pattern/mvc_pattern.dart';
// import 'package:smacredit/src/content-creator/controller/creator_controller.dart';
// import 'package:smacredit/src/content-creator/models/category_model.dart';
// import 'package:smacredit/src/content-creator/models/channel_model.dart';
// import 'package:smacredit/src/content-creator/widgets/success_dialog.dart';
// import 'package:smacredit/src/helpers/Message.dart';
// import 'package:smacredit/src/repositories/user_repository.dart';
// import 'package:smacredit/src/widgets/CustomOverlay.dart';

// class CreateChannelPage extends StatefulWidget {
//   const CreateChannelPage({super.key});

//   @override
//   StateMVC<CreateChannelPage> createState() => _CreateChannelPageState();
// }

// class _CreateChannelPageState extends StateMVC<CreateChannelPage> {
//   late CreatorController _con;

//   _CreateChannelPageState() : super(CreatorController()) {
//     _con = controller as CreatorController;
//   }
//   final _formKey = GlobalKey<FormState>();
//   // File states
//   File? _coverImage;
//   File? _logoImage;

//   CategoryModel? categoryModel;

//   // Controllers
//   final _nameController = TextEditingController();
//   final _descController = TextEditingController();
//   final _priceController = TextEditingController();

//   // Boolean states
//   bool _subscriptionEnabled = false;
//   bool _isPublic = true;

//   // Dropdown states
//   String _selectedCurrency = 'USD';
//   String _selectedPeriod = 'Monthly';
//   String _selectedStatus = 'Active';

//   // File Picker Logic
//   Future<void> _pickFile(bool isLogo) async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.image,
//     );

//     final Color brandGreen = const Color(0xFF00D285);
//     if (result != null) {
//       File file = File(result.files.single.path!);
//       CroppedFile? croppedFile = await ImageCropper().cropImage(
//         sourcePath: file.path,
//         aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
//         uiSettings: [
//           AndroidUiSettings(
//             toolbarTitle: 'Crop Image',
//             toolbarColor: brandGreen,
//             toolbarWidgetColor: Colors.white,
//             activeControlsWidgetColor: brandGreen,
//             initAspectRatio: CropAspectRatioPreset.original,
//             lockAspectRatio: false,
//             aspectRatioPresets: [
//               CropAspectRatioPreset.original,
//               CropAspectRatioPreset.square,
//               CropAspectRatioPreset.ratio4x3,
//             ],
//           ),
//           IOSUiSettings(
//             title: 'Crop Image',

//             aspectRatioPresets: [
//               CropAspectRatioPreset.original,
//               CropAspectRatioPreset.square,
//               CropAspectRatioPreset.ratio4x3,
//             ],
//           ),
//         ],
//       );

//       if (croppedFile != null) {
//         if (isLogo) {
//           setState(() {
//             _logoImage = File(croppedFile.path);

//             _con.uploadProfile(_logoImage!);
//           });
//         } else {
//           setState(() {
//             _coverImage = File(croppedFile.path);
//           });
//           _con.uploadCover(_coverImage!);
//         }
//       }
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _con.listenForCategoies();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomOverlay(
//       loading: _con.loading,
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF9F9F9),
//         key: _con.scaffoldKey,
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0.5,
//           leading: IconButton(
//             icon: const Icon(Icons.close, color: Colors.black),
//             onPressed: () => Navigator.pop(context),
//           ),
//           title: const Text(
//             "Create Channel",
//             style: TextStyle(
//               color: Colors.black,
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {},
//               child: const Text(
//                 "Done",
//                 style: TextStyle(
//                   color: Color(0xFF679E4F),
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 // 1. MEDIA SECTION (Cover & Logo)
//                 _buildMediaHeader(),

//                 Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // 2. BASIC INFO
//                         _buildSectionTitle("General Information"),
//                         _buildTextField(
//                           "Channel Name",
//                           _nameController,
//                           Icons.title,
//                         ),
//                         const SizedBox(height: 16),
//                         _buildTextField(
//                           "Description",
//                           _descController,
//                           Icons.notes,
//                           maxLines: 3,
//                         ),

//                         const SizedBox(height: 16),
//                         _buildCategoryDropdownField(),

//                         const SizedBox(height: 24),

//                         // 3. SETTINGS & STATUS
//                         _buildSectionTitle("Visibility & Status"),
//                         _buildSwitchTile(
//                           "Public Channel",
//                           "Anyone can find and join",
//                           _isPublic,
//                           (val) => setState(() => _isPublic = val),
//                         ),
//                         const SizedBox(height: 12),
//                         _buildDropdownField(
//                           "Channel Status",
//                           _selectedStatus,
//                           ['Active', 'Disabled'],
//                           (val) => setState(() => _selectedStatus = val!),
//                         ),

//                         const SizedBox(height: 24),

//                         // 4. MONETIZATION
//                         _buildSectionTitle("Monetization"),
//                         _buildSwitchTile(
//                           "Enable Subscription",
//                           "Charge users for access",
//                           _subscriptionEnabled,
//                           (val) => setState(() => _subscriptionEnabled = val),
//                         ),

//                         if (_subscriptionEnabled) ...[
//                           const SizedBox(height: 16),
//                           Row(
//                             children: [
//                               Expanded(
//                                 flex: 2,
//                                 child: _buildTextField(
//                                   "Price",
//                                   _priceController,
//                                   Icons.attach_money,
//                                   isNumber: true,
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: _buildDropdownField(
//                                   "Currency",
//                                   _selectedCurrency,
//                                   ['USD', 'EUR', 'GBP'],
//                                   (val) =>
//                                       setState(() => _selectedCurrency = val!),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                           _buildDropdownField(
//                             "Billing Period",
//                             _selectedPeriod,
//                             ['Monthly', 'Annually'],
//                             (val) => setState(() => _selectedPeriod = val!),
//                           ),
//                         ],

//                         const SizedBox(height: 40),

//                         // 5. CREATE BUTTON
//                         _buildGradientButton(),
//                         const SizedBox(height: 50),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // --- UI COMPONENT WIDGETS ---

//   Widget _buildMediaHeader() {
//     return SizedBox(
//       height: 220,
//       child: Stack(
//         children: [
//           // Cover Image
//           GestureDetector(
//             onTap: () => _pickFile(false),
//             child: Container(
//               height: 160,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 image: _coverImage != null && _con.coverImage != null
//                     ? DecorationImage(
//                         image: FileImage(_coverImage!),
//                         fit: BoxFit.cover,
//                       )
//                     : null,
//               ),
//               child: _coverImage == null || _con.coverImage == null
//                   ? const Icon(Icons.add_a_photo, color: Colors.white, size: 40)
//                   : null,
//             ),
//           ),
//           // Circular Logo
//           Positioned(
//             bottom: 0,
//             left: 20,
//             child: GestureDetector(
//               onTap: () => _pickFile(true),
//               child: Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.white, width: 4),
//                   boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
//                   image: _logoImage != null && _con.profileImage != null
//                       ? DecorationImage(
//                           image: FileImage(_logoImage!),
//                           fit: BoxFit.cover,
//                         )
//                       : null,
//                 ),
//                 child: _logoImage == null || _con.profileImage == null
//                     ? Icon(Icons.camera_alt, color: Colors.grey[400])
//                     : null,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Text(
//         title.toUpperCase(),
//         style: const TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.bold,
//           color: Colors.grey,
//           letterSpacing: 1.1,
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(
//     String label,
//     TextEditingController controller,
//     IconData icon, {
//     int maxLines = 1,
//     bool isNumber = false,
//   }) {
//     return TextFormField(
//       controller: controller,
//       maxLines: maxLines,
//       keyboardType: isNumber ? TextInputType.number : TextInputType.text,

//       validator: (v) {
//         if (v == null || v.isEmpty) {
//           return 'required';
//         }

//         return null;
//       },
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, size: 20),
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey.shade200),
//         ),
//       ),
//     );
//   }

//   Widget _buildDropdownField(
//     String label,
//     String value,
//     List<String> items,
//     Function(String?) onChanged,
//   ) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: value,
//           isExpanded: true,
//           hint: Text(label),
//           items: items
//               .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//               .toList(),
//           onChanged: onChanged,
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryDropdownField() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<CategoryModel>(
//           value: categoryModel,
//           isExpanded: true,
//           hint: Text('Category'),
//           items: _con.categories
//               .map((e) => DropdownMenuItem(value: e, child: Text(e.name ?? "")))
//               .toList(),
//           onChanged: (v) {
//             setState(() {
//               categoryModel = v;
//             });
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildSwitchTile(
//     String title,
//     String subtitle,
//     bool value,
//     Function(bool) onChanged,
//   ) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: SwitchListTile(
//         title: Text(
//           title,
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//         ),
//         subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
//         value: value,
//         activeColor: const Color(0xFF679E4F),
//         onChanged: onChanged,
//       ),
//     );
//   }

//   Widget _buildGradientButton() {
//     return Container(
//       width: double.infinity,
//       height: 55,
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF679E4F), Color(0xFFBCCB4F)],
//         ),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: ElevatedButton(
//         onPressed: () async {
//           if (_formKey.currentState!.validate() &&
//               _con.coverImage != null &&
//               _con.profileImage != null &&
//               categoryModel != null) {
//             Map map = {
//               "name": _nameController.text,
//               "description": _descController.text,
//               "cover_image_url": _con.coverImage?.fileLink,
//               "logo_url": _con.profileImage?.fileLink,
//               "subscription_enabled": _subscriptionEnabled,
//               "subscription_price": _priceController.text,
//               "subscription_currency": _selectedCurrency,
//               "is_public": _isPublic,
//               "status": _selectedStatus,
//               "period": _selectedPeriod,
//               "category_id": categoryModel?.id,
//             };
//             Channel? channel = await _con.createChannel(map);

//             if (channel != null) {
//               _showSuccess(context);
//             } else {
//               CustomMessageHandler().showErrorSnakeBar(
//                 context,
//                 "Something went wrong.Try again",
//               );
//             }
//           } else {
//             CustomMessageHandler().showErrorSnakeBar(
//               context,
//               "Please fill in all fields including a the category, cover image and logo",
//             );
//           }
//         },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//         ),
//         child: const Text(
//           "Create Channel",
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),
//       ),
//     );
//   }

//   void _showSuccess(BuildContext dialogContext) {
//     showDialog(
//       context: context,
//       barrierDismissible: false, // User must click the button
//       builder: (BuildContext context) {
//         return SuccessDialog(
//           message: "Your new channel is ready for playlists!",
//           onDismiss: () {
//             Navigator.of(dialogContext).pop();
//             Navigator.of(context).pop(); // Close Dialog
//             // Navigate to the Channel Detail screen or List
//           },
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/content-creator/controller/creator_controller.dart';
import 'package:smacredit/src/content-creator/models/category_model.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/content-creator/widgets/success_dialog.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

class CreateChannelPage extends StatefulWidget {
  const CreateChannelPage({super.key});

  @override
  StateMVC<CreateChannelPage> createState() => _CreateChannelPageState();
}

class _CreateChannelPageState extends StateMVC<CreateChannelPage> {
  late CreatorController _con;

  _CreateChannelPageState() : super(CreatorController()) {
    _con = controller as CreatorController;
  }

  final _formKey = GlobalKey<FormState>();
  File? _coverImage;
  File? _logoImage;
  CategoryModel? categoryModel;

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();

  bool _subscriptionEnabled = false;
  bool _isPublic = true;
  String _selectedCurrency = 'USD';
  String _selectedPeriod = 'Monthly';
  String _selectedStatus = 'Active';

  @override
  void initState() {
    super.initState();
    _con.listenForCategoies();
  }

  // Logic: Combined Submit Logic for "Done" button and bottom button
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _con.coverImage != null &&
        _con.profileImage != null &&
        categoryModel != null) {
      Map map = {
        "name": _nameController.text,
        "description": _descController.text,
        "cover_image_url": _con.coverImage?.fileLink,
        "logo_url": _con.profileImage?.fileLink,
        "subscription_enabled": _subscriptionEnabled,
        "subscription_price": _priceController.text,
        "subscription_currency": _selectedCurrency,
        "is_public": _isPublic,
        "status": _selectedStatus,
        "period": _selectedPeriod,
        "category_id": categoryModel?.id,
      };

      Channel? channel = await _con.createChannel(map);

      if (channel != null) {
        _showSuccess(context);
      } else {
        CustomMessageHandler().showErrorSnakeBar(
          context,
          "Something went wrong. Try again",
        );
      }
    } else {
      CustomMessageHandler().showErrorSnakeBar(
        context,
        "Missing info: Ensure category, cover, and logo are selected.",
      );
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
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.close,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "New Channel",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w900,
            ),
          ),
          actions: [
            TextButton(
              onPressed: _submitForm,
              child: const Text(
                "Done",
                style: TextStyle(
                  color: Color(0xFF679E4F),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildMediaHeader(isDark),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("General Information", isDark),
                      _buildTextField(
                        "Channel Name",
                        _nameController,
                        Icons.title,
                        isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        "Description",
                        _descController,
                        Icons.notes,
                        isDark,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _buildCategoryDropdown(isDark),

                      const SizedBox(height: 32),
                      _buildSectionTitle("Visibility & Access", isDark),
                      _buildSwitchTile(
                        "Public Channel",
                        "Anyone can find and join this channel",
                        _isPublic,
                        (val) => setState(() => _isPublic = val),
                        isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildSwitchTile(
                        "Enable Subscription",
                        "Monetize this channel via subscription",
                        _subscriptionEnabled,
                        (val) => setState(() => _subscriptionEnabled = val),
                        isDark,
                      ),

                      if (_subscriptionEnabled) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
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
                              child: _buildSimpleDropdown(
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
                      _buildGradientButton(),
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

  Widget _buildMediaHeader(bool isDark) {
    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          // Cover Photo Container
          GestureDetector(
            onTap: () => _pickFile(false),
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey[200],
                image: _coverImage != null
                    ? DecorationImage(
                        image: FileImage(_coverImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _coverImage == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          color: isDark ? Colors.white24 : Colors.grey,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Add Cover Photo",
                          style: TextStyle(
                            color: isDark ? Colors.white24 : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
          // Logo/Avatar Container
          Positioned(
            bottom: 0,
            left: 20,
            child: GestureDetector(
              onTap: () => _pickFile(true),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? Colors.black : Colors.white,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                  image: _logoImage != null
                      ? DecorationImage(
                          image: FileImage(_logoImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _logoImage == null
                    ? Icon(
                        Icons.camera_enhance_outlined,
                        color: Colors.grey[400],
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
        labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF679E4F)),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CategoryModel>(
          value: categoryModel,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          hint: const Text(
            'Select Category',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          items: _con.categories
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e.name ?? "",
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => categoryModel = v),
        ),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: SwitchListTile(
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
        value: value,
        activeColor: const Color(0xFF679E4F),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildGradientButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF679E4F), Color(0xFFBCCB4F)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF679E4F).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: const Text(
          "Create Channel",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // --- Helpers ---
  Widget _buildSectionTitle(String title, bool isDark) => Padding(
    padding: const EdgeInsets.only(bottom: 12, left: 4),
    child: Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white38 : Colors.grey,
        letterSpacing: 1.2,
      ),
    ),
  );

  Widget _buildSimpleDropdown(
    String value,
    List<String> items,
    Function(String?) onChanged,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
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
                    e,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Future<void> _pickFile(bool isLogo) async {
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
            toolbarTitle: 'Crop Media',
            toolbarColor: const Color(0xFF679E4F),
            toolbarWidgetColor: Colors.white,
          ),
          IOSUiSettings(title: 'Crop Media'),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          if (isLogo) {
            _logoImage = File(croppedFile.path);
            _con.uploadProfile(_logoImage!);
          } else {
            _coverImage = File(croppedFile.path);
            _con.uploadCover(_coverImage!);
          }
        });
      }
    }
  }

  void _showSuccess(BuildContext dialogContext) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => SuccessDialog(
        message: "Your channel is live! Time to upload some content.",
        onDismiss: () {
          Navigator.of(dialogContext).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
