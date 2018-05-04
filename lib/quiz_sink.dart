import 'quiz.dart';
import 'controller/question_controller.dart';
import 'model/question.dart';
import 'model/answer.dart';

/// This class handles setting up this application.
///
/// Override methods from [RequestSink] to set up the resources your
/// application uses and the routes it exposes.
///
/// See the documentation in this file for the constructor, [setupRouter] and [willOpen]
/// for the purpose and order of the initialization methods.
///
/// Instances of this class are the type argument to [Application].
/// See http://aqueduct.io/docs/http/request_sink
/// for more details.
class QuizSink extends RequestSink {
  /// Constructor called for each isolate run by an [Application].
  ///
  /// This constructor is called for each isolate an [Application] creates to serve requests.
  /// The [appConfig] is made up of command line arguments from `aqueduct serve`.
  ///
  /// Configuration of database connections, [HTTPCodecRepository] and other per-isolate resources should be done in this constructor.
  QuizSink(ApplicationConfiguration appConfig) : super(appConfig) {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

    var dataModel = new ManagedDataModel.fromCurrentMirrorSystem();

    var persistentStore = new PostgreSQLPersistentStore.fromConnectionInfo(
        "dart", "dart", "localhost", 5432, "dart_test");

    context = new ManagedContext(dataModel, persistentStore);
  }

  ManagedContext context;

  /// All routes must be configured in this method.
  ///
  /// This method is invoked after the constructor and before [willOpen] Routes must be set up in this method, as
  /// the router gets 'compiled' after this method completes and routes cannot be added later.
  @override
  void setupRouter(Router router) {
    router
        .route('/questions/[:index]')
        .generate(() => new QuestionController());

    // Prefer to use `pipe` and `generate` instead of `listen`.
    // See: https://aqueduct.io/docs/http/request_controller/
    router.route("/example").listen((request) async {
      return new Response.ok({"key": "value"});
    });
  }

  /// Final initialization method for this instance.
  ///
  /// This method allows any resources that require asynchronous initialization to complete their
  /// initialization process. This method is invoked after [setupRouter] and prior to this
  /// instance receiving any requests.
  @override
  Future willOpen() async {
    await createDatabaseSchema(context);
    await populateTables();
  }

  static Future createDatabaseSchema(ManagedContext context) async {
    var builder = new SchemaBuilder.toSchema(
      context.persistentStore,
      new Schema.fromDataModel(context.dataModel),
      isTemporary: true,
    );

    for (var cmd in builder.commands) {
      await context.persistentStore.execute(cmd);
    }
  }

  static Future populateTables() async {
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
  }
}
