import Foundation

struct QuizResultsViewModel {
    let title: String
    let text: String
    let buttonText: String

    init(_ title: String, _ text: String, _ buttonText: String) {
        self.title = title
        self.text = text
        self.buttonText = buttonText
    }
}
