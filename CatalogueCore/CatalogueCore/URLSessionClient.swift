//
//  URLSessionClient.swift
//  CatalogueCore
//
//  Created by Stanislav Dimitrov on 29.03.24.
//

import Foundation

public final class URLSessionClient: HTTPClient {
  private let session: URLSession

  public init(session: URLSession) {
    self.session = session
  }

  private struct UnexpectedDataRepresentation: Error { }

  public func perform(request: URLRequest) async -> HTTPClientResult {
    do {
      let data = try await session.data(for: request)
      if let response = data.1 as? HTTPURLResponse {
        return .success((data.0, response))
      }
      return .failure(UnexpectedDataRepresentation())
    } catch {
      return .failure(error)
    }
  }
}
