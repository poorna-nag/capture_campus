import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

class EventInfo extends Equatable {
  final List<XFile> images;
  final String eventName;
  final String eventInfo;
  final String userName;
  final String date;
  

  const EventInfo({
    required this.eventName,
    required this.eventInfo,
    required this.userName,
    required this.date,
    required this.images,

  });
  EventInfo copyWith({
    String? imagePath,
    final String? eventName,
    final String? eventInfo,
    final String? userName,
    final String? date,
    final List<XFile>? images,
  }) {
    return EventInfo(
      eventName: eventName ?? this.eventName,
      eventInfo: eventInfo ?? this.eventInfo,
      userName: userName ?? this.userName,
      date: date ?? this.date,
      images: images ?? this.images,
    );
  }

  @override
  List<Object?> get props => [eventInfo, eventName, userName, date, images];
}
