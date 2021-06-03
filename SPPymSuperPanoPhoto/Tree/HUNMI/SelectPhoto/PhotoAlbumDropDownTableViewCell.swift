//
//  PhotoAlbumDropDownTableViewCell.swift
//  BlukEdit
//
//  Created by 薛忱 on 2019/8/26.
//  Copyright © 2019 薛忱. All rights reserved.
//

import UIKit

class PhotoAlbumDropDownTableViewCell: UITableViewCell {

    var cellTitle: UILabel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.cellTitle = UILabel().then({ (label) in
            label.textAlignment = .center
            label.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
            self.contentView.addSubview(label)
            label.snp.makeConstraints {
                $0.top.bottom.equalToSuperview()
                $0.centerX.equalTo(self.contentView)
            }
             
        })
        
        _ = UIView().then({ (v) in
            
            v.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            self.contentView.addSubview(v)
            v.snp.makeConstraints {
                $0.left.right.bottom.equalToSuperview()
                $0.height.equalTo(1)
            }
             
        })
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
