import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/payments/controller/payment_controller.dart';
import 'package:smacredit/src/payments/models/bank_account.dart';
import 'package:smacredit/src/payments/models/currencyModel.dart';
import 'package:smacredit/src/payments/models/document_type.dart';
import 'package:smacredit/src/payments/widgets/create_paylink_link.dart';
import 'package:smacredit/src/profile/models/account_info.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

class UploadDocumentWidget extends StatefulWidget {
  const UploadDocumentWidget({super.key});

  @override
  _UploadDocumentWidgetState createState() => _UploadDocumentWidgetState();
}

class _UploadDocumentWidgetState extends StateMVC<UploadDocumentWidget> {
  final _formKey = GlobalKey<FormState>();

  late PaymentController _con;

  _UploadDocumentWidgetState() : super(PaymentController()) {
    _con = controller as PaymentController;
  }
  DocumentTypeDetail? _selectedDocument;
  File? file;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _con.listenForDocumentTypes();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // --- Form Submission Logic (Placeholder) ---
  void _submitForm() async {
    // Navigator.pop(context);
    // return;
    if (file != null && _formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final formData = {
        "documentTypeId": _selectedDocument?.id,
        "documentType": _selectedDocument?.documentTypeName,
      };

      var data = await _con.uploadDocument(formData, file!);
      if (data == true) {
        CustomMessageHandler().showSuccessSnakeBar(
          _con.scaffoldKey.currentContext!,
          'document uploaded successfully',
        );
        Navigator.pop(context);
      } else {
        CustomMessageHandler().showErrorSnakeBar(
          _con.scaffoldKey.currentContext!,
          'Failed to upload document. Try again',
        );
      }
      // Here, you'd send this data to your backend API
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        key: _con.scaffoldKey,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Text
                        _buildHeaderText(),
                        const SizedBox(height: 30),
                        _buildDocumentTypeDropdown(),
                        const SizedBox(height: 30),

                        _buildLogoUpload(),
                        const SizedBox(height: 30),

                        // 10. Next Button
                        _buildNextButton(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Custom Widget Builders ---

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void pickFile() async {
    File? file = await pickSingleImageFile();

    if (file != null) {
      setState(() {
        this.file = file;
      });
    }
  }

  Future<File?> pickSingleImageFile() async {
    try {
      // 1. Configure File Picker
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        // Allow the user to select only one file
        allowMultiple: false,

        // Restrict to custom file types (extensions)
        type: FileType.custom,

        // Define the allowed extensions (case-insensitive)
        allowedExtensions: ['png', 'jpeg', 'jpg'],
      );

      // 2. Process Result
      if (result != null) {
        // Since allowMultiple is false, we can safely take the first file
        PlatformFile platformFile = result.files.first;

        // Check if the file path is available
        if (platformFile.path != null) {
          print('✅ File picked: ${platformFile.name}');
          print('File size: ${platformFile.size / 1024} KB');

          // Return a standard Dart File object
          return File(platformFile.path!);
        }
      } else {
        // User canceled the picker
        print('❌ File picking cancelled by user.');
        return null;
      }
    } catch (e) {
      print('❌ Error picking file: $e');
      return null;
    }
    return null;
  }

  Widget _buildLogoUpload() {
    // *** Using the Custom Painter Widget here ***
    return Column(
      children: [
        if (file != null) ...[
          DashedRectContainer(
            color: Colors.grey.shade400,
            child: Container(
              height: 200,
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              child: Image.file(file!, fit: BoxFit.contain),
            ),
          ),
        ],
        DashedRectContainer(
          color: Colors.grey.shade400,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 30,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Upload your document',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                InkWell(
                  onTap: () {
                    pickFile();
                  },
                  child: const Text(
                    'Browse',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentTypeDropdown() {
    return DropdownButtonFormField<DocumentTypeDetail>(
      initialValue: _selectedDocument,
      isExpanded: true, // Crucial for constrained width
      decoration: InputDecoration(
        labelText: 'Document type',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      items: _con.documentTypes.map((DocumentTypeDetail currency) {
        return DropdownMenuItem<DocumentTypeDetail>(
          value: currency,
          child: Text(currency.documentTypeName ?? ''),
        );
      }).toList(),
      onChanged: (DocumentTypeDetail? newValue) {
        setState(() {
          _selectedDocument = newValue;
        });
      },
      validator: (value) =>
          value == null ? 'Please select a document type' : null,
    );
  }

  Widget _buildHeaderText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Update your documents',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Update your documents for easier withdrawals.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildNextButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.yellow.shade700],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextButton(
        onPressed: _submitForm,
        child: const Text(
          'Next',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
