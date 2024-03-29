//
//  HTTPClient.swift
//  CatalogueCore
//
//  Created by Stanislav Dimitrov on 29.03.24.
//

import Foundation

public typealias HTTPClientResult = Result<(Data, HTTPURLResponse), Error>

public protocol HTTPClient {
  func perform(request: URLRequest) async -> HTTPClientResult
}
