//
//  ShowDriverCollectionViewCell.swift
//  Seraphic_Demo
//
//  Created by Paritosh on 29/09/23.
//

import UIKit

class ShowDriverCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var DistanceTimeView: UIView!
    
    
    @IBOutlet weak var DetailsView: UIView!
    
    
    @IBOutlet weak var distanceLbl: UILabel!
    
    
    @IBOutlet weak var carimageView: UIImageView!
    
    
    @IBOutlet weak var driverName: UILabel!
    
    
    @IBOutlet weak var driverLocation: UILabel!
    
    
    @IBOutlet weak var driverEta: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureUI()
        // Initialization code
    }

    
    func configureUI(){
        self.carimageView.layer.cornerRadius = 5.0
        self.DistanceTimeView.addShadow(color: UIColor.gray, opacity: 0.5, offset: CGSize(width: 0, height: 2), radius: 4.0)
        self.DistanceTimeView.backgroundColor = .white
        self.DistanceTimeView.layer.cornerRadius = 17.0
        self.DetailsView.backgroundColor = .white
        self.DetailsView.layer.cornerRadius = 8.0
        self.driverName.font = UIFont.systemFont(ofSize: 14)
        self.driverLocation.font = UIFont.systemFont(ofSize: 13)
        self.driverLocation.textColor = UIColor.lightGray
        self.driverEta.font = UIFont.systemFont(ofSize: 13)
        self.driverEta.textColor = UIColor.lightGray
    }
}
