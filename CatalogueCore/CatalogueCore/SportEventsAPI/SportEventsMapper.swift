//
//  SportEventsMapper.swift
//  CatalogueCore
//
//  Created by Stanislav Dimitrov on 31.03.24.
//

import Foundation

final class SportEventsMapper {
  private init() {}

  private struct RootSportEventsResponse: Decodable {
    let data: [RemoteSportEvent]
  }

  private static var OK_200: Int { 200 }

  static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteSportEvent] {
    guard response.statusCode == OK_200,
          let root = try? JSONDecoder().decode(RootSportEventsResponse.self, from: data) else {
      throw RemoteSportEventsLoader.Error.invalidData
    }
    return root.data
  }
}
