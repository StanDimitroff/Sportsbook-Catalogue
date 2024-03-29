//
//  LoadSportsUseCaseTests.swift
//  LoadSportsUseCaseTests
//
//  Created by Stanislav Dimitrov on 27.03.24.
//

import XCTest
import CatalogueCore

final class LoadSportsUseCaseTests: XCTestCase {

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
      XCTAssertEqual(receivedError as! RemoteSportsLoader.Error, RemoteSportsLoader.Error.noConnection)

    default:
      XCTFail("Expected failure, got \(result) instead")
    }
  }

  func test_load_deliversErrorOnNon200HTTPResponse() async {
    let (sut, client) = makeSUT()

    let samples = [199, 201, 300, 400, 500]

    samples.enumerated().forEach { index, code in
      client.stub(result: (statusCode: code, data: Data()), error: nil)

      Task { [sut] in
        let result = await sut.load()

        switch result {
        case let .failure(receivedError):
          XCTAssertEqual(receivedError as! RemoteSportsLoader.Error, RemoteSportsLoader.Error.invalidData)

        default:
          XCTFail("Expected failure, got \(result) instead")
        }
      }
    }
  }

  func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() async {
    let (sut, client) = makeSUT()

    let invalidJSONData = Data("invalid json".utf8)

    client.stub(result: (statusCode: 200, data: invalidJSONData), error: nil)

    let result = await sut.load()

    switch result {
    case let .failure(receivedError):
      XCTAssertEqual(receivedError as! RemoteSportsLoader.Error, RemoteSportsLoader.Error.invalidData)

    default:
      XCTFail("Expected failure, got \(result) instead")
    }
  }

  // MARK: - Happy path

  func test_load_deliversNoSportsOn200HTTPResponseWithEmptyJSONList() async {
    let (sut, client) = makeSUT()

    let emptyListJSONData = Data("{\"data\": []}".utf8)

    client.stub(result: (statusCode: 200, data: emptyListJSONData), error: nil)

    let result = await sut.load()

    switch result {
    case let .success(receivedItems):
      XCTAssertEqual(receivedItems, [])

    default:
      XCTFail("Expected success, got \(result) instead")
    }
  }

  func test_load_deliversSportsOn200HTTPResponseWithJSONItems() async {
    let (sut, client) = makeSUT()

    let item1 = Sport(id: 1, name: "a name")
    let item2 = Sport(id: 2, name: "another name")

    let itemsJSONData = Data("{\"data\": [{\"id\": 1, \"name\": \"a name\"}, {\"id\": 2, \"name\": \"another name\"}]}".utf8)

    client.stub(result: (statusCode: 200, data: itemsJSONData), error: nil)

    let result = await sut.load()

    switch result {
    case let .success(receivedItems):
      XCTAssertEqual(receivedItems, [item1, item2])

    default:
      XCTFail("Expected success, got \(result) instead")
    }
  }

  // MARK: - Helpers

  private func makeSUT(
    request: URLRequest = .init(url: URL(string: "https://a-url.com")!),
    file: StaticString = #filePath,
    line: UInt = #line
  ) -> (sut: RemoteSportsLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteSportsLoader(request: request, client: client)

    return (sut: sut, client: client)
  }

  private class HTTPClientSpy: HTTPClient {

    struct Stub {
      let result: (statusCode: Int, data: Data)?
      let error: Error?
    }

    private(set) var sentRequests = [URLRequest]()
    private(set) var stub: Stub?

    private let queue = DispatchQueue(label: "HTTPClientSpyQueue")

    func stub(result: (statusCode: Int, data: Data)?, error: Error?) {
      stub = Stub(result: result, error: error)
    }

    func perform(request: URLRequest) async -> HTTPClientResult {
      queue.sync {
        sentRequests.append(request)
      }

      if let error = stub?.error {
        return .failure(error)
      }

      if let result = stub?.result {
        let response = HTTPURLResponse(
          url: request.url!,
          statusCode: result.statusCode,
          httpVersion: nil,
          headerFields: nil
        )!
        return .success((result.data, response))
      }

      return .failure(NSError(domain: "Empty error", code: 0))
    }
  }
}
