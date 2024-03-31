//
//  SceneDelegate.swift
//  SportsbookApp
//
//  Created by Stanislav Dimitrov on 31.03.24.
//

import UIKit
import CatalogueCore
import CatalogueiOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    guard let _ = (scene as? UIWindowScene) else { return }

    var urlRequest = URLRequest(url: URL(string: "http://localhost:8080/sports")!)
    urlRequest.setValue("Bearer ewogICAibmFtZSI6ICJHdWVzdCIKfQ==", forHTTPHeaderField: "Authorization")
    let client = URLSessionClient(session: URLSession(configuration: .ephemeral))
    let loader = RemoteSportsLoader(request: urlRequest, client: client)

    let bundle = Bundle(for: SportsViewController.self)
    let storyboard = UIStoryboard(name: "Catalogue", bundle: bundle)
    let sportsViewController = storyboard.instantiateViewController(
      identifier: String.init(describing: SportsViewController.self)
    ) { coder in
      return SportsViewController(coder: coder, loader: loader)
    }

    let navigationController = UINavigationController(rootViewController: sportsViewController)

    window?.rootViewController = navigationController
  }
}
