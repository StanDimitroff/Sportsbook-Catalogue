//
//  RemoteSportsLoader.swift
//  CatalogueCore
//
//  Created by Stanislav Dimitrov on 29.03.24.
//

import Foundation

public typealias LoadSportsResult = Result<[Sport], Error>

public final class RemoteSportsLoader {
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

  public func load() async -> LoadSportsResult {
    let result = await client.perform(request: request)

    switch result {
    case let .success((data, response)):
      do {
        let sports = try SportsMapper.map(data, from: response)
        return .success(sports.toModels())
      } catch {
        return .failure(error)
      }
    case .failure:
      return .failure(Error.noConnection)
    }
  }
}

private extension Array where Element == RemoteSport {
  func toModels() -> [Sport] {
    map { Sport(id: $0.id, name: $0.name) }
  }
}
