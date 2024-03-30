//
//  SportsLoader.swift
//  CatalogueCore
//
//  Created by Stanislav Dimitrov on 30.03.24.
//

import Foundation

public protocol SportsLoader {

  func load() async -> LoadSportsResult
}
