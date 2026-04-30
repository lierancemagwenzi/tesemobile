class VideoDownloadLink {
  String? link;

  VideoDownloadLink({this.link});

  factory VideoDownloadLink.fromJson(Map<String, dynamic> json) {
    return VideoDownloadLink(link: json['link'] as String);
  }
}
