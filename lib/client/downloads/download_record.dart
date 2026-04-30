class DownloadRecord {
  final int videoId;
  final String taskId;
  final String videoName;
  final String fileName;
  final String type;
  final String? artist;
  final String? album;

  const DownloadRecord({
    required this.videoId,
    required this.taskId,
    required this.videoName,
    required this.fileName,
    required this.type,
    this.artist,
    this.album,
  });

  factory DownloadRecord.fromMap(Map<String, dynamic> map) {
    return DownloadRecord(
      videoId: map['videoId'] as int,
      taskId: map['taskId'] as String,
      videoName: map['videoName'] as String,
      fileName: map['fileName'] as String,
      type: (map['type'] as String?) ?? 'video',
      artist: map['artist'] as String?,
      album: map['album'] as String?,
    );
  }

  bool get isMusic => type == 'music';
}
