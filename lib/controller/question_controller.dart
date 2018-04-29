import '../quiz.dart';
import '../model/question.dart';

class QuestionController extends HTTPController {
  @httpGet
  Future<Response> getAllQuestions() async {
    var questionQuery = new Query<Question>();
    var databaseQuestions = await questionQuery.fetch();

    return new Response.ok(databaseQuestions);
  }

  @httpGet
  Future<Response> getQuestionAtIndex(@HTTPPath("index") int index) async {
    var questionQuery = new Query<Question>()
      ..where.index = whereEqualTo(index); // `whereEqualTo()` query matchers

    var question = await questionQuery.fetchOne();

    if (question == null) {
      return new Response.notFound();
    }
    return new Response.ok(question);
  }
}
