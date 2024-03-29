//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Dolnik Nikolay on 11.04.2023.
//

import Foundation

protocol StatisticServiceProtocol {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord? { get }
    
    func store(correct count: Int, total amount: Int)
    func cleanUserDefaults ()
}


final class StatisticServiceImplementation: StatisticServiceProtocol {
   
    private let userDefaults: UserDefaults
    private let dateProvider: () -> Date
   
    init(userDefaults: UserDefaults = .standard, dateProvider: @escaping () -> Date = { Date() } ) {
        self.userDefaults = userDefaults
        self.dateProvider = dateProvider
    }

    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    var bestGame: GameRecord? {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
            let bestGame = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return bestGame
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
               return print("Невозможно сохранить результат")
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        guard total != 0 else{
            return 0
        }
        return Double(correct) / Double(total) * 100
    }
   
    var total: Int {
        get {
            userDefaults.integer(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    var correct: Int {
        get {
            userDefaults.integer(forKey: Keys.correct.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    
    func store(correct: Int, total: Int) {
        self.correct += correct
        self.total += total
        self.gamesCount += 1
        
        let date = dateProvider()
        let currentBestGame = GameRecord (correct: correct, total: total, date: date)
        
        if let previousBestGame = bestGame {
             if currentBestGame > previousBestGame {
                bestGame = currentBestGame
            }} else {
                bestGame = currentBestGame
            }
    }
    
    func cleanUserDefaults () {
        let date = dateProvider()
        let zeroGame = GameRecord(correct: 0, total: 0, date: date)
        bestGame = zeroGame
    }
}
