import '../quiz.dart';
import 'answer.dart';

class Question extends ManagedObject<_Question> implements _Question {}

class _Question {
  @managedPrimaryKey
  int index;

  String description;
  ManagedSet<Answer> answers;
}
