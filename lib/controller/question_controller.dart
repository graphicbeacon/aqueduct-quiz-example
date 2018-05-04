import '../quiz.dart';
import '../model/question.dart';

class QuestionController extends HTTPController {
  @httpGet
  Future<Response> getAllQuestions(
      {@HTTPQuery("contains") String containsSubstring}) async {
    var questionQuery = new Query<Question>()
      ..join(set: (question) => question.answers);

    if (containsSubstring != null) {
      questionQuery.where.description = whereContainsString(containsSubstring);
    }
    var databaseQuestions = await questionQuery.fetch();
    return new Response.ok(databaseQuestions);
  }

  @httpGet
  Future<Response> getQuestionAtIndex(@HTTPPath("index") int index) async {
    var questionQuery = new Query<Question>()
      ..where.index = whereEqualTo(index) // `whereEqualTo()` query matchers
      ..join(set: (question) => question.answers);

    var question = await questionQuery.fetchOne();

    if (question == null) {
      return new Response.notFound(body: '<h1>404 Not Found</h1>')
        ..contentType = ContentType.HTML;
    }
    return new Response.ok(question);
  }
}
