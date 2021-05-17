//
//  SSPMultiSlideTempBar.swift
//  SPPymSuperPanoPhoto
//
//  Created by JOJO on 2021/5/13.
//

import UIKit

class SSPMultiSlideTempBar: UIView {
    var collection: UICollectionView!
    var mobanList: [String] = []
    var clickTempItemBlock: ((String,Bool)->Void)?
    
    
    init(frame: CGRect, mobanList: [String]) {
        self.mobanList = mobanList
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}

extension SSPMultiSlideTempBar {
    func setupView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collection = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.backgroundColor = .clear
        collection.delegate = self
        collection.dataSource = self
        addSubview(collection)
        collection.snp.makeConstraints {
            $0.top.bottom.right.left.equalToSuperview()
        }
        collection.register(cellWithClass: SSPMultiSlideTempBarCell.self)
    }
    
    
}

extension SSPMultiSlideTempBar: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: SSPMultiSlideTempBarCell.self, for: indexPath)
        let item = mobanList[indexPath.item]
        let thumbName = "t_\(item)"
        cell.contentImgV.image = UIImage(named: thumbName)
        if indexPath.item >= 2 {
            cell.vipImgV.isHidden = false
        } else {
            cell.vipImgV.isHidden = true
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mobanList.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
}

extension SSPMultiSlideTempBar: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 61, height: 61)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
}

extension SSPMultiSlideTempBar: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = mobanList[indexPath.item]
        var isPro = false
        if indexPath.item >= 2 {
            isPro = true
        }
        clickTempItemBlock?(item, isPro)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
}



class SSPMultiSlideTempBarCell: UICollectionViewCell {
    let contentImgV = UIImageView()
    let vipImgV = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        contentImgV.contentMode = .scaleAspectFill
        contentImgV.clipsToBounds = true
        contentView.addSubview(contentImgV)
        contentImgV.snp.makeConstraints {
            $0.top.left.equalToSuperview().offset(10)
            $0.right.bottom.equalToSuperview().offset(-10)
        }
        //
        vipImgV.isHidden = true
        contentView.addSubview(vipImgV)
        vipImgV.image = UIImage(named: "pic_pro_ic")
        vipImgV.snp.makeConstraints {
            $0.top.right.equalToSuperview()
            $0.width.height.equalTo(52 / 2)
        }
    }
}
