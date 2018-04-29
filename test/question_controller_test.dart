import 'harness/app.dart';
import 'package:quiz/model/question.dart';

Future main() async {
  TestApplication app = new TestApplication();

  setUpAll(() async {
    await app.start();

    var questions = [
      new Question()..description = "How much wood can a woodchuck chuck?",
      new Question()..description = "What's the tallest mountain in the world?",
    ];

    await Future.forEach(questions, (q) {
      var query = new Query<Question>()..values = q;
      return query.insert();
    });
  });

  tearDownAll(() async {
    await app.stop();
  });

  test("/questions returns list of questions", () async {
    var request = app.client.request("/questions");
    expectResponse(await request.get(), 200,
        body: allOf([
          hasLength(greaterThan(0)),
          everyElement(containsPair("description", endsWith("?")))
        ]));
  });

  test("/questions/index returns a single question", () async {
    expectResponse(await app.client.request("/questions/1").get(), 200,
        body: containsPair("description", endsWith("?")));
  });

  test("/questions/index out of range returns 404", () async {
    expectResponse(await app.client.request("/questions/100").get(), 404);
  });
}
