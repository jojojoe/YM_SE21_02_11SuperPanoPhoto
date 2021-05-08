//
//  SPPymSettingVC.swift
//  SPPymSuperPanoPhoto
//
//  Created by JOJO on 2021/5/8.
//

import UIKit

class SPPymSettingVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        
    }
    
    func setupView() {
        var backBtn = UIButton(type: .custom)
        backBtn = makeBtnBack()
        func makeBtnBack() -> UIButton {
            let btn = UIButton(type: .custom)
            btn.setImage(UIImage(named: ""), for: .normal)
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
            btn.addTarget(self, action: #selector(makeBtnBackClick(sender:)), for: .touchUpInside)
            return btn
        }
        @objc func makeBtnBackClick(sender: UIButton) {
            if self.navigationController != nil {
                self.navigationController?.popViewController()
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    

}

extension SPPymSettingVC {
    
}
