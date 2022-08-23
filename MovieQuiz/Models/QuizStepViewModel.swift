import Foundation
import UIKit

struct QuizStepViewModel {
    let image: UIImage
    let question: String
    let counter: String

    init(_ image: UIImage, _ question: String, _ counter: String) {
        self.image = image
        self.question = question
        self .counter = counter
    }
}
