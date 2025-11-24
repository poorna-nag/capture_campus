import 'package:capture_campus/features/home/data/photo_model.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
  });
}

class EventModel {
  final String id;
  final String name; // folder name
  final String uploaderId;
  final String uploaderName;
  final String uploaderEmail;
  final String description;
  final DateTime createdAt;
  final List<PhotoModel> photos;
  EventModel({
    required this.id,
    required this.name,
    required this.uploaderId,
    required this.uploaderName,
    required this.uploaderEmail,
    required this.description,
    required this.createdAt,
    required this.photos,
  });
}
