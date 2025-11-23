import 'package:equatable/equatable.dart';

class EventInfo extends Equatable {
  final String eventName;
  final String eventInfo;
  final String userName;
  final String date;

  const EventInfo({
    required this.eventName,
    required this.eventInfo,
    required this.userName,
    required this.date,
  });
  EventInfo copyWith({
    final String? eventName,
    final String? eventInfo,
    final String? userName,
    final String? date,
  }) {
    return EventInfo(
      eventName: eventName ?? this.eventName,
      eventInfo: eventInfo ?? this.eventInfo,
      userName: userName ?? this.userName,
      date: date ?? this.date,
    );
  }

  @override
  List<Object?> get props => [eventInfo, eventName, userName, date];
}
