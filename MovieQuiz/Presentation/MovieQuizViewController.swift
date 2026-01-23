import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - State
    
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Dependencies
    
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol!
    // MARK: - Helpers
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "(dd.MM.yy HH:mm)"
        return formatter
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let statisticService = StatisticService()
        self.statisticService = statisticService
        presenter = MovieQuizPresenter(viewController: self, statisticService: statisticService)
        setupDependencies()
        setupUI()
        showLoadingIndicator()
        
    }
    
    // MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    // MARK: - Private functions
    
    private func setupDependencies() {
        alertPresenter = AlertPresenter(screen: self)
    }
    
    private func setupUI() {
        yesButton.layer.cornerRadius = 15
        noButton.layer.cornerRadius = 15
        imageView.layer.cornerRadius = 20
    }
    
    private func makeResultText() -> String {
        """
        \(Constants.resultText) \(presenter.correctAnswers)/\(Constants.totalQuestions)\n \(Constants.totalText) \(statisticService.gamesCount)\n  a\(Constants.recordText) \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) \(dateFormatter.string(from: statisticService.bestGame.date))\n \(Constants.accuracyText) \(String(format: "%.2f", statisticService.totalAccuracy))%
        """
    }
    
    private func setButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    func show(quiz result: QuizResultsViewModel) {
        statisticService.store(correct: presenter.correctAnswer, total: presenter.questionsAmount)
        
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText)
        { [weak self] in
            guard let self = self else { return }
            self.presenter.restartGame()
            self.presenter.correctAnswers = 0
            self.presenter.restartGame()
        }
        alertPresenter?.showAlert(model: alertModel)
    }
    
    // MARK: - Internal functions
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: Constants.alertNetworkTitle,
            message: "",
            buttonText: Constants.alertNetworkButton) { [ weak self ] in
                guard let self else { return }
                self.presenter.restartGame()
                self.presenter.correctAnswers = 0
                self.presenter.restartGame()
            }
        alertPresenter?.showAlert(model: model)
    }
    
    func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = UIImage(data: step.image)
        textLabel.text = step.question
        
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.cornerRadius = 20
        setButtonsEnabled(true)
    }
    
    func showResult() {
        statisticService.store(correct: presenter.correctAnswers, total: Constants.totalQuestions)
        
        let viewModel = QuizResultsViewModel(
            title: Constants.roundFinished,
            text: makeResultText(),
            buttonText: Constants.playAgain)
        
        show(quiz: viewModel)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    private enum Constants {
        static let roundFinished = "Раунд окончен!"
        static let resultText = "Ваш результат: "
        static let totalText = "Количество сыгранных квизов: "
        static let recordText = "Рекорд: "
        static let accuracyText = "Средняя точность: "
        static let playAgain = "Сыграть еще раз"
        static let totalQuestions = 10
        static let alertNetworkButton = "Попробовать еще раз"
        static let alertNetworkTitle = "Ошибка сети"
    }
}
