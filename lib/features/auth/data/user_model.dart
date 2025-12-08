class UserModel {
  final String campusName;
  final String email;
  final String? phone;
  final String passCode;
  UserModel({
    required this.campusName,
    required this.email,
    this.phone,
    required this.passCode,
  });

  factory UserModel.json(Map<String, dynamic> json) {
    return UserModel(
      campusName: json['campusName'],
      email: json['email'],
      passCode: json['passCode'],
    );
  }
}

// class EventModel {
//   final String id;
//   final String name; // folder name
//   final String uploaderId;
//   final String uploaderName;
//   final String uploaderEmail;
//   final String description;
//   final DateTime createdAt;
//   final List<PhotoModel> photos;
//   EventModel({
//     required this.id,
//     required this.name,
//     required this.uploaderId,
//     required this.uploaderName,
//     required this.uploaderEmail,
//     required this.description,
//     required this.createdAt,
//     required this.photos,
//   });
// }
