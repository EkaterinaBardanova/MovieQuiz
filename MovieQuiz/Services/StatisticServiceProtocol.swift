//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Екатерина Барданова on 15. 12. 2025..
//

import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ another: GameResult) -> Bool {
            correct > another.correct
        }
}

protocol StatisticServiceProtocol {
    var gamesCount: Int { get set }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store (correct count: Int, total amount: Int) 
}
