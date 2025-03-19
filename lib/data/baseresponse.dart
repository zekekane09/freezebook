class BaseResponse {
  final String code;
  final String message;
  final dynamic payload; // Change this to dynamic or Map<String, dynamic>

  BaseResponse({
    required this.code,
    required this.message,
    this.payload,
  });

  // Factory constructor to create a BaseResponse from JSON
  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    return BaseResponse(
      code: json['code'] as String,
      message: json['message'] as String,
      payload: json['payload'], // Keep this as dynamic to accommodate different types
    );
  }

  // Method to convert BaseResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'payload': payload,
    };
  }
}