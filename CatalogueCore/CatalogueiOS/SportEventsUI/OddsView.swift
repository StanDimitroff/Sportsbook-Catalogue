//
//  OddsView.swift
//  CatalogueiOS
//
//  Created by Stanislav Dimitrov on 1.04.24.
//

import UIKit

final class OddsView: UIView {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var numeratorLabel: UILabel!
  @IBOutlet weak var denominatorLabel: UILabel!

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  private func setup() {
    let nib = UINib(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
    guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }

    view.frame = bounds

    addSubview(view)
  }
}
