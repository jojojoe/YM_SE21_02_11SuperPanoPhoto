//
//  PhotoAlbumCollectionViewCell.swift
//  BlukEdit
//
//  Created by 薛忱 on 2019/8/26.
//  Copyright © 2019 薛忱. All rights reserved.
//

import UIKit

class PhotoAlbumCollectionViewCell: UICollectionViewCell {
    
    var reqressentedAssetIdentifier: String = ""
    let mainImage = UIImageView()
    let selectView = UIImageView()
    var selectBgView = UIView()
    let cellMaskView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.layer.masksToBounds = true
        
        _ = mainImage.then({ (imageView) in
            imageView.contentMode = .scaleAspectFill
            self.contentView.addSubview(imageView)
            imageView.snp.makeConstraints {
                $0.left.right.top.bottom.equalToSuperview()
            }
             
        })
        
        self.selectBgView = UIView().then({ (v) in
            
            v.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            v.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
            v.layer.borderWidth = 1
            v.layer.cornerRadius  = 10
            v.layer.masksToBounds = true
            self.contentView.addSubview(v)
            v.snp.makeConstraints {
                $0.width.height.equalTo(20)
                $0.bottom.equalTo(-6)
                $0.right.equalTo(-6)
            }
             
        })
        
        _ = selectView.then({ (select) in
            select.image = UIImage(named: "photo_select")
            select.contentMode = .scaleAspectFit
            select.isHidden = true
            self.contentView.addSubview(select)
            select.snp.makeConstraints {
                $0.width.height.equalTo(20)
                $0.bottom.equalTo(-6)
                $0.right.equalTo(-6)
            }
             
        })
        
        _ = cellMaskView.then({ (v) in
            v.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            v.isHidden = true
            self.contentView.addSubview(v)
            v.snp.makeConstraints {
                $0.left.right.top.bottom.equalToSuperview()
            }
            
        })
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
