//
//  CompassView.swift
//  QiblaPlus
//
//  Created by Abdulelah Hajjar on 21/05/2020.
//  Copyright © 2020 Abdulelah Hajjar. All rights reserved.
//

import UIKit

@IBDesignable
class CompassView: UIView {
	let nibName = "CompassView"
	var contentView : UIView?
	@IBOutlet weak var base: UIView!
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	func commonInit() {
		guard let view = loadViewFromNib() else { return }
		view.frame = self.bounds
		self.addSubview(view)
		contentView = view
		createBase()
	}
	
	func createBase() {
		base.layer.cornerRadius = base.frame.height / 2
		base.layer.borderColor = UIColor.black.cgColor
		base.layer.borderWidth = 5.0
	}
	
	func loadViewFromNib() -> UIView? {
		let bundle = Bundle(for: type(of: self))
		let nib = UINib(nibName: nibName, bundle: bundle)
		return nib.instantiate(withOwner: self, options: nil).first as? UIView
	}
}
