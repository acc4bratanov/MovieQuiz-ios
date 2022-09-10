import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    private let delegate: QuestionFactoryDelegate
    private let moviesLoader: MoviesLoadingProtocol
    private var movies: [MostPopularMovie] = []

    init(moviesLoader: MoviesLoadingProtocol, delegate: QuestionFactoryDelegate) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }

    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0

            guard let movie = self.movies[safe: index] else { return }

            var imageData = Data()

            do {
                imageData = try Data(contentsOf: movie.imageURL)
            } catch {
                print("Failed to load image")
            }

            let rating = Float(movie.rating) ?? 0

            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7

            let question = QuizQuestion(image: imageData, question: text, correctAnswer: correctAnswer)

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate.didReceiveNextQuestion(question)
            }
        }
    }

    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let mostPopularMovies):
                self.movies = mostPopularMovies.items
                self.delegate.didLoadDataFromServer()
            case .failure(let error):
                self.delegate.didFailToLoadData(with: error)
            }
        }
    }
}
