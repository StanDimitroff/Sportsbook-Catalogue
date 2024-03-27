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
    let (sut, client) = makeSUT()

    XCTAssertEqual(client.sentRequests, [])
  }

  func test_load_requestsDataFromURL() async {
    let request = URLRequest(url: URL(string: "https://test-url.com")!)
    let (sut, client) = makeSUT(request: request)

    await sut.load()

    XCTAssertEqual(client.sentRequests, [request])
  }

  func test_loadTwice_requestDataFromURL() async {
    let request = URLRequest(url: URL(string: "https://test-url.com")!)
    let (sut, client) = makeSUT(request: request)

    let _ = await sut.load()
    let _ = await sut.load()

    XCTAssertEqual(client.sentRequests, [request, request])
  }

  private class HTTPClientSpy: HTTPClient {

    private(set) var sentRequests = [URLRequest]()

    func perform(request: URLRequest) -> HTTPClientResult {
      sentRequests.append(request)
      return .success((Data(), HTTPURLResponse()))
    }
  }

  // MARK: - Helpers

  private func makeSUT(
    request: URLRequest = .init(url: URL(string: "https://a-url.com")!),
    file: StaticString = #filePath,
    line: UInt = #line
  ) -> (sut: RemoteSportLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteSportLoader(request: request, client: client)

    return (sut: sut, client: client)
  }
}
