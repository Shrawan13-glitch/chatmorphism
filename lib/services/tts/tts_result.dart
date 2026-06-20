import 'dart:typed_data';

class TtsItem {
  final String text;
  final String voice;
  final double speed;

  const TtsItem({
    required this.text,
    this.voice = 'af_sky',
    this.speed = 1.0,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'voice': voice,
    'speed': speed,
  };
}

enum TtsStatus {
  queued,
  triggering,
  waiting,
  downloading,
  completed,
  failed,
}

class TtsResult {
  final TtsStatus status;
  final Uint8List? wavBytes;
  final String? vfsPath;
  final String? message;
  final int durationSeconds;

  const TtsResult({
    this.status = TtsStatus.queued,
    this.wavBytes,
    this.vfsPath,
    this.message,
    this.durationSeconds = 0,
  });

  bool get isCompleted => status == TtsStatus.completed;
  bool get isFailed => status == TtsStatus.failed;
}
