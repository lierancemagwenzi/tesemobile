/// token : "eyJhbGciOiJIUzUxMiJ9.eyJVc2VySWQiOjEsInJvbGVzIjpbIkNVU1RPTUVSIl0sInN1YiI6InVkZWFuQHNtYXRlY2hncm91cC5jb20iLCJpYXQiOjE3MzA4NjgyNjEsImV4cCI6MTczMDg4NjI2MX0.2MUzPF1CUK0dv50-FYgTnFrr95LS0DL-7zKz6t0yrX5hcsvagEgc1yej-xsTp6JRKrAKNABW8pUJj06wrOEjiA"
/// user : {"id":1,"email":"udean@smatechgroup.com","firstName":"John","lastName":"Doe","role":"CUSTOMER","token":"eyJhbGciOiJIUzUxMiJ9.eyJVc2VySWQiOjEsInJvbGVzIjpbIkNVU1RPTUVSIl0sInN1YiI6InVkZWFuQHNtYXRlY2hncm91cC5jb20iLCJpYXQiOjE3MzA4NjgyNjEsImV4cCI6MTczMDg4NjI2MX0.2MUzPF1CUK0dv50-FYgTnFrr95LS0DL-7zKz6t0yrX5hcsvagEgc1yej-xsTp6JRKrAKNABW8pUJj06wrOEjiA","accountId":0,"activationActivated":null}
/// errorResponse : {"errorMessage":null,"statusCode":0}

class UserModel {
  UserModel({String? token, User? user, ErrorResponse? errorResponse}) {
    _token = token;
    _user = user;
    _errorResponse = errorResponse;
  }

  UserModel.fromJson(dynamic json) {
    _token = json['token'];
    _user = json['user'] != null ? User.fromJson(json['user']) : null;
    _errorResponse = json['errorResponse'] != null
        ? ErrorResponse.fromJson(json['errorResponse'])
        : null;
  }
  String? _token;
  User? _user;
  ErrorResponse? _errorResponse;
  UserModel copyWith({
    String? token,
    User? user,
    ErrorResponse? errorResponse,
  }) => UserModel(
    token: token ?? _token,
    user: user ?? _user,
    errorResponse: errorResponse ?? _errorResponse,
  );
  String? get token => _token;
  User? get user => _user;
  ErrorResponse? get errorResponse => _errorResponse;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['token'] = _token;
    if (_user != null) {
      map['user'] = _user?.toJson();
    }
    if (_errorResponse != null) {
      map['errorResponse'] = _errorResponse?.toJson();
    }
    return map;
  }
}

/// errorMessage : null
/// statusCode : 0

class ErrorResponse {
  ErrorResponse({dynamic errorMessage, num? statusCode}) {
    _errorMessage = errorMessage;
    _statusCode = statusCode;
  }

  ErrorResponse.fromJson(dynamic json) {
    _errorMessage = json['errorMessage'];
    _statusCode = json['statusCode'];
  }
  dynamic _errorMessage;
  num? _statusCode;
  ErrorResponse copyWith({dynamic errorMessage, num? statusCode}) =>
      ErrorResponse(
        errorMessage: errorMessage ?? _errorMessage,
        statusCode: statusCode ?? _statusCode,
      );
  dynamic get errorMessage => _errorMessage;
  num? get statusCode => _statusCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['errorMessage'] = _errorMessage;
    map['statusCode'] = _statusCode;
    return map;
  }
}

/// id : 1
/// email : "udean@smatechgroup.com"
/// firstName : "John"
/// lastName : "Doe"
/// role : "CUSTOMER"
/// token : "eyJhbGciOiJIUzUxMiJ9.eyJVc2VySWQiOjEsInJvbGVzIjpbIkNVU1RPTUVSIl0sInN1YiI6InVkZWFuQHNtYXRlY2hncm91cC5jb20iLCJpYXQiOjE3MzA4NjgyNjEsImV4cCI6MTczMDg4NjI2MX0.2MUzPF1CUK0dv50-FYgTnFrr95LS0DL-7zKz6t0yrX5hcsvagEgc1yej-xsTp6JRKrAKNABW8pUJj06wrOEjiA"
/// accountId : 0
/// activationActivated : null

class User {
  // Personal Details
  final String? name;
  final String? lastname;
  final String? email;
  final String? phone;
  final String? title;
  final String? gender;
  final String? nationality;

  // Account/Auth Details
  final String? userType;
  final String? password;
  final int? otp;
  final String? status;
  final String? deviceToken;
  final String? communicationId;
  final bool? receiveNotifications; // Boolean is now nullable

  // Verification/Identification Details
  final DateTime? emailVerifiedAt;
  final int? nationalIdentificationTypeId;
  final String? nationalIdentificationType;
  final String? nationalIdentification;
  final String? selfie;
  final String? nationalIdFront;
  final String? nationalIdBack;

  // Timestamps and ID
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? id;
  final int? isFollowing;
  final int? videoCount;
  final int? channelCount;
  final int? followerCount;

  final String? description;

  final String? fireBaseToken;
  final String? banner;
  final String? slug;
  final int? totalViews;
  User({
    this.name,
    this.lastname,
    this.email,
    this.userType,
    this.status,
    this.receiveNotifications,
    this.phone,
    this.password,
    this.otp,
    this.emailVerifiedAt,
    this.deviceToken,
    this.communicationId,
    this.nationality,
    this.nationalIdentificationTypeId,
    this.nationalIdentificationType,
    this.nationalIdentification,
    this.title,
    this.selfie,
    this.gender,
    this.nationalIdFront,
    this.nationalIdBack,
    this.createdAt,
    this.updatedAt,
    this.id,
    this.channelCount,
    this.followerCount,
    this.isFollowing,
    this.videoCount,
    this.description,
    this.fireBaseToken,
    this.banner,
    this.slug,
    this.totalViews,
  });

  // --- Factory Constructor for JSON Deserialization (FROM JSON) ---
  factory User.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse a DateTime string or return null
    DateTime? parseDate(dynamic date) {
      if (date == null) return null;
      if (date is String) return DateTime.tryParse(date);
      return null;
    }

    // Helper function to safely parse an integer or return null
    int? parseInt(dynamic value) {
      if (value == null) return null;
      // Casts 'num' types (like double) or 'int' to int?
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    return User(
      // Nullable Strings
      name: json['name'] as String?,
      lastname: json['lastname'] as String?,
      email: json['email'] as String?,
      userType: json['user_type'] as String?,
      status: json['status'] as String?,
      phone: json['phone'] as String?,
      password: json['password'] as String?,
      deviceToken: json['device_token'] as String?,
      communicationId: json['communication_id'] as String?,
      nationality: json['nationality'] as String?,
      nationalIdentificationType:
          json['national_identification_type'] as String?,
      nationalIdentification: json['national_identification'] as String?,
      title: json['title'] as String?,
      selfie: json['selfie'] as String?,
      banner: json['banner'] as String?,
      gender: json['gender'] as String?,
      nationalIdFront: json['national_id_front'] as String?,
      nationalIdBack: json['national_id_back'] as String?,
      description: json['description'] as String?,
      // Nullable Boolean
      receiveNotifications: json['receive_notifications'] as bool?,

      // Nullable DateTimes (using the helper)
      emailVerifiedAt: parseDate(json['email_verified_at']),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      fireBaseToken: json['fireBaseToken'],

      // Nullable Integers (using the helper)
      otp: parseInt(json['otp']),

      followerCount: parseInt(json['followerCount']),
      channelCount: parseInt(json['channelCount']),
      videoCount: parseInt(json['videoCount']),
      isFollowing: parseInt(json['isFollowing']),

      nationalIdentificationTypeId: parseInt(
        json['national_identification_type_id'],
      ),
      id: parseInt(json['id']),
      slug: json['slug'] as String?,
      totalViews: parseInt(json['total_views']),
    );
  }
  get fullname => "${name ?? ''} ${lastname ?? ''}";
  get username =>
      '${name?.trim().toLowerCase()}${lastname?.trim().toLowerCase()}-$id'
          .replaceAll(' ', '');

  bool get isClient => userType == 'client';

  // Optional: Method for JSON serialization (TO JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastname': lastname,
      'email': email,
      'user_type': userType,
      'status': status,
      'receive_notifications': receiveNotifications,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      // ... include all other fields
    };
  }
}
