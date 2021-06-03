//
//  FilterCollectionViewCell.swift
//  PanoMaker
//
//  Created by 薛忱 on 2021/1/26.
//  Copyright © 2021 薛忱. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    
    let cellImageView = UIImageView()
    let cellLabel = UILabel()
    let selectView = UIView()
    let selectColor = UIColor.color(hexString: "#000000")
    let nomalColor = UIColor.clear
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = .white
        
        cellImageView.layer.cornerRadius = 25
        cellImageView.layer.masksToBounds = true
        cellImageView.contentMode = .scaleAspectFit
        self.contentView.addSubview(cellImageView)
        cellImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(50)
            make.center.equalTo(self.contentView)
        }
        
        selectView.backgroundColor = nomalColor
        self.cellImageView.addSubview(selectView)
        selectView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(0)
            make.height.equalTo(18)
        }
        
        cellLabel.textAlignment = .center
        cellLabel.textColor = .white
        cellLabel.font = UIFont(name: "Avenir-Black", size: 12)
        selectView.addSubview(cellLabel)
        cellLabel.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
