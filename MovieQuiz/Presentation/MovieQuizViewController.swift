import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle

    // MARK: Модель логики игры Quiz
    struct Quiz {
        private(set) var numberOfCorrectAnswers = 0
        private(set) var currentQuestionIndex = 0

        private(set) var quizQuestions = [
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

        init () {
            quizQuestions.shuffle()
        }

        mutating func goToNextQuestion() {
            currentQuestionIndex += 1
        }
        mutating func addCorrectAnswer() {
            numberOfCorrectAnswers += 1
        }
        mutating func startNewGame() {
            currentQuestionIndex = 0
            numberOfCorrectAnswers = 0
            quizQuestions.shuffle()
        }
    }

    // Структура вопроса. Свойства internal.
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

    // MARK: Модель состояний интерфейса

    // Вопрос.
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
    // Результат игры
    struct QuizResultViewModel {
        let title: String
        let text: String
        let buttonText: String

        init(_ title: String, _ text: String, _ buttonText: String) {
            self.title = title
            self.text = text
            self.buttonText = buttonText
        }
        // Результат ответа
        private var isCorrectAnswer = false
    }
    // Конец описания моделей состояний

    // MARK: Коннекты
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet var answerButtons: [UIButton]!


    // MARK: Инициализация
    private var quiz = Quiz()


    override func viewDidLoad() {
        super.viewDidLoad()
        let stepVM = convertDataToStepVM(from: quiz)
        show(quiz: stepVM)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateImageLayer()
    }

    // MARK: Обработчики нажатия кнопок
    @IBAction private func didClickYesButton(_ sender: UIButton) {
        let answer = checkAnswer(of: sender)
        show(quiz: answer)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showNextQuestionOrResult()
        }
    }

    @IBAction private func didClickNoButton(_ sender: UIButton) {
        let answer = checkAnswer(of: sender)
        show(quiz: answer)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showNextQuestionOrResult()
        }
    }


    // MARK: Описание функции
    private func convertDataToStepVM(from quiz: Quiz) -> QuizStepViewModel {
        let currentQuestion = quiz.quizQuestions[quiz.currentQuestionIndex]
        let image = UIImage(named: currentQuestion.image) ?? UIImage()
        let question = currentQuestion.question
        let counter = "\(quiz.currentQuestionIndex + 1)/\(quiz.quizQuestions.count)"
        return QuizStepViewModel(image, question, counter)
    }


    private func convertDataToResultVM(from quiz: Quiz) -> QuizResultViewModel {
        var congratulation = ""
        if quiz.numberOfCorrectAnswers == quiz.quizQuestions.count {
            congratulation = "Поздравляем!"
        }
        let title = "Этот раунд окончен!"
        let text = """
                    \(congratulation)
                    Ваш результат: \(quiz.numberOfCorrectAnswers)/\(quiz.quizQuestions.count)
                    """
        let buttonText = "Сыграть еще раз"
        return QuizResultViewModel(title, text, buttonText)
    }

    private func show(quiz step: QuizStepViewModel ) {
        imageView.image = step.image
        questionLabel.text = step.question
        counterLabel.text = step.counter
    }

    private func show(quiz result: QuizResultViewModel) {
        let allert = UIAlertController(title: result.title, message: result.text, preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.quiz.startNewGame()
            let stepVM = self.convertDataToStepVM(from: self.quiz)
            self.show(quiz: stepVM)
        }
        allert.addAction(action)
        self.present(allert, animated: true, completion: nil)
    }

    // Функция отображает состояние ответа
    private func show(quiz isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        if isCorrect {
            imageView.layer.borderColor = UIColor(named: "green")?.cgColor
        } else {
            imageView.layer.borderColor = UIColor(named: "red")?.cgColor
        }
    }

    private func checkAnswer(of button: UIButton) -> Bool {
        if let buttonIndex = answerButtons.firstIndex(of: button) {
            let userAnswer = buttonIndex == 1 ? true : false
            if userAnswer == quiz.quizQuestions[quiz.currentQuestionIndex].correctAnswer {
                quiz.addCorrectAnswer()
                return true
            }
        }
        return false
    }

    private func showNextQuestionOrResult() {
        updateImageLayer()
        if quiz.currentQuestionIndex == quiz.quizQuestions.count - 1 {
            let resultVM = convertDataToResultVM(from: quiz)
            show(quiz: resultVM)
        } else {
            quiz.goToNextQuestion()
            let stepVM = convertDataToStepVM(from: quiz)
            show(quiz: stepVM)
        }
    }

    private func updateImageLayer() {
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor(named: "white")?.cgColor
    }
}
