import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    private var currentQuestionIndex: Int = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?
    
    private var correctAnswer: Int = 0
    private var counterQuiz: Int = 0
    
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
        alertPresenter = AlertPresenter(delegate: self)
        statisticService = StatisticServiceImplementation()
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
    // MARK: - AlertPresenterDelegate
    
    func present(alert: UIAlertController) {
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - private functions
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        imageView.layer.borderWidth = 0
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    /*
     private func show(quiz result: QuizResultsViewModel) {
     
     statisticService.store(correct count: correctAnswer, total amount: questionsAmount)
     let text = "Ваш результат: \(correctAnswer) из 10 \n Количество сыгранных квизов: \(counterQuiz) \n Рекорд:\(recordQuiz) (\(dateRecord ?? dateNow)) \n Средняя точность \(accuracy)%"
     
     let viewModel = AlertModel(
     title: "Этот раунд окончен",
     massage: text,
     buttonText: "Сыграть еще раз",
     completion: {self.currentQuestionIndex = 0
     self.correctAnswer = 0
     self.questionFactory?.requestNextQuestion()})
     alertPresenter?.showAlert(alertModel: viewModel)
     
     let alert = UIAlertController(title: result.title, message: result.text, preferredStyle: .alert)
     let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
     guard let self = self else {return}
     self.currentQuestionIndex = 0
     self.correctAnswer = 0
     self.questionFactory?.requestNextQuestion()
     }
     
     alert.addAction(action)
     self.present(alert: alert)
     }
     */
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return  QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswer += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        noButton.isEnabled = false
        yesButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            [weak self] in
            guard let self = self else {return}
            self.showNextQuestionOrResult()
        }
    }
    
    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questionsAmount - 1 {
            self.showFinalResults()
        } else {
            currentQuestionIndex+=1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showFinalResults() {
        guard let statisticService = statisticService else {
            return assertionFailure("error message")
        }
        guard let bestGame = statisticService.bestGame else {
            return assertionFailure("error message")
        }
        statisticService.store(correct: correctAnswer, total: questionsAmount)
        let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
        let text = "Ваш результат: \(correctAnswer) из \(questionsAmount) \n Количество сыгранных квизов: \(statisticService.gamesCount) \n Рекорд:\(bestGame.correct)/\(questionsAmount) (\(bestGame.date.dateTimeString)) \n Средняя точность \(accuracy)%"
        
        let viewModel = AlertModel(
            title: "Этот раунд окончен",
            massage: text,
            buttonText: "Сыграть еще раз",
            completion: {self.currentQuestionIndex = 0
                self.correctAnswer = 0
                self.questionFactory?.requestNextQuestion()})
        alertPresenter?.showAlert(alertModel: viewModel)
    }
    
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
