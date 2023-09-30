//
//  CustomInfoWindow.swift
//  Seraphic_Demo
//
//  Created by Paritosh on 30/09/23.
//

import UIKit

class CustomInfoWindow: UIView {
    var driverName : UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    private func setupUI() {
        // Create and configure the label
        driverName = UILabel()
        driverName.textColor = UIColor.black
        driverName.textAlignment = .center
        addSubview(driverName)

        // Add constraints to position the label within the view
        driverName.translatesAutoresizingMaskIntoConstraints = false
        driverName.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        driverName.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        driverName.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        driverName.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
    }

    func configure(withName name: String) {
        driverName.text = name
    }

}
