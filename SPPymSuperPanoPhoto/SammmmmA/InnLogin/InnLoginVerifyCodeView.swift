//
//  InnLoginVerifyCodeView.swift
//  InnLoginExample
//
//  Created by Charles on 2020/8/10.
//  Copyright © 2020 Charles. All rights reserved.
//

import UIKit

class InnLoginVerifyCodeView: UIView {
    
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var codeView: UIView!
    @IBOutlet weak var tipLab: UILabel!
    
    var codeStr:String?
    var okActionHandler:((_ code:String?)->())?
    var resendCodeHandler:(()->())?
    var closeClick:(()->())?

    lazy var tv: InnTextView = {
        let textView = InnTextView(frame: CGRect(x: 0, y: 0, width: 220, height: 40), codeSize: CGSize(width: 30, height: 40), maxCount: 6)
        textView.setUpText(.black, highlightColor: .black, textFont: UIFont.systemFont(ofSize: 15), textAlignment: .center, keyboardType: .numberPad)
        textView.setUpBorder(.lightGray, highlightBorderColor: .gray, borderWidth: 1, borderCornerRadius: 3)
        textView.delegate = self
     
        return textView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func initialSubViews() {
        self.okBtn.isEnabled = false
        self.okBtn.backgroundColor = UIColor.lightGray

        self.codeView.addSubview(tv)
        
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }

    @IBAction func okAction(_ sender: Any) {
     
         self.okActionHandler?(self.codeStr)
        
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.closeClick?()
    }
    
}


extension InnLoginVerifyCodeView:InnTextViewDelegate {
    func textViewDidChangeEdit(codeStr: String) {
        self.codeStr = codeStr
        
        if codeStr.count >= 6 {
            self.okBtn.isEnabled = true
            self.okBtn.backgroundColor = UIColor.init(red: 14.0 / 255.0, green: 129.0 / 255.0, blue: 221.0 / 255.0, alpha: 1)
        } else {
            self.okBtn.isEnabled = false
            self.okBtn.backgroundColor = UIColor.lightGray
        }
    }
    
    func textViewDidFinishedEdit(codeStr: String) {
        self.codeStr = codeStr
        
        if codeStr.count >= 6 {
            self.okBtn.isEnabled = true
            self.okBtn.backgroundColor = UIColor.init(red: 14.0 / 255.0, green: 129.0 / 255.0, blue: 221.0 / 255.0, alpha: 1)
        } else {
            self.okBtn.isEnabled = false
            self.okBtn.backgroundColor = UIColor.lightGray
        }
    }
}
