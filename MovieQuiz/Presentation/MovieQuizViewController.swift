import UIKit

final class MovieQuizViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet var answerButtons: [UIButton]!

    // MARK: Properties
    private let questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    private var correctAnswers = 0
    private var currentQuestionIndex = 0
    private var isCorrectAnswer = false

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        questionFactory.requestNextQuestion { [weak self] question in
            guard
                let self = self,
                let question = question
            else {
                return
            }

            self.currentQuestion = question
            let stepVM = convert(question: question)

            DispatchQueue.main.async {
                self.show(quiz: stepVM)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateImageLayer()
    }

    // MARK: Buttons
    @IBAction private func didClickYesButton(_ sender: UIButton) {
        let result = checkAnswer(of: sender)
        showAnswerResult(isCorrect: result)
        switchButtonsAccess()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.currentQuestionIndex += 1
            self.updateImageLayer()
            self.showNextQuestionOrResult()
            self.switchButtonsAccess()
        }
    }

    @IBAction private func didClickNoButton(_ sender: UIButton) {
        let result = checkAnswer(of: sender)
        showAnswerResult(isCorrect: result)
        switchButtonsAccess()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.currentQuestionIndex += 1
            self.updateImageLayer()
            self.showNextQuestionOrResult()
            self.switchButtonsAccess()
        }
    }

    // MARK: Functions
    private func convert(question: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(named: question.image) ?? UIImage()
        let question = question.question
        let counter = "\(currentQuestionIndex + 1)/\(questionFactory.questionsAmount)"
        return QuizStepViewModel(image, question, counter)
    }

    private func show(quiz step: QuizStepViewModel ) {
        imageView.image = step.image
        questionLabel.text = step.question
        counterLabel.text = step.counter
    }

    private func show(quiz result: QuizResultsViewModel) {
        let allert = UIAlertController(title: result.title, message: result.text, preferredStyle: .alert)

        let action = UIAlertAction(title: result.buttonText, style: .default) { [self] _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0

            self.questionFactory.requestNextQuestion { [weak self] question in
                guard
                    let self = self,
                    let question = question
                else {
                    return
                }

                self.currentQuestion = question
                let stepVM = self.convert(question: question)
                DispatchQueue.main.async {
                    self.show(quiz: stepVM)
                }
            }
        }
        allert.addAction(action)
        self.present(allert, animated: true, completion: nil)
    }

    // Функция отображает состояние ответа
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        if isCorrect {
            imageView.layer.borderColor = UIColor(named: "green")?.cgColor
        } else {
            imageView.layer.borderColor = UIColor(named: "red")?.cgColor
        }
    }

    private func checkAnswer(of button: UIButton) -> Bool {
        guard let buttonIndex = answerButtons.firstIndex(of: button) else { return false }
        let userAnswer = buttonIndex == 1 ? true : false
        if userAnswer == currentQuestion?.correctAnswer {
            correctAnswers += 1
            return true
        } else {
            return false
        }
    }

    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questionFactory.questionsAmount {
            let date = getCurrentDate()
            var congratulation = ""

            if correctAnswers == questionFactory.questionsAmount {
                congratulation = "Идеально!"
            } else {
                congratulation = "Попробуйте еще раз!"
            }

            let title = "Этот раунд окончен!"
            let text = """
                            \(congratulation)
                            Ваш результат: \(correctAnswers)/\(questionFactory.questionsAmount)
                            \(date)
                            """
            let buttonText = "Сыграть еще раз"

            let resultVM = QuizResultsViewModel(title, text, buttonText)
            show(quiz: resultVM)
        } else {
            questionFactory.requestNextQuestion { [weak self] question in
                guard
                    let self = self,
                    let question = question
                else {
                    return
                }

                self.currentQuestion = question
                let stepVM = self.convert(question: question)
                DispatchQueue.main.async {
                    self.show(quiz: stepVM)
                }
            }
        }
    }

    private func updateImageLayer() {
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor(named: "white")?.cgColor
    }

    private func switchButtonsAccess() {
        for button in answerButtons {
            if button.isUserInteractionEnabled == true {
                button.isUserInteractionEnabled = false
            } else {
                button.isUserInteractionEnabled = true
            }
        }
    }

    private func getCurrentDate() -> String {
        let generatedDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy' 'HH:mm"
        let currentDate = dateFormatter.string(from: generatedDate)
        return currentDate
    }
}
