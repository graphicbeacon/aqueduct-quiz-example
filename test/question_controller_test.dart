import 'harness/app.dart';
import 'package:quiz/model/question.dart';
import 'package:quiz/model/answer.dart';

Future main() async {
  TestApplication app = new TestApplication();

  setUpAll(() async {
    await app.start();

    var questions = [
      new Question()
        ..description = "How much wood can a woodchuck chuck?"
        ..answers = (new ManagedSet()
          ..add(new Answer()..description = "Depends")
          ..add(new Answer()..description = "At least one perhaps")),
      new Question()
        ..description = "What's the tallest mountain in the world?"
        ..answers = (new ManagedSet()
          ..add(new Answer()..description = "Mount Everest")),
    ];

    await Future.forEach(questions, (Question q) async {
      var query = new Query<Question>()..values = q;
      var insertedQuestion = await query.insert();

      var answers = q.answers;
      await Future.forEach(answers, (Answer a) async {
        var answer = new Query<Answer>()
          ..values = a
          ..values.question = insertedQuestion;
        return (await answer.insert());
      });
      return insertedQuestion;
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
          everyElement(partial({
            "description": endsWith("?"),
            "answers": allOf([
              everyElement(partial({"description": isString}))
            ])
          }))
        ]));
  });

  test("/questions/index returns a single question", () async {
    expectResponse(await app.client.request("/questions/1").get(), 200,
        body: partial({
          "description": endsWith("?"),
          "answers": allOf([
            everyElement(partial({"description": isString}))
          ])
        }));
  });

  test("/questions/index out of range returns 404", () async {
    expectResponse(await app.client.request("/questions/100").get(), 404);
  });

  test("/questions returns list of questions filtered by contains", () async {
    var request = app.client.request("/questions?contains=mountain");
    expectResponse(await request.get(), 200, body: [
      {
        "index": greaterThanOrEqualTo(0),
        "description": "What's the tallest mountain in the world?",
        "answers": allOf([
          everyElement(partial({"description": "Mount Everest"}))
        ])
      }
    ]);
  });
}
