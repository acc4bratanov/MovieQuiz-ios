import Foundation

protocol QuestionFactoryDelegate {
    func didReceiveNextQuestion(_ question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
