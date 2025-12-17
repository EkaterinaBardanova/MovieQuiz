//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Екатерина Барданова on 12. 12. 2025..
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)   
}
