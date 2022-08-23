import Foundation

struct QuizQuestion {
    let image: String
    let question: String
    let correctAnswer: Bool

    init(image: String, question: String = "Рейтинг этого фильма больше чем 6?", correctAnswer: Bool) {
        self.image = image
        self.correctAnswer = correctAnswer
        self.question = question
    }
}
