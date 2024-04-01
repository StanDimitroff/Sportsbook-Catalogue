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
  var coordinator: MainCoordinator?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    guard let _ = (scene as? UIWindowScene) else { return }

    let navigationController = UINavigationController()
    coordinator = MainCoordinator(navigationController: navigationController)
    coordinator?.start()

    window?.rootViewController = navigationController
  }
}
