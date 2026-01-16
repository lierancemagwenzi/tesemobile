class FileSizeFormatter {
  static String formatBytes(int bytes, {int decimals = 1}) {
    if (bytes <= 0) return "0 KB";

    // Define thresholds
    const int kb = 1024;
    const int mb = kb * 1024;
    const int gb = mb * 1024;

    if (bytes < mb) {
      // If less than 1 MB, show as KB
      final double result = bytes / kb;
      return "${result.toStringAsFixed(0)} KB";
    } else if (bytes < gb) {
      // If less than 1 GB, show as MB
      final double result = bytes / mb;
      return "${result.toStringAsFixed(decimals)} MB";
    } else {
      // Otherwise show as GB
      final double result = bytes / gb;
      return "${result.toStringAsFixed(decimals)} GB";
    }
  }
}
