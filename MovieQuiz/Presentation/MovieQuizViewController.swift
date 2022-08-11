import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle

    // MARK: Модель логики игры Quiz
    struct Quiz {
        private(set) var numberOfCorrectAnswers = 0
        private(set) var currentQuestionIndex = 0
        private(set) var numberOfGames = 0

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

        private(set) var records: [Record] = []

        init () {
            numberOfGames += 1
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
            numberOfGames += 1
            quizQuestions.shuffle()
        }

        mutating func reloadGame() {
            currentQuestionIndex = 0
            numberOfCorrectAnswers = 0
            quizQuestions.shuffle()
        }

        mutating func addRecord() {
            records.append(Record(numberOfCorrectAnswers))
        }

        func getBestRecord() -> Record? {
            guard !records.isEmpty else { return nil }
            var bestRecord = records[0]
            for record in records where record.numberOfCorrectAnswers > bestRecord.numberOfCorrectAnswers {
                bestRecord = record
            }
            return bestRecord
        }

        func getAverageAccuracy() -> Double? {
            guard !records.isEmpty else { return nil }
            var sum = 0
            for record in records {
                sum += record.numberOfCorrectAnswers
            }
            let accuracy = ((Double(sum) / Double(records.count)) / Double(quizQuestions.count)) * 100
            return accuracy
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
    // Структура рекорда
    struct Record {
        let numberOfCorrectAnswers: Int
        let date: Date

        init(_ numberOfCorrectAnswers: Int) {
            self.numberOfCorrectAnswers = numberOfCorrectAnswers
            date = Date()
        }
    }
        // MARK: Ошибки
        enum QuizErrors: Error {
            case isEmpty
            case noImage
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
    }

    // Результат ответа
    private var isCorrectAnswer = false
    // Конец описания моделей состояний

    private struct ErrorViewModel {
        let title: String
        let text: String
        let buttonText: String

        init() {
            title = "Что-то пошло не так("
            text = "Невозможно загрузить данные"
            buttonText = "Попробовать еще раз"
        }
    }

    // MARK: Коннекты
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet var answerButtons: [UIButton]!


    // MARK: Инициализация
    private var quiz = Quiz()


    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateImageLayer()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Для того, что бы показать alert. Во viewDidLoad не выводит pop up.
        if let stepVM = try? convertDataToStepVM(from: quiz) {
            show(quiz: stepVM)
        } else {
            showError()
        }
    }

    // MARK: Обработчики нажатия кнопок
    @IBAction private func didClickYesButton(_ sender: UIButton) {
        let answer = checkAnswer(of: sender)
        show(quiz: answer)
        switchButtonsAccess()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showNextQuestionOrResult()
            self.switchButtonsAccess()
        }
    }

    @IBAction private func didClickNoButton(_ sender: UIButton) {
        let answer = checkAnswer(of: sender)
        show(quiz: answer)
        switchButtonsAccess()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showNextQuestionOrResult()
            self.switchButtonsAccess()
        }
    }


    // MARK: Описание функции
    private func convertDataToStepVM(from quiz: Quiz) throws -> QuizStepViewModel {
        let currentQuestion = quiz.quizQuestions[quiz.currentQuestionIndex]
        guard let image = UIImage(named: currentQuestion.image) else { throw QuizErrors.noImage }
        let question = currentQuestion.question
        let counter = "\(quiz.currentQuestionIndex + 1)/\(quiz.quizQuestions.count)"
        return QuizStepViewModel(image, question, counter)
    }


    private func convertDataToResultVM(from quiz: Quiz) throws -> QuizResultViewModel {
        guard let bestRecord = quiz.getBestRecord() else { throw QuizErrors.isEmpty }
        guard let accuracyOfAnswers = quiz.getAverageAccuracy() else { throw QuizErrors.isEmpty }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yy' 'HH:mm"
            let recordDate = dateFormatter.string(from: bestRecord.date)

            var congratulation = ""
            if quiz.numberOfCorrectAnswers == quiz.quizQuestions.count {
                congratulation = "Поздравляем!"
            }

            let title = "Этот раунд окончен!"
            let text = """
                        \(congratulation)
                        Ваш результат: \(quiz.numberOfCorrectAnswers)/\(quiz.quizQuestions.count)
                        Количество сыгранных квизов: \(quiz.numberOfGames)
                        Рекорд: \(bestRecord.numberOfCorrectAnswers)/\(quiz.quizQuestions.count) (\(recordDate))
                        Средняя точность: \(String(format: "%.2f", accuracyOfAnswers))%
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
            guard let stepVM = try? self.convertDataToStepVM(from: self.quiz) else {
                self.showError()
                return
            }
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

    private func showError() {
        let error = ErrorViewModel()
        let allert = UIAlertController(title: error.title, message: error.text, preferredStyle: .alert)
        let action = UIAlertAction(title: error.buttonText, style: .default) { _ in
            self.quiz.reloadGame()
            guard let stepVM = try? self.convertDataToStepVM(from: self.quiz) else {
                self.showError()
                return
            }
            self.show(quiz: stepVM)
        }
        allert.addAction(action)
        self.present(allert, animated: true, completion: nil)
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
            quiz.addRecord()
            guard let resultVM = try? convertDataToResultVM(from: quiz) else {
                showError()
                return
            }
            show(quiz: resultVM)
        } else {
            quiz.goToNextQuestion()
            guard let stepVM = try? convertDataToStepVM(from: quiz) else {
                showError()
                return
            }
            show(quiz: stepVM)
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
}
