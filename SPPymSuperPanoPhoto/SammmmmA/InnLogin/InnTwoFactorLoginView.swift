//
//  InnTwoFactorLoginView.swift
//  InnLoginExample
//
//  Created by Charles on 2020/8/10.
//  Copyright © 2020 Charles. All rights reserved.
//

import UIKit

class InnTwoFactorLoginView: UIView {
    @IBOutlet weak var  codeView:UIView!
    @IBOutlet weak var  tipLab:UILabel!
    @IBOutlet weak var  okBtn:UIButton!
    @IBOutlet weak var  bottomLab:UILabel!
    @IBOutlet weak var  codeTF:UITextField!
    var okActionHandler:((_ code:String?)->())?
    var closeClick:(()->())?
    
    var codeStr:String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.okBtn.isEnabled = true
        self.okBtn.backgroundColor = UIColor.init(red: 14.0 / 255.0, green: 129.0 / 255.0, blue: 221.0 / 255.0, alpha: 1)
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }
    
    @IBAction func okAction(_ sender:Any) {
        if self.codeTF.text?.count ?? 0 > 0 {
          self.okActionHandler?(self.codeTF.text)
        }
    }


    @IBAction func closeAction(_ sender:Any) {
        self.closeClick?()
    }
}
