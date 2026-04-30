import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/src/content-creator/controller/creator_controller.dart';
import 'package:smacredit/src/content-creator/events/models/event_model.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key, required Null Function() onPop});

  @override
  StateMVC<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends StateMVC<CreateEventScreen> {
  late CreatorController _con;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Form Fields
  String title = '';
  String description = '';
  double price = 0.0;
  String currency = 'USD';
  DateTime? startDate;
  DateTime? endDate;
  File? thumbnail;

  _CreateEventScreenState() : super(CreatorController()) {
    _con = controller as CreatorController;
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => thumbnail = File(image.path));
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(minutes: 5)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          final fullDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
          if (isStart)
            startDate = fullDate;
          else
            endDate = fullDate;
        });
      }
    }
  }

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate() && thumbnail != null) {
      if (startDate == null || endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select event dates")),
        );
        return;
      }

      _formKey.currentState!.save();

      final DateFormat customFormatter = DateFormat('yyyy-MM-dd:HH:mm');

      // Format your DateTime objects
      String formattedStart = customFormatter.format(
        startDate!,
      ); // 2025-02-03:10:30
      String formattedEnd = customFormatter.format(endDate!);

      EventModel? event = await _con.createLiveStream(thumbnail!, {
        "title": title,
        "description": description,
        "price": price,
        "currency": currency,
        "start_date": formattedStart,
        "end_date": formattedEnd,
      });

      if (event != null) {
        TeseSuccessDialog.show(
          context,
          title: "Event Created",
          message:
              "Your live stream has been scheduled and is ready for your audience!",
          onDismiss: () {
            Navigator.pop(context); // Close dialog
            Navigator.pop(context); // Go back to previous screen
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Something went wrong.Try again")),
        );
      }

      // Sending to controller
      // _con.createEvent(

      // );
    } else if (thumbnail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload a thumbnail")),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _con.serverHeartBeat();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color teseGreen = const Color(0xFF00D285);

    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        appBar: AppBar(title: const Text("Create Live Event"), elevation: 0),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. THUMBNAIL PICKER
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                      image: thumbnail != null
                          ? DecorationImage(
                              image: FileImage(thumbnail!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: thumbnail == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.imagePlus,
                                size: 40,
                                color: teseGreen,
                              ),
                              const SizedBox(height: 10),
                              const Text("Upload Event Thumbnail"),
                            ],
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 25),

                // 2. TITLE
                _buildLabel("Event Title"),
                TextFormField(
                  decoration: _inputDecoration(
                    "e.g. Afrobeat Night Live",
                    isDark,
                  ),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  validator: (v) => v!.isEmpty ? "Title required" : null,
                  onSaved: (v) => title = v!,
                ),
                const SizedBox(height: 20),

                // 3. DESCRIPTION
                _buildLabel("Description"),
                TextFormField(
                  maxLines: 3,
                  decoration: _inputDecoration(
                    "Tell your audience what to expect...",
                    isDark,
                  ),
                  onSaved: (v) => description = v!,
                ),
                const SizedBox(height: 20),

                // 4. DATE PICKERS
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                        "Start Date",
                        startDate,
                        () => _selectDate(context, true),
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildDateField(
                        "End Date",
                        endDate,
                        () => _selectDate(context, false),
                        isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 5. PRICE & CURRENCY
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Ticket Price"),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration("0.00", isDark),
                            onSaved: (v) =>
                                price = double.tryParse(v ?? '0') ?? 0,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Currency"),
                          DropdownButtonFormField<String>(
                            value: currency,
                            dropdownColor: isDark
                                ? Colors.grey[900]
                                : Colors.white,
                            decoration: _inputDecoration("", isDark),
                            items: ['ZWG', 'USD']
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => currency = v!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // 6. SUBMIT BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: teseGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "CREATE EVENT",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    ),
  );

  InputDecoration _inputDecoration(String hint, bool isDark) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  Widget _buildDateField(
    String label,
    DateTime? date,
    VoidCallback onTap,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.calendar,
                  size: 18,
                  color: Color(0xFF00D285),
                ),
                const SizedBox(width: 8),
                Text(
                  date == null
                      ? "Select"
                      : DateFormat('MMM d, HH:mm').format(date),
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TeseSuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onDismiss;

  const TeseSuccessDialog({
    super.key,
    this.title = "Success!",
    this.message = "Your action was completed successfully.",
    this.buttonText = "Awesome",
    required this.onDismiss,
  });

  static void show(
    BuildContext context, {
    String? title,
    String? message,
    VoidCallback? onDismiss,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TeseSuccessDialog(
        title: title ?? "Success!",
        message: message ?? "Your action was completed successfully.",
        onDismiss: onDismiss ?? () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const Color teseGreen = Color(0xFF00D285);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. ANIMATED-STYLE SUCCESS ICON
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: teseGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.checkCircle2,
                color: teseGreen,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),

            // 2. TEXT CONTENT
            Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // 3. ACTION BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onDismiss,
                style: ElevatedButton.styleFrom(
                  backgroundColor: teseGreen,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
