import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: Outlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var answerButtons: [UIButton]!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    // MARK: Properties
    private var questionFactory: QuestionFactoryProtocol?
    private var resultAlertPresender: ResultAlertPresender?
    private var statisticService: StatisticServiceProtocol?
    private var currentQuestion: QuizQuestion?
    private var correctAnswers = 0
    private var currentQuestionIndex = 0
    private let questionsAmount = 10
    private var isCorrectAnswer = false

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let moviesLoader = MoviesLoader()
        questionFactory = QuestionFactory(moviesLoader: moviesLoader, delegate: self)
        resultAlertPresender = ResultAlertPresender(controller: self)
        statisticService = StatisticServiceImplementation()
        disableUserIteraction()

        DispatchQueue.main.async { [weak self] in
            self?.showLoadingIndicator()
            self?.questionFactory?.loadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateImageLayer()
    }

    // MARK: QuestionFactoryDelegate
    func didReceiveNextQuestion(_ question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let stepVM = convert(question)

        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: stepVM)
            self?.enableButtonIteraction()
        }
    }

    func didLoadDataFromServer() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.isHidden = true
            self?.questionFactory?.requestNextQuestion()
        }
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }

    // MARK: Actions
    @IBAction private func didClickYesButton(_ sender: UIButton) {
        let result = checkAnswer(of: sender)
        showAnswerResult(isCorrect: result)
        disableUserIteraction()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.currentQuestionIndex += 1
            self.updateImageLayer()
            self.showNextQuestionOrResult()
        }
    }

    @IBAction private func didClickNoButton(_ sender: UIButton) {
        let result = checkAnswer(of: sender)
        showAnswerResult(isCorrect: result)
        disableUserIteraction()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.currentQuestionIndex += 1
            self.updateImageLayer()
            self.showNextQuestionOrResult()
        }
    }

    // MARK: Private functions
    private func convert(_ question: QuizQuestion) -> QuizStepViewModel {
        print(question.image)
        let image = UIImage(data: question.image) ?? UIImage()
        let question = question.question
        let counter = "\(currentQuestionIndex + 1)/\(questionsAmount)"
        return QuizStepViewModel(image, question, counter)
    }

    private func show(quiz step: QuizStepViewModel ) {
        imageView.image = step.image
        imageView.contentMode = .scaleAspectFit
        questionLabel.text = step.question
        counterLabel.text = step.counter
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
        if currentQuestionIndex == questionsAmount {
            statisticService?.store(correct: correctAnswers, total: questionsAmount)

            guard let gameCount = statisticService?.gameCount else { return }
            guard let record = statisticService?.bestGame else { return }
            guard let totalAccuracy = statisticService?.totalAccuracy else { return }

            let title = "Этот раунд окончен!"
            let text = """
                            Ваш результат: \(correctAnswers)/\(questionsAmount)
                            Количество сыгранных квизов: \(gameCount)
                            Рекорд: \(record.correct)/\(record.total) (\(format(date: record.date)))
                            Средняя точность: \(String(format: "%.2f", totalAccuracy / Double(gameCount)))%
                            """
            let buttonText = "Сыграть еще раз"

            let resultVM = QuizResultsViewModel(title, text, buttonText)

            resultAlertPresender?.show(quiz: resultVM) { [weak self] in
                self?.currentQuestionIndex = 0
                self?.correctAnswers = 0
                self?.questionFactory?.requestNextQuestion()
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.questionFactory?.requestNextQuestion()
            }
        }
    }

    private func updateImageLayer() {
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor(named: "white")?.cgColor
    }

    private func enableButtonIteraction() {
        for button in answerButtons {
            button.isUserInteractionEnabled = true
        }
    }

    private func disableUserIteraction() {
        for button in answerButtons {
            button.isUserInteractionEnabled = false
        }
    }

    private func format(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy' 'HH:mm"
        let currentDate = dateFormatter.string(from: date)
        return currentDate
    }

    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    private func showNetworkError(message: String) {
        activityIndicator.isHidden = true
        let allert = UIAlertController(title: "Что-то пошло не так(", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Попробовать еще раз", style: .default) { _ in
            DispatchQueue.main.async { [weak self] in
                self?.questionFactory?.requestNextQuestion()
            }
        }
        allert.addAction(action)
        present(allert, animated: true, completion: nil)
    }
}
