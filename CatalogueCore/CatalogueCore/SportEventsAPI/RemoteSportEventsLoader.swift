//
//  RemoteSportEventsLoader.swift
//  CatalogueCore
//
//  Created by Stanislav Dimitrov on 31.03.24.
//

import Foundation

public typealias LoadSportEventsResult = Result<[SportEvent], Error>

public final class RemoteSportEventsLoader: SportEventsLoader {
  private let request: URLRequest
  private let client: HTTPClient

  public enum Error: Swift.Error {
    case noConnection
    case invalidData
  }

  public init(request: URLRequest, client: HTTPClient) {
    self.request = request
    self.client = client
  }

  public func load() async -> LoadSportEventsResult {
    let result = await client.perform(request: request)

    switch result {
    case let .success((data, response)):
      do {
        let sports = try SportEventsMapper.map(data, from: response)
        return .success(sports.toModels())
      } catch {
        return .failure(error)
      }
    case .failure:
      return .failure(Error.noConnection)
    }
  }
}

private extension Array where Element == RemoteSportEvent {
  func toModels() -> [SportEvent] {
    let dateTransformer: (String) -> Date = {
      let formatter = ISO8601DateFormatter()
      let date = formatter.date(from: $0) ?? Date.init()

        let cal: Calendar = Calendar.current
      let comp: DateComponents = cal.dateComponents([.day, .month, .year], from: date)

      return cal.date(from: comp) ?? Date.init()
    }

    return map {
      SportEvent(
        name: $0.name,
        date: dateTransformer($0.date),
        primaryMarket: $0.primaryMarket.toModel()
      )
    }
  }
}

private extension RemotePrimaryMarket {
  func toModel() -> PrimaryMarket {
    PrimaryMarket(
      name: self.name,
      type: PrimaryMarket.MarketType(rawValue: self.type)!,
      runners: self.runners.toModels()
    )
  }
}

private extension Array where Element == RemoteRunner {
  func toModels() -> [Runner] {
    map {
      Runner(
        marketType: PrimaryMarket.MarketType(rawValue: $0.marketType)!,
        name: $0.name,
        totalGoals: $0.totalGoals,
        odds: $0.odds.toModel()
      )
    }
  }
}

private extension RemoteOdds {
  func toModel() -> Odds {
    Odds(numerator: self.numerator, denominator: self.denominator)
  }
}
