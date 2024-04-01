//
//  SportEventCell.swift
//  CatalogueiOS
//
//  Created by Stanislav Dimitrov on 31.03.24.
//

import UIKit

public final class SportEventCell: UITableViewCell {

  @IBOutlet public var marketLabel: UILabel!
  @IBOutlet public var matchLabel: UILabel!

  @IBOutlet public var homeNumeratorLabel: UILabel!
  @IBOutlet public var homeDenominatorLabel: UILabel!

  @IBOutlet public var drawNumeratorLabel: UILabel!
  @IBOutlet public var drawDenominatorLabel: UILabel!

  @IBOutlet public var awayNumeratorLabel: UILabel!
  @IBOutlet public var awayDenominatorLabel: UILabel!
}
