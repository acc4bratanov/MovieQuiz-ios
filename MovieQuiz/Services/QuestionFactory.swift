import Foundation

class QuestionFactory: QuestionFactoryProtocol {

    let questionsAmount: Int

    private var quizQuestions = [
        QuizQuestion(image: "The Godfather", correctAnswer: true),
        QuizQuestion(image: "The Dark Knight", correctAnswer: true),
        QuizQuestion(image: "Kill Bill", correctAnswer: true),
        QuizQuestion(image: "The Avengers", correctAnswer: true),
        QuizQuestion(image: "Deadpool", correctAnswer: true),
        QuizQuestion(image: "The Green Knight", correctAnswer: true),
        QuizQuestion(image: "Old", correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", correctAnswer: false),
        QuizQuestion(image: "Tesla", correctAnswer: false),
        QuizQuestion(image: "Vivarium", correctAnswer: false)
    ]

    init() {
        questionsAmount = quizQuestions.count
    }

    func requestNextQuestion(completion: (QuizQuestion?) -> Void) {
        if !quizQuestions.isEmpty {
            let index = quizQuestions.indices.randomElement()!
            let question = quizQuestions[index]
            completion(question)
        }
   }
}
