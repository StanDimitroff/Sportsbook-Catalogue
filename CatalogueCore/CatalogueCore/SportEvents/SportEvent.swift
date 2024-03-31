//
//  SportEvent.swift
//  CatalogueCore
//
//  Created by Stanislav Dimitrov on 31.03.24.
//

import Foundation

public struct SportEvent: Equatable {
  public let name: String
  public let date: Date
  public let primaryMarket: PrimaryMarket


  public init(name: String, date: Date, primaryMarket: PrimaryMarket) {
    self.name = name
    self.date = date
    self.primaryMarket = primaryMarket
  }
}

public struct PrimaryMarket: Equatable {
  public enum MarketType {
    case winDrawWin
    case matchBetting
    case totalGoalsIntMatch
  }

  public let name: String
  public let type: MarketType
  public let runners: [Runner]

  public init(name: String, type: MarketType, runners: [Runner]) {
    self.name = name
    self.type = type
    self.runners = runners
  }
}

public struct Runner: Equatable {
  public let name: String
  public let totalGoals: Int?
  public let odds: [Odd]

  public init(name: String, totalGoals: Int?, odds: [Odd]) {
    self.name = name
    self.totalGoals = totalGoals
    self.odds = odds
  }
}

public struct Odd: Equatable {
  public let numerator: Int
  public let denominator: Int

  public init(numerator: Int, denominator: Int) {
    self.numerator = numerator
    self.denominator = denominator
  }
}
