//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Екатерина Барданова on 15. 12. 2025..
//

import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    private enum Keys: String {
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case totalCorrectAnswers
        case totalQuestionsAsked
    }
    
    private let storage: UserDefaults = .standard
    var gamesCount: Int {
        get {
            return storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }

    }
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    private var totalCorrectAnswers: Int {
        get {
            return storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        set {
            storage.set(newValue,forKey: Keys.totalCorrectAnswers.rawValue)
        }
    }
    
    private var totalQuestionsAsked: Int {
        get {
            return storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)
        }
        set {
            storage.set( newValue, forKey: Keys.totalQuestionsAsked.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        if totalQuestionsAsked != 0 { return Double(totalCorrectAnswers) / Double(totalQuestionsAsked) * 100
        } else {
            return 0
        }
    }
    
    func store (correct count: Int, total amount: Int) {
        totalCorrectAnswers += count
        totalQuestionsAsked += amount
        gamesCount += 1
        
        if bestGame.correct < count {
            bestGame = GameResult(correct: count, total: amount, date: Date())
        }
    }
}
        

