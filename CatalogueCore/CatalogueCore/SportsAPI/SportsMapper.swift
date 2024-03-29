//
//  SportsMapper.swift
//  CatalogueCore
//
//  Created by Stanislav Dimitrov on 29.03.24.
//

import Foundation

final class SportsMapper {
  private init() {}

  private struct RootSportResponse: Decodable {
    let data: [RemoteSport]
  }

  private static var OK_200: Int { 200 }

  static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteSport] {
    guard response.statusCode == OK_200,
          let root = try? JSONDecoder().decode(RootSportResponse.self, from: data) else {
      throw RemoteSportsLoader.Error.invalidData
    }
    return root.data
  }
}
