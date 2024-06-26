//
//  Sport.swift
//  CatalogueCore
//
//  Created by Stanislav Dimitrov on 27.03.24.
//

import Foundation

public struct Sport: Equatable {
  public let id: Int
  public let name: String

  public init(id: Int, name: String) {
    self.id = id
    self.name = name
  }
}
