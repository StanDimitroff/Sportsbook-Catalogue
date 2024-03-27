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
  func perform(request: URLRequest) async -> HTTPClientResult
}

final class RemoteSportLoader {
  private let request: URLRequest
  private let client: HTTPClient

  public init(request: URLRequest, client: HTTPClient) {
    self.request = request
    self.client = client
  }

  public func load() async {
    let result = await client.perform(request: request)
  }
}

final class CatalogueCoreTests: XCTestCase {

  func test_init_doesNotLoadDataFromURL() {
    let client = HTTPClientSpy()
    let request = URLRequest(url: URL(string: "https://a-url.com")!)
    let sut = RemoteSportLoader(request: request, client: client)

    XCTAssertNil(client.sentRequest)
  }

  func test_load_requestsDataFromURL() async {
    let client = HTTPClientSpy()
    let request = URLRequest(url: URL(string: "https://a-url.com")!)
    let sut = RemoteSportLoader(request: request, client: client)

    await sut.load()

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
