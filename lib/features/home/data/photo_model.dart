class PhotoModel {
  final String id;
  final String storagePath; // e.g. users/{uid}/events/{eventId}/{filename}.jpg
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  PhotoModel({
    required this.id,
    required this.storagePath,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });
}