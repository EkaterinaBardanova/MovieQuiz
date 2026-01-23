import Foundation

final class QuestionFactory: QuestionFactoryProtocol  {
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    private var movies: [MostPopularMovie] = []
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData: Data
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didFailToLoadData(with: error)
                }
                return
            }
            guard let movieRating = Float(movie.rating) else {
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didFailToLoadData(
                        with: NSError(domain: "RatingConversion", code: 0)
                    )
                }
                return
            }
            
            let comparison = Bool.random() ? ">" : "<"
            let possibleRatings: [Float] = [5.0, 5.5, 6.0, 6.5, 7.0, 7.5, 8.0, 8.5, 9.0]
            let randomRating: Float = possibleRatings.randomElement() ?? 7.0
            let questionText = "Рейтинг этого фильма \(comparison == ">" ? "больше" : "меньше") чем \(randomRating)?"
            let correctAnswer = comparison == ">"
                ? movieRating > randomRating
                : movieRating < randomRating
        
            let question = QuizQuestion(image: imageData,
                                        text: questionText,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    func loadData() {
        print("loadData запустился")

        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                switch result {
                case .success(let MostPopularMovies):
                    self.movies = MostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
}

