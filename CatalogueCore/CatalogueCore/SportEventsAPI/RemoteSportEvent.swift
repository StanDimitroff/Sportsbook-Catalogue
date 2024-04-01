//
//  RemoteSportEvent.swift
//  CatalogueCore
//
//  Created by Stanislav Dimitrov on 31.03.24.
//

import Foundation

struct RemoteSportEvent: Decodable {
  let name: String
  let date: String
  let primaryMarket: RemotePrimaryMarket
}

struct RemotePrimaryMarket: Decodable {
  let name: String
  let type: String
  let runners: [RemoteRunner]
}

struct RemoteRunner: Decodable {
  let marketType: String
  let name: String?
  let totalGoals: Int?
  let odds: RemoteOdds
}

struct RemoteOdds: Decodable {
  let numerator: Int
  let denominator: Int
}
