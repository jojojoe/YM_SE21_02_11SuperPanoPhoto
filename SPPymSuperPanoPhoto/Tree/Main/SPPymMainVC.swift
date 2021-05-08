//
//  SPPymMainVC.swift
//  SPPymSuperPanoPhoto
//
//  Created by JOJO on 2021/5/7.
//

import UIKit

class SPPymMainVC: UIViewController {
    let contentBgView = UIView()
    var settingBtn = UIButton(type: .custom)
    var nameLabel = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    

}

extension SPPymMainVC {
    func setupView() {
        let bgImgV = UIImageView(image: UIImage(named: "home_bg_pic"))
        bgImgV.contentMode = .scaleAspectFill
        view.addSubview(bgImgV)
        bgImgV.snp.makeConstraints {
            $0.top.left.right.bottom.equalToSuperview()
        }
        //
        settingBtn = makeBtnSetting()
        let bgOverImgV = UIImageView(image: UIImage(named: "home_pic_ic"))
        view.addSubview(bgOverImgV)
        bgOverImgV.snp.makeConstraints {
            $0.right.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.width.equalTo(472/2)
            $0.height.equalTo(578/2)
        }
        //
        view.addSubview(contentBgView)
        contentBgView.backgroundColor = .white
        contentBgView.layer.cornerRadius =  46
        contentBgView.snp.makeConstraints {
            $0.width.equalTo(320)
            $0.height.equalTo(224)
            $0.top.equalTo(view.snp.centerY).offset(-20)
            $0.centerX.equalToSuperview()
        }
        //
        let panoBtn = MainCenterToolBtn(frame: .zero, bgColor: UIColor(hexString: "#F5B9D8") ?? .white, iconImg: UIImage(named: "home_pano_ic")!, nameTitle: "Super Pano")
        contentBgView.addSubview(panoBtn)
        panoBtn.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(38)
            $0.height.equalTo(153)
            $0.width.equalTo(110)
        }
        panoBtn.clickBlock = {
            [weak self] in
            guard let `self` = self else {return}
            
        }
        //
        let photoBtn = MainCenterToolBtn(frame: .zero, bgColor: UIColor(hexString: "#B7D09B") ?? .white, iconImg: UIImage(named: "home_collage_ic")!, nameTitle: "Photo Splicing")
        contentBgView.addSubview(photoBtn)
        photoBtn.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalTo(-38)
            $0.height.equalTo(153)
            $0.width.equalTo(110)
        }
        photoBtn.clickBlock = {
            [weak self] in
            guard let `self` = self else {return}
            
        }
        
        //
        nameLabel = makeLabelTitle()
        //
        let storeBtn = MainCoinStoreBtn()
        storeBtn.layer.cornerRadius = 32
        storeBtn.clipsToBounds = true
        view.addSubview(storeBtn)
        storeBtn.snp.makeConstraints {
            $0.top.equalTo(contentBgView.snp.bottom).offset(22)
            $0.centerX.equalToSuperview()
            $0.left.equalTo(contentBgView)
            $0.height.equalTo(72)
        }
        storeBtn.clickBlock = {
            [weak self] in
            guard let `self` = self else {return}
            
        }
    }
    
    func makeLabelTitle() -> UILabel {
        let titleNameLabel = UILabel()
        titleNameLabel.font = UIFont(name: "Alstoria", size: 60)
        titleNameLabel.textColor = UIColor(hexString: "#FFFFFF")
        titleNameLabel.text = "Photo\nSplicing"
        titleNameLabel.textAlignment = .left
        titleNameLabel.numberOfLines = 2
        titleNameLabel.adjustsFontSizeToFitWidth = true
        titleNameLabel.backgroundColor = .clear
        
        view.addSubview(titleNameLabel)
        titleNameLabel.snp.makeConstraints {
            $0.left.equalTo(28)
            $0.bottom.equalTo(contentBgView.snp.top).offset(-54)
            $0.width.greaterThanOrEqualTo(1)
            $0.height.greaterThanOrEqualTo(1)
        }
        
        return titleNameLabel
    }
    
    func makeBtnSetting() -> UIButton {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "home_setting_ic"), for: .normal)
        btn.setTitle("", for: .normal)
        btn.setTitleColor(UIColor(hexString: "#FFFFFF"), for: .normal)
        btn.setBackgroundImage(UIImage(named: ""), for: .normal)
        btn.backgroundColor = .clear
        btn.titleLabel?.font = UIFont(name: "", size: 18)
        view.addSubview(btn)
        btn.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.left.equalTo(10)
            $0.width.equalTo(44)
            $0.height.equalTo(44)
        }
        btn.addTarget(self, action: #selector(btnClickSetting(sender:)), for: .touchUpInside)
        return btn
    }
    @objc func btnClickSetting(sender: UIButton) {
         
    }
    
}




class MainCenterToolBtn: UIButton {
    var bgColor: UIColor
    var iconImg: UIImage
    var nameTitle: String
    var clickBlock: (()->Void)?
    
    
    
    init(frame: CGRect, bgColor: UIColor, iconImg: UIImage, nameTitle: String) {
        self.bgColor = bgColor
        self.iconImg = iconImg
        self.nameTitle = nameTitle
        super.init(frame: frame)
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        let bgView = UIView()
        bgView.backgroundColor = bgColor
        bgView.layer.cornerRadius = 32
        addSubview(bgView)
        bgView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(110)
        }
        //
        let iconImgV = UIImageView(image: iconImg)
        bgView.addSubview(iconImgV)
        iconImgV.contentMode = .scaleAspectFit
        iconImgV.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(30)
        }
        //
        var nameLabel = UILabel()
        nameLabel = makeLabel()
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(bgView.snp.bottom).offset(16)
            $0.width.greaterThanOrEqualTo(1)
            $0.height.greaterThanOrEqualTo(1)
        }
        
        self.addTarget(self, action: #selector(clickAction(sender:)), for: .touchUpInside)
        
        func makeLabel() -> UILabel {
            let label = UILabel()
            label.font = UIFont(name: "Alstoria", size: 18)
            label.textColor = bgColor
            label.text = nameTitle
            label.textAlignment = .left
            label.numberOfLines = 1
            label.adjustsFontSizeToFitWidth = true
            label.backgroundColor = .clear
            
            return label
        }
    }
    
    @objc func clickAction(sender: UIButton) {
        clickBlock?()
    }
    
}


class MainCoinStoreBtn: UIButton {
    var clickBlock: (()->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        addTarget(self, action: #selector(clickAction(sender:)), for: .touchUpInside)
    }
    
    @objc func clickAction(sender: UIButton) {
        clickBlock?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        self.backgroundColor = .white
        
        //
        let iconImgV = UIImageView(image: UIImage(named: "coins_store_ic"))
        addSubview(iconImgV)
        iconImgV.snp.makeConstraints {
            $0.width.height.equalTo(36)
            $0.centerY.equalToSuperview()
            $0.left.equalTo(40)
        }
        //
        var label = UILabel()
        label = makeLabel()
        addSubview(label)
        label.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(iconImgV.snp.right).offset(13)
            $0.width.greaterThanOrEqualTo(1)
            $0.height.greaterThanOrEqualTo(1)
        }
        func makeLabel() -> UILabel {
            let label = UILabel()
            label.font = UIFont(name: "Alstoria", size: 18)
            label.textColor = UIColor(hexString: "#ECA86B")
            label.text = "Coins Store"
            label.textAlignment = .center
            label.numberOfLines = 0
            label.adjustsFontSizeToFitWidth = true
            label.backgroundColor = .clear
            
            return label
        }
        //
        let imgV = UIImageView(image: UIImage(named: "home_next_ic"))
        addSubview(imgV)
        imgV.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.centerY.equalToSuperview()
            $0.right.equalTo(-38)
        }
        
        
    }
    
    
}

