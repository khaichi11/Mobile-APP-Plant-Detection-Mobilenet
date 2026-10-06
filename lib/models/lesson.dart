import 'story.dart';

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.summary,
    required this.art,
    required this.sections,
    required this.minutes,
  });

  final String id;
  final String title;
  final String summary;
  final StoryArt art;
  final List<LessonSection> sections;
  final int minutes;
}

class LessonSection {
  const LessonSection(this.heading, this.body);
  final String heading;
  final String body;
}
