//
//  SportsViewController.swift
//  CatalogueiOS
//
//  Created by Stanislav Dimitrov on 30.03.24.
//

import UIKit
import CatalogueCore

public final class SportsViewController: UITableViewController {

  private var loader: SportsLoader?

  public convenience init(loader: SportsLoader) {
    self.init()
    self.loader = loader
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    Task {
      let _ = await loader?.load()
    }
  }
}
