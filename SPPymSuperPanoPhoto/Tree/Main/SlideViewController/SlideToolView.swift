//
//  SlideToolView.swift
//  PanoMaker
//
//  Created by 薛忱 on 2019/11/7.
//  Copyright © 2019 薛忱. All rights reserved.
//

import UIKit

protocol SlideToolViewDelegate: class {
//    func selectProportion(sizeType: TSToolSizeProportionBtn.SizeType)
//    func selectPagenum(pageNum: Int)
    func updateSlideEditView(sizeType: TSToolSizeProportionBtn.SizeType, pageNum: Int)
}

class SlideToolView: UIView {
    
    let addNumBtn = UIButton(type: .custom)
    let numPreviewLabel = UILabel()
    let subNumBtn = UIButton(type: .custom)
    
    var currentSizeType : TSToolSizeProportionBtn.SizeType = .size1_1
    var currentPageNum: Int = 1
    
    
    weak var delegate: SlideToolViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
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
            self.currentSizeType = .size4_5
            self.delegate?.updateSlideEditView(sizeType: self.currentSizeType, pageNum: self.currentPageNum)
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
            self.currentSizeType = .size1_1
            self.delegate?.updateSlideEditView(sizeType: self.currentSizeType, pageNum: self.currentPageNum)
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
            self.currentSizeType = .size9_16
            self.delegate?.updateSlideEditView(sizeType: self.currentSizeType, pageNum: self.currentPageNum)
            size4_5Btn.isCurrentSelected = false
            size1_1Btn.isCurrentSelected = false
            size9_16Btn.isCurrentSelected = true
        }
        size9_16Btn.isCurrentSelected = false
        
        //
        let numberlabel = UILabel()
        numberlabel.font = UIFont(name: "Avenir-Black", size: 14)
        numberlabel.text = "Number"
        numberlabel.textColor = UIColor(hexString: "#EF4C96")
        addSubview(numberlabel)
        numberlabel.snp.makeConstraints {
            $0.left.equalTo(60)
            $0.top.equalTo(size9_16Btn.snp.bottom).offset(66)
            $0.height.greaterThanOrEqualTo(1)
            $0.width.greaterThanOrEqualTo(1)
        }
        //

        addNumBtn.setImage(UIImage(named: "pic_add_ic_s"), for: .normal)
        addSubview(addNumBtn)
        addNumBtn.snp.makeConstraints {
            $0.right.equalTo(-42)
            $0.centerY.equalTo(numberlabel)
            $0.width.height.equalTo(34)
        }
        addNumBtn.addTarget(self, action: #selector(addNumBtnClick(sender:)), for: .touchUpInside)
        //

        numPreviewLabel.font = UIFont(name: "Avenir-Black", size: 20)
        numPreviewLabel.textColor = UIColor(hexString: "#EF4C96")
        numPreviewLabel.text = "1"
        numPreviewLabel.backgroundColor = UIColor(hexString: "#FFF2F9")
        numPreviewLabel.layer.borderWidth = 1
        numPreviewLabel.layer.borderColor = UIColor(hexString: "#FFDBED")?.cgColor
        numPreviewLabel.layer.cornerRadius = 8
        numPreviewLabel.textAlignment = .center
        addSubview(numPreviewLabel)
        numPreviewLabel.snp.makeConstraints {
            $0.centerY.equalTo(addNumBtn)
            $0.right.equalTo(addNumBtn.snp.left).offset(-10)
            $0.width.height.equalTo(36)
        }
        
        //
        
        subNumBtn.setImage(UIImage(named: "pic_down_ic_s"), for: .normal)
        addSubview(subNumBtn)
        subNumBtn.snp.makeConstraints {
            $0.centerY.equalTo(addNumBtn)
            $0.right.equalTo(numPreviewLabel.snp.left).offset(-10)
            $0.width.height.equalTo(34)
        }
        subNumBtn.addTarget(self, action: #selector(subNumBtnClick(sender:)), for: .touchUpInside)

        updateNumberBtnStatus()
          
    }
    
    @objc func addNumBtnClick(sender: UIButton) {
        numPreviewLabel.text = "\((numPreviewLabel.text?.int ?? 1) + 1)"
        updateNumberBtnStatus()
    }
    @objc func subNumBtnClick(sender: UIButton) {
        numPreviewLabel.text = "\((numPreviewLabel.text?.int ?? 1) - 1)"
        updateNumberBtnStatus()
    }
    
    func subNumberEnable(isEnable: Bool) {
        subNumBtn.isEnabled = isEnable
        subNumBtn.alpha = isEnable ? 1 : 0.5
        
    }
    func addNumberEnable(isEnable: Bool){
        addNumBtn.isEnabled = isEnable
        addNumBtn.alpha = isEnable ? 1 : 0.5
    }
    func updateNumberBtnStatus() {
        if numPreviewLabel.text == "1" {
            subNumberEnable(isEnable: false)
            addNumberEnable(isEnable: true)
        } else if numPreviewLabel.text == "2" {
            subNumberEnable(isEnable: true)
            addNumberEnable(isEnable: true)
        } else if numPreviewLabel.text == "3" {
            subNumberEnable(isEnable: true)
            addNumberEnable(isEnable: true)
        } else if numPreviewLabel.text == "4" {
            subNumberEnable(isEnable: true)
            addNumberEnable(isEnable: false)
        }
        self.currentPageNum = numPreviewLabel.text?.int ?? 1
        self.delegate?.updateSlideEditView(sizeType: self.currentSizeType, pageNum: self.currentPageNum)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
