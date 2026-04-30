class CloudFrontCookies {
  final String keyPairId;
  final String signature;
  final String policy;
  final int expiresAt;
  CloudFrontCookies({
    required this.keyPairId,
    required this.signature,
    required this.policy,
    required this.expiresAt,
  });

  factory CloudFrontCookies.fromJson(Map<String, dynamic> json) {
    return CloudFrontCookies(
      keyPairId: json['CloudFront-Key-Pair-Id'] as String,
      signature: json['CloudFront-Signature'] as String,
      policy: json['CloudFront-Policy'] as String,
      expiresAt: json['expiresAt'],
    );
  }

  /// Returns a single Cookie header string for CloudFront
  String get cookieHeader =>
      'CloudFront-Key-Pair-Id=$keyPairId; CloudFront-Signature=$signature; CloudFront-Policy=$policy';
}
