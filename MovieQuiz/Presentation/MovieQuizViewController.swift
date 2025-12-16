import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private let statisticService: StatisticServiceProtocol = StatisticService()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "(dd.MM.yy HH:mm)"
        return formatter
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        alertPresenter = AlertPresenter(screen: self)
        
        yesButton.layer.cornerRadius = 15
        yesButton.clipsToBounds = true
        
        noButton.layer.cornerRadius = 15
        noButton.clipsToBounds = true
        
        questionFactory.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        setButtonsEnabled(false)
        guard let currentQuestion = currentQuestion else {
            return
        }
        let correctAnswer = currentQuestion.correctAnswer
        let userAnswer = false
        let isCorrectAnswer = userAnswer == correctAnswer
        showAnswerResult(isCorrect: isCorrectAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        setButtonsEnabled(false)
        guard let currentQuestion = currentQuestion else {
            return
        }
        let correctAnswer = currentQuestion.correctAnswer
        let userAnswer = true
        let isCorrectAnswer = userAnswer == correctAnswer
        showAnswerResult(isCorrect: isCorrectAnswer)
    }
    
    // MARK: - Private functions
    
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
        
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.cornerRadius = 20
        setButtonsEnabled(true)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        
        if isCorrect == true {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers += 1
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText)
        { [weak self] in
        guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter?.showAlert(model: alertModel)
    }
        
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let viewModel = QuizResultsViewModel(
                title: Constants.roundFinished,
                text: "\(Constants.resultText) \(correctAnswers)/\(Constants.totalQuestions)\n \(Constants.totalText) \(statisticService.gamesCount)\n \(Constants.recordText) \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) \(dateFormatter.string(from: statisticService.bestGame.date))\n \(Constants.accuracyText) \(String(format: "%.2f", statisticService.totalAccuracy))%",
                buttonText: Constants.playAgain)
            
            show(quiz: viewModel)
            
        } else {
            currentQuestionIndex += 1
            
            questionFactory?.requestNextQuestion()
        }
    }
            
    private func setButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }

        
    private enum Constants {
        static let roundFinished = "Раунд окончен!"
        static let resultText = "Ваш результат: "
        static let totalText = "Количество сыгранных квизов: "
        static let recordText = "Рекорд: "
        static let accuracyText = "Средняя точность: "
        static let playAgain = "Сыграть еще раз"
        static let totalQuestions = 10
    }
}

