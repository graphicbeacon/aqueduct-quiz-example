import '../quiz.dart';
import 'question.dart';

class Answer extends ManagedObject<_Answer> implements _Answer {}

class _Answer {
  @managedPrimaryKey
  int id;

  String description;

  // This decorator creates a relationship between
  // Question and Answer classes, in particular the
  // `answer` prop on the Question class. Only one of
  // the linked classes can have this meta data
  @ManagedRelationship(#answers,
      onDelete: ManagedRelationshipDeleteRule.cascade, isRequired: true)
  Question question;
}
