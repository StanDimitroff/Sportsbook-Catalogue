//
//  CatalogueCoreTests.swift
//  CatalogueCoreTests
//
//  Created by Stanislav Dimitrov on 27.03.24.
//

import XCTest
import CatalogueCore

public typealias HTTPClientResult = Result<(Data, HTTPURLResponse), Error>

public typealias LoadSportsResult = Result<[Sport], Error>

protocol HTTPClient {
  func perform(request: URLRequest) async -> HTTPClientResult
}

final class RemoteSportLoader {
  private let request: URLRequest
  private let client: HTTPClient

  public enum Error: Swift.Error {
    case noConnection
    case invalidData
  }

  public init(request: URLRequest, client: HTTPClient) {
    self.request = request
    self.client = client
  }

  public func load() async -> LoadSportsResult {
    _ = await client.perform(request: request)

    return .failure(Error.noConnection)
  }
}

final class CatalogueCoreTests: XCTestCase {

  func test_init_doesNotLoadDataFromURL() {
    let (_, client) = makeSUT()

    XCTAssertEqual(client.sentRequests, [])
  }

  func test_load_requestsDataFromURL() async {
    let request = URLRequest(url: URL(string: "https://test-url.com")!)
    let (sut, client) = makeSUT(request: request)

    let _ = await sut.load()

    XCTAssertEqual(client.sentRequests, [request])
  }

  func test_loadTwice_requestDataFromURL() async {
    let request = URLRequest(url: URL(string: "https://test-url.com")!)
    let (sut, client) = makeSUT(request: request)

    let _ = await sut.load()
    let _ = await sut.load()

    XCTAssertEqual(client.sentRequests, [request, request])
  }


  // MARK: - Sad path

  func test_load_deliversErrorOnHTTPClientError() async {
    let (sut, client) = makeSUT()

    client.stub(result: nil, error: NSError(domain: "HTTPClient", code: 0))

    let result = await sut.load()

    switch result {
    case let .failure(receivedError):
      XCTAssertEqual(receivedError as! RemoteSportLoader.Error, RemoteSportLoader.Error.noConnection)

    default:
      XCTFail("Expected failure, got \(result) instead")
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

  private class HTTPClientSpy: HTTPClient {

    struct Stub {
      let result: (statusCode: Int, data: Data)?
      let error: Error?
    }

    private(set) var sentRequests = [URLRequest]()
    private var stub: Stub?

    func stub(result: (statusCode: Int, data: Data)?, error: Error?) {
      stub = Stub(result: result, error: error)
    }

    func perform(request: URLRequest) -> HTTPClientResult {
      sentRequests.append(request)

      if let error = stub?.error {
        return .failure(error)
      }
      return .success((Data(), HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!))
    }
  }
}
