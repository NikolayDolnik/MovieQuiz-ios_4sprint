//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Dolnik Nikolay on 04.04.2023.
//

import Foundation
protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)    
}
