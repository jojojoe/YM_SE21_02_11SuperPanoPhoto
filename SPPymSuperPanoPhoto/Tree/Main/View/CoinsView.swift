//
//  CoinsView.swift
//  PanoMaker
//
//  Created by 薛忱 on 2021/1/26.
//  Copyright © 2021 薛忱. All rights reserved.
//

import UIKit

typealias ButtonClickBlock = () -> Void



class CoinsView: UIView {
    
    var okButtonClick: ButtonClickBlock?
    var bottomBgViewHieght: CGFloat
    
    init(frame: CGRect, viewHeight: CGFloat) {
        self.bottomBgViewHieght = viewHeight
        super.init(frame: frame)
        
         
        let bottomBgView = UIView()
        bottomBgView.backgroundColor = .white
        
        bottomBgView.frame = CGRect(x: 0, y: 0, width: screen_width_CGFloat, height: bottomBgViewHieght)
//        bottomBgView.frame = CGRect(x: 0, y: 100 + screen_width_CGFloat + 20, width: screen_width_CGFloat, height: screen_hight_CGFloat - 100 - screen_width_CGFloat - 20)
        bottomBgView.corner(byRoundingCorners: [.topLeft, .topRight], radii: 46)
        self.addSubview(bottomBgView)
        
       //
        let dismissButton = UIButton()
        dismissButton.setImage(UIImage(named: "close_popup_ic"), for: .normal)
        dismissButton.addTarget(self, action: #selector(dismissButtonClick(button:)), for: .touchUpInside)
        bottomBgView.addSubview(dismissButton)
        dismissButton.snp.makeConstraints { (make) in
            make.width.equalTo(34)
            make.height.equalTo(34)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(bottomBgView).offset(10)
        }
        //
//        let dismissLine = UIView()
//        dismissLine.layer.cornerRadius = 2
//        dismissLine.backgroundColor = UIColor(hexString: "#D8D8D8")
//        dismissLine.isUserInteractionEnabled = false
//        bottomBgView.addSubview(dismissLine)
//        dismissLine.snp.makeConstraints {
//            $0.center.equalTo(dismissButton)
//            $0.width.equalTo(128)
//            $0.height.equalTo(4)
//        }
        //
        let label = UILabel()
        
        
        label.text = "Use VIP function.\nCost \(CoinManager.default.coinCostCount) coins when saving, are you sure?"
        label.textAlignment = .center
        label.textColor = UIColor(hexString: "#EF4C96")
        label.font = UIFont(name: "Avenir-Heavy", size: 18)
        label.numberOfLines = 3
        label.adjustsFontSizeToFitWidth = true
        self.addSubview(label)
        label.snp.makeConstraints { (make) in
            
            make.height.equalTo(75)
            make.left.equalTo(37)
            make.centerX.equalTo(self)
            make.centerY.equalTo(bottomBgView).offset(-10)
        }
        //
        let topImageView = UIImageView()
        topImageView.contentMode = .scaleAspectFit
        topImageView.image = UIImage(named: "store_coins_popup")
        self.addSubview(topImageView)
        topImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(48)
            make.centerX.equalTo(self)
            make.bottom.equalTo(label.snp.top).offset(-18)
        }
        //
        let okButton = UIButton()
        okButton.backgroundColor = UIColor.color(hexString: "#EF4C96")
        okButton.setTitle("OK", for: .normal)
        okButton.setTitleColor(.white, for: .normal)
        okButton.titleLabel?.font = UIFont(name: "Avenir-Black", size: 24)
        okButton.layer.cornerRadius = 24
        okButton.addTarget(self, action: #selector(okButtonClick(button:)), for: .touchUpInside)
        self.addSubview(okButton)
        okButton.snp.makeConstraints { (make) in
            make.width.equalTo(300)
            make.height.equalTo(57)
            make.top.equalTo(label.snp.bottom).offset(35)
            make.centerX.equalTo(self)
        }
    }
    
    @objc func okButtonClick(button: UIButton) {
        self.okButtonClick?()
        self.isHidden = true
        self.removeFromSuperview()
    }
    
    @objc func dismissButtonClick(button: UIButton) {
        self.isHidden = true
        self.removeFromSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
