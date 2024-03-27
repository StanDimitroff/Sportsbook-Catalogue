//
//  CatalogueCoreTests.swift
//  CatalogueCoreTests
//
//  Created by Stanislav Dimitrov on 27.03.24.
//

import XCTest
import CatalogueCore

protocol HTTPClient {
  func get(from url: URL)
}

final class RemoteSportLoader {
  private let client: HTTPClient

  public init(client: HTTPClient) {
    self.client = client
  }

  public func load() {
    client.get(from: URL(string: "https://catalogue.core")!)
  }
}

final class CatalogueCoreTests: XCTestCase {

  func test_init_doesNotLoadDataFromURL() {
    let client = HTTPClientSpy()
    let sut = RemoteSportLoader(client: client)

    XCTAssertEqual(client.requestedURL, nil)
  }

  func test_load_requestsDataFromURL() {
    let client = HTTPClientSpy()
    let sut = RemoteSportLoader(client: client)

    sut.load()

    XCTAssertNotNil(client.requestedURL)
  }

  private class HTTPClientSpy: HTTPClient {
    private(set) var requestedURL: URL?

    func get(from url: URL) {
      requestedURL = url
    }
  }
}
