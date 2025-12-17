//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Екатерина Барданова on 11. 12. 2025..
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol  {
    
    weak var delegate: QuestionFactoryDelegate?
    
    private let questions = QuizQuestion.mockQuestions
    
    func requestNextQuestion() {
        guard let index = (0..<questions.count).randomElement(),
        let question = questions[safe: index] else {
            delegate?.didReceiveNextQuestion(question: nil)
                    return
        }
            delegate?.didReceiveNextQuestion(question: question)
        } 
}
