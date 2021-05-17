//
//  SSPMultiSlideToolView.swift
//  SPPymSuperPanoPhoto
//
//  Created by JOJO on 2021/5/12.
//

import UIKit
import YPImagePicker

class SSPMultiSlideToolView: UIView {
    
    let temepBtn = MultiSlideToolBottomBtn(frame: .zero, titleName: "Temeplate")
    let splicBtn = MultiSlideToolBottomBtn(frame: .zero, titleName: "Splicing")
    
    var bottomBgViewHieght: CGFloat
    var mobanList: [String]
    var filterClickBlock: ((YPFilter)->Void)?
    var mobanClickBlock: ((String,Bool)->Void)?
    var bottomActionClick: ((String)->Void)?
    var slideVerBtnClickBlock: (()->Void)?
    var slideHorBtnClickBlock: (()->Void)?
    let filterBar = SSPMultiSlideFilterView()
    var tempBar: SSPMultiSlideTempBar?
    
    let slideHorBtn = UIButton(type: .custom)
    let slideVerBtn = UIButton(type: .custom)
    
    init(frame: CGRect, viewHeight: CGFloat, mobanList: [String]) {
        self.bottomBgViewHieght = viewHeight
        self.mobanList = mobanList
        super.init(frame: frame)
        
        let bottomBgView = UIView()
        bottomBgView.backgroundColor = .white
        bottomBgView.frame = CGRect(x: 0, y: 0, width: screen_width_CGFloat, height: bottomBgViewHieght)
        bottomBgView.corner(byRoundingCorners: [.topLeft, .topRight], radii: 46)
        self.addSubview(bottomBgView)
        //
        
        //
        temepBtn.isCurrentSelected = true
        addSubview(temepBtn)
        temepBtn.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-10)
            $0.right.equalTo(snp.centerX).offset(-20)
            $0.width.equalTo(100)
            $0.height.equalTo(40)
        }
        temepBtn.clickActionBlock = {
            [weak self] in
            guard let `self` = self else {return}
            self.temepBtn.isCurrentSelected = true
            self.splicBtn.isCurrentSelected = false
            
            self.bottomActionClick?("temeplate")
            
            self.filterBar.isHidden = false
            self.tempBar?.isHidden = false
            self.slideHorBtn.isHidden = true
            self.slideVerBtn.isHidden = true
        }
        //
        addSubview(splicBtn)
        splicBtn.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-10)
            $0.left.equalTo(snp.centerX).offset(20)
            $0.width.equalTo(100)
            $0.height.equalTo(40)
        }
        splicBtn.clickActionBlock = {
            [weak self] in
            guard let `self` = self else {return}
            self.temepBtn.isCurrentSelected = false
            self.splicBtn.isCurrentSelected = true
            
            self.bottomActionClick?("splic")
            
            self.filterBar.isHidden = true
            self.tempBar?.isHidden = true
            self.slideHorBtn.isHidden = false
            self.slideVerBtn.isHidden = false
        }
        self.temepBtn.isCurrentSelected = true
        self.splicBtn.isCurrentSelected = false
        self.filterBar.isHidden = false
        self.tempBar?.isHidden = false
        self.slideHorBtn.isHidden = true
        self.slideVerBtn.isHidden = true
        //
        
        addSubview(filterBar)
        filterBar.snp.makeConstraints {
            $0.bottom.equalTo(splicBtn.snp.top).offset(-24)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(120)
        }
        filterBar.filterClickBlock = {
            [weak self] filter in
            guard let `self` = self else {return}
            //
            self.filterClickBlock?(filter)
        }
        //
        let tempBar = SSPMultiSlideTempBar(frame: .zero, mobanList: mobanList)
        self.tempBar = tempBar
        addSubview(tempBar)
        tempBar.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.bottom.equalTo(filterBar.snp.top).offset(-24)
            $0.height.equalTo(61)
        }
        tempBar.clickTempItemBlock = {
            [weak self] tempItem, isPro in
            guard let `self` = self else {return}
            self.mobanClickBlock?(tempItem, isPro)
        }
        //
        
        slideHorBtn.setImage(UIImage(named: "right_left_ic"), for: .normal)
        slideVerBtn.setImage(UIImage(named: "up_down_ic"), for: .normal)
        addSubview(slideHorBtn)
        addSubview(slideVerBtn)
        slideHorBtn.snp.makeConstraints {
            $0.right.equalTo(snp.centerX).offset(-40)
            $0.centerY.equalToSuperview().offset(-20)
            $0.width.height.equalTo(118/2)
        }
        slideVerBtn.snp.makeConstraints {
            $0.left.equalTo(snp.centerX).offset(40)
            $0.centerY.equalToSuperview().offset(-20)
            $0.width.height.equalTo(118/2)
        }
        
        slideHorBtn.addTarget(self, action: #selector(slideHorBtnClick(button:)), for: .touchUpInside)

        slideVerBtn.addTarget(self, action: #selector(slideVerBtnClick(button:)), for: .touchUpInside)
    }
    
    @objc func slideHorBtnClick(button: UIButton) {
        slideHorBtnClickBlock?()
    }
    
    @objc func slideVerBtnClick(button: UIButton) {
        slideVerBtnClickBlock?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}





class MultiSlideToolBottomBtn: UIButton {
    
    let nameLabel = UILabel()
    let selectView = UIView()
    var nameStr: String
    var clickActionBlock: (()->Void)?
    
    var isCurrentSelected: Bool = false {
        didSet {
            selectView.isHidden = !isCurrentSelected
            if isCurrentSelected == true {
                nameLabel.textColor = UIColor(hexString: "#EF4C96")
            } else {
                nameLabel.textColor = UIColor(hexString: "#F697C2")
            }

        }
    }
    
    init(frame: CGRect, titleName: String) {
        nameStr = titleName
        super.init(frame: frame)
        setupView()
        addTarget(self, action: #selector(clickAction(sender:)), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func clickAction(sender: UIButton) {
        clickActionBlock?()
    }
    
    func setupView() {
        addSubview(selectView)
        selectView.backgroundColor = UIColor(hexString: "#EF4C96")
        selectView.layer.cornerRadius = 3
        selectView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.equalTo(88)
            $0.height.equalTo(4)
        }
        //
        nameLabel.text = nameStr
        nameLabel.font = UIFont(name: "Alstoria-Regular", size: 18)
        nameLabel.textColor = UIColor(hexString: "#EF4C96")
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.bottom.equalTo(selectView.snp.top).offset(-8)
            $0.centerX.equalToSuperview()
            $0.width.greaterThanOrEqualTo(1)
            $0.height.greaterThanOrEqualTo(1)
        }
        //
        
    }
    
}




