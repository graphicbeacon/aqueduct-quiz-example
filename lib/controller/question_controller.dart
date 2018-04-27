import '../quiz.dart';

class QuestionController extends HTTPController {
  List<String> questions = [
    'How much wood can a woodchuck chuck?',
    'Whats the tallest mountain in the world',
  ];

  @httpGet
  Future<Response> getAllQuestions() async {
    return new Response.ok(questions);
  }

  @httpGet
  Future<Response> getQuestionAtIndex(@HTTPPath("index") int index) async {
    if (index < 0 || index > questions.length) {
      return new Response.notFound();
    }
    return new Response.ok(questions[index]);
  }
}
