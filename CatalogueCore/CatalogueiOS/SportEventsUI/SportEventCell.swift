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

  @IBOutlet public var odsStackView: UIStackView!

  public override func prepareForReuse() {
    super.prepareForReuse()

    odsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
  }
}
