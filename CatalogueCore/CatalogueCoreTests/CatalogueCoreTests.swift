//
//  CatalogueCoreTests.swift
//  CatalogueCoreTests
//
//  Created by Stanislav Dimitrov on 27.03.24.
//

import XCTest
import CatalogueCore

public typealias HTTPClientResult = Result<(Data, HTTPURLResponse), Error>

protocol HTTPClient {
  func perform(request: URLRequest) -> HTTPClientResult
}

final class RemoteSportLoader {
  private let request: URLRequest
  private let client: HTTPClient

  public init(request: URLRequest, client: HTTPClient) {
    self.request = request
    self.client = client
  }

  public func load() {
    let result = client.perform(request: request)
  }
}

final class CatalogueCoreTests: XCTestCase {

  func test_init_doesNotLoadDataFromURL() {
    let client = HTTPClientSpy()
    let request = URLRequest(url: URL(string: "https://a-url.com")!)
    let sut = RemoteSportLoader(request: request, client: client)

    XCTAssertNil(client.sentRequest)
  }

  func test_load_requestsDataFromURL() {
    let client = HTTPClientSpy()
    let request = URLRequest(url: URL(string: "https://a-url.com")!)
    let sut = RemoteSportLoader(request: request, client: client)

    sut.load()

    XCTAssertNotNil(client.sentRequest)
  }

  private class HTTPClientSpy: HTTPClient {

    private(set) var sentRequest: URLRequest?

    func perform(request: URLRequest) -> HTTPClientResult {
      sentRequest = request
      return .success((Data(), HTTPURLResponse()))
    }
  }
}
