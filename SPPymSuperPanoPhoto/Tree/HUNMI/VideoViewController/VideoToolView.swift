//
//  VideoToolView.swift
//  PanoMaker
//
//  Created by 薛忱 on 2019/11/8.
//  Copyright © 2019 薛忱. All rights reserved.
//

import UIKit

protocol VideoToolViewDelegate: class {
    func selectProportion(sizeType: TSToolSizeProportionBtn.SizeType)
}

class VideoToolView: UIView {
    
    weak var delegate: VideoToolViewDelegate?
  
    var thumbnailImageView: UIImageView = UIImageView()
    var animationView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //
        let size4_5Btn = TSToolSizeProportionBtn(frame: .zero, sizeType: .size4_5, isSelected: true)
        let size1_1Btn = TSToolSizeProportionBtn(frame: .zero, sizeType: .size1_1, isSelected: false)
        let size9_16Btn = TSToolSizeProportionBtn(frame: .zero, sizeType: .size9_16, isSelected: false)
        
        
        size4_5Btn.isCurrentSelected = false
        addSubview(size4_5Btn)
        size4_5Btn.snp.makeConstraints {
            $0.height.equalTo(78)
            $0.width.equalTo(50)
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        size4_5Btn.clickBtnBlock = {
            [weak self] sizeType in
            guard let `self` = self else {return}
            self.delegate?.selectProportion(sizeType: sizeType)
            size4_5Btn.isCurrentSelected = true
            size1_1Btn.isCurrentSelected = false
            size9_16Btn.isCurrentSelected = false
        }
        //
        
        addSubview(size1_1Btn)
        size1_1Btn.snp.makeConstraints {
            $0.height.equalTo(78)
            $0.width.equalTo(50)
            $0.right.equalTo(size4_5Btn.snp.left).offset(-50)
            $0.top.equalToSuperview()
        }
        size1_1Btn.clickBtnBlock = {
            [weak self] sizeType in
            guard let `self` = self else {return}
            self.delegate?.selectProportion(sizeType: sizeType)
            size4_5Btn.isCurrentSelected = false
            size1_1Btn.isCurrentSelected = true
            size9_16Btn.isCurrentSelected = false
        }
        size1_1Btn.isCurrentSelected = true
        //
        
        addSubview(size9_16Btn)
        size9_16Btn.snp.makeConstraints {
            $0.height.equalTo(78)
            $0.width.equalTo(50)
            $0.left.equalTo(size4_5Btn.snp.right).offset(50)
            $0.top.equalToSuperview()
        }
        size9_16Btn.clickBtnBlock = {
            [weak self] sizeType in
            guard let `self` = self else {return}
            self.delegate?.selectProportion(sizeType: sizeType)
            size4_5Btn.isCurrentSelected = false
            size1_1Btn.isCurrentSelected = false
            size9_16Btn.isCurrentSelected = true
        }
        size9_16Btn.isCurrentSelected = false
         
        self.thumbnailImageView = UIImageView().then { (imageView) in
            imageView.contentMode = .scaleAspectFill
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 2
            imageView.layer.borderColor = UIColor(hexString: "#F5B9D8")?.cgColor

            self.addSubview(imageView)
            imageView.snp.makeConstraints {
                $0.left.equalTo(30)
                $0.right.equalTo(-30)
                $0.height.equalTo(60)
                $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(0)
            }
            
        }
        
        _ = UIImageView().then({ (imageView) in
            imageView.image = UIImage(named: "ic_right")
            self.addSubview(imageView)
            imageView.snp.makeConstraints {
                $0.left.equalTo(self.thumbnailImageView.snp.right)
                $0.width.equalTo(8)
                $0.height.equalTo(30)
                $0.centerY.equalTo(self.thumbnailImageView)
            }
            
        })
        
        _ = UIImageView().then({ (imageView) in
            imageView.image = UIImage(named: "ic_left")
            self.addSubview(imageView)
            imageView.snp.makeConstraints {
                $0.right.equalTo(self.thumbnailImageView.snp.left)
                $0.width.equalTo(8)
                $0.height.equalTo(28)
                $0.centerY.equalTo(self.thumbnailImageView)
            }
             
        })
        
        self.animationView = UIImageView().then({ (imageView) in
            imageView.image = UIImage(named: "border")
            self.addSubview(imageView)
            imageView.snp.makeConstraints {
                $0.left.top.equalTo(self.thumbnailImageView)
                $0.width.height.equalTo(58)
                
            }
             
        })
    }
    
    func startAnimation() {
        self.layoutIfNeeded()
        animationView.snp.makeConstraints {
            $0.width.height.equalTo(58)
            $0.left.top.equalTo(thumbnailImageView)
        }
       
        
        self.layoutIfNeeded()
        self.animationView.snp.remakeConstraints {
            $0.width.height.equalTo(58)
            $0.right.top.equalTo(thumbnailImageView)
        }
        UIView.animate(withDuration: TimeInterval(commentAnimationTime)) {
            
            self.layoutIfNeeded()
        }
    }
    
    func pauseAnimation() {
        animationView.layer.removeAllAnimations()
        animationView.snp.remakeConstraints {
            $0.width.height.equalTo(58)
            $0.left.top.equalTo(thumbnailImageView)
        }
      
        self.layoutIfNeeded()
         
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}



class TSToolSizeProportionBtn: UIButton {
    enum SizeType: String {
        case size1_1 = "1:1"
        case size4_5 = "4:5"
        case size9_16 = "9:16"
    }
    var selectView = UIImageView()
    var isCurrentSelected: Bool {
        didSet {
            selectView.isHidden = !isCurrentSelected
        }
    }
    var sizeType: TSToolSizeProportionBtn.SizeType
    var clickBtnBlock: ((TSToolSizeProportionBtn.SizeType)->Void)?
    
    init(frame: CGRect,  sizeType: TSToolSizeProportionBtn.SizeType, isSelected: Bool) {
        self.sizeType = sizeType
        self.isCurrentSelected = isSelected
        super.init(frame: frame)
        setupView()
        addTarget(self, action: #selector(btnClick(sender:)), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func btnClick(sender: UIButton) {
        clickBtnBlock?(sizeType)
    }
    
    func setupView() {
        clipsToBounds = false
        //
        let contentBgView = UIView()
        contentBgView.layer.cornerRadius = 8
        contentBgView.isUserInteractionEnabled = false
        contentBgView.backgroundColor = UIColor(hexString: "#F5B9D8")
        addSubview(contentBgView)
        var width: CGFloat = 50
        
        switch sizeType {
        case .size1_1:
            width = 50
        case .size4_5:
            width = 40
        case .size9_16:
            width = 28
        }
        
        contentBgView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(50)
            $0.width.equalTo(width)
        }
        //
        selectView.image = UIImage(named: "edit_select_ic")
        addSubview(selectView)
        selectView.snp.makeConstraints {
            $0.top.equalTo(-3)
            $0.right.equalTo(contentBgView).offset(3)
            $0.width.height.equalTo(38/2)
        }
        //
        
        var nameLabel = UILabel()
        nameLabel = makeLabelnameLabel()
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.greaterThanOrEqualTo(1)
            $0.height.greaterThanOrEqualTo(1)
            $0.top.equalTo(contentBgView.snp.bottom).offset(8)
        }
        
        func makeLabelnameLabel() -> UILabel {
            let label = UILabel()
            label.font = UIFont(name: "Avenir-Black", size: 14)
            label.textColor = UIColor(hexString: "#EF4C96")
            label.text = self.sizeType.rawValue
            label.textAlignment = .center
            label.numberOfLines = 0
            label.adjustsFontSizeToFitWidth = true
            label.backgroundColor = .clear
            
            
            
            return label
        }
        
    }
    
    
}
