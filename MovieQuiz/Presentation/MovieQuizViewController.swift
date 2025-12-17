import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    // MARK: - State
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers = 0
    private var currentQuestion: QuizQuestion?
    
    // MARK: - Dependencies
    
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenter?
    private let statisticService: StatisticServiceProtocol = StatisticService()
    
    // MARK: - Helpers
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "(dd.MM.yy HH:mm)"
        return formatter
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDependencies()
        setupUI()
        requestFirstQuestion()
    }
    
    private func setupDependencies() {
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        alertPresenter = AlertPresenter(screen: self)
    }
    
    private func setupUI() {
        yesButton.layer.cornerRadius = 15
        noButton.layer.cornerRadius = 15
    }

    
    private func requestFirstQuestion() {
        questionFactory?.requestNextQuestion()
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
        handleAnswer(false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        handleAnswer(true)
    }
    
    // MARK: - Private functions
    
    private func handleAnswer (_ userAnswer: Bool) {
        setButtonsEnabled(false)
        guard let currentQuestion = currentQuestion else {
            return
        }
        let isCorrectAnswer = userAnswer == currentQuestion.correctAnswer
        showAnswerResult(isCorrect: isCorrectAnswer)
    }
    
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
            questionNumber: "\(currentQuestionIndex + 1)/\(Constants.totalQuestions)")
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
        if currentQuestionIndex == Constants.totalQuestions - 1 {
            showResult()
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showResult() {
        statisticService.store(correct: correctAnswers, total: Constants.totalQuestions)
        
        let viewModel = QuizResultsViewModel(
            title: Constants.roundFinished,
            text: makeResultText(),
            buttonText: Constants.playAgain)
        
        show(quiz: viewModel)
    }
    
    private func makeResultText() -> String {
        """
        \(Constants.resultText) \(correctAnswers)/\(Constants.totalQuestions)\n \(Constants.totalText) \(statisticService.gamesCount)\n \(Constants.recordText) \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) \(dateFormatter.string(from: statisticService.bestGame.date))\n \(Constants.accuracyText) \(String(format: "%.2f", statisticService.totalAccuracy))%
        """
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
