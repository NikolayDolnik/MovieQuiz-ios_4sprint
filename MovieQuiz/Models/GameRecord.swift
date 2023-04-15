//
//  BestGame.swift
//  MovieQuiz
//
//  Created by Dolnik Nikolay on 15.04.2023.
//

import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
  
    /* моя функция
    func bestResult (record: GameRecord ) -> GameRecord  {
        bestGame.correct > record.correct ?? return bestGame : return bestGame = record.correct
    }
   */
}

extension GameRecord: Comparable {
    private var accuracy: Double {
        guard total != 0 else {
            return 0
        }
        return Double(correct) / Double (total)
    }
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
      lhs.accuracy < rhs.accuracy
        
    }
}
