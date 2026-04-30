class S3UploadResponse {
  final String uploadUrl;
  final String fileName;
  final String title;
  final int videoId;
  S3UploadResponse({
    required this.uploadUrl,
    required this.fileName,
    required this.title,
    required this.videoId,
  });

  // Factory to convert JSON Map to Model
  factory S3UploadResponse.fromJson(Map<String, dynamic> json) {
    return S3UploadResponse(
      uploadUrl: json['uploadUrl'] ?? '',
      fileName: json['fileName'] ?? '',
      title: json['title'] ?? '',
      videoId: json['video_id'] ?? '',
    );
  }

  // To convert back to JSON if needed for local storage
  Map<String, dynamic> toJson() {
    return {'uploadUrl': uploadUrl, 'fileName': fileName};
  }
}
