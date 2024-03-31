//
//  SportsEventsLoader.swift
//  CatalogueCore
//
//  Created by Stanislav Dimitrov on 31.03.24.
//

import Foundation

public protocol SportEventsLoader {

  func load() async -> LoadSportEventsResult
}
