import Foundation

protocol QuestionFactoryProtocol {
    var questionsAmount: Int { get }
    func requestNextQuestion(completion: (QuizQuestion?) -> Void)
}
