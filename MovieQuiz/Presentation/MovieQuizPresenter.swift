//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Dolnik Nikolay on 25.04.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private var statisticService: StatisticServiceProtocol!
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
   
    var currentQuestion: QuizQuestion?
    private var currentQuestionIndex: Int = 0
    let questionsAmount: Int = 10
    var correctAnswer: Int = 0
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        self.statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
   
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswer = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswer += 1
        }
    }
    
    
     func convert(model: QuizQuestion) -> QuizStepViewModel {
        return  QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            [weak self] in
            guard let self = self else {return}
            self.proceedToNextQuestionOrResult()
        }
    }
    
   private func proceedToNextQuestionOrResult() {
        if self.isLastQuestion() {
            let text = correctAnswer == self.questionsAmount ?
                        "Поздравляем, вы ответили на 10 из 10!" :
                        "Вы ответили на \(correctAnswer) из 10, попробуйте ещё раз!"

                        let viewModel = QuizResultsViewModel(
                            title: "Этот раунд окончен!",
                            text: text,
                            buttonText: "Сыграть ещё раз")
                            viewController?.show(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswer, total: questionsAmount)

        guard let bestGame = statisticService.bestGame else {
            return "error message"
        }
            let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
            let currentGameResultLine = "Ваш результат: \(correctAnswer)\\\(questionsAmount)"
            let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
        + " (\(bestGame.date.dateTimeString))"
            let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"

            let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
            ].joined(separator: "\n")
            return resultMessage
        }
    
    private func showFinalResults() {
        guard let statisticService = statisticService else {
            return assertionFailure("error message")
        }
        statisticService.store(correct: correctAnswer, total: questionsAmount)
        // очистил данные лучшей игры statisticService.cleanUserDefaults()
        guard let bestGame = statisticService.bestGame else {
            return assertionFailure("error message")
        }
        let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
        let text = """
            Ваш результат: \(correctAnswer)/\(questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд:\(bestGame.correct)/\(questionsAmount) (\(bestGame.date.dateTimeString))
            Средняя точность \(accuracy)%
        """
        
        let viewModel = AlertModel(
            title: "Этот раунд окончен!",
            massage: text,
            buttonText: "Сыграть еще раз",
            completion: {
                self.restartGame()})
        //viewController?.alertPresenter?.showAlert(alertModel: viewModel)
    }
    
}


