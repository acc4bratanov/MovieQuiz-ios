import Foundation
import UIKit

class ResultAlertPresender {
    private let controller: UIViewController

    init (controller: UIViewController) {
        self.controller = controller
    }

    func show(quiz result: QuizResultsViewModel, performHandler: @escaping () -> Void) {
        let allert = UIAlertController(title: result.title, message: result.text, preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            performHandler()
        }
        allert.addAction(action)
        controller.present(allert, animated: true, completion: nil)
    }
}
