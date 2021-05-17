//
//  SPPPanoHomeVC.swift
//  SPPymSuperPanoPhoto
//
//  Created by JOJO on 2021/5/10.
//

import UIKit

class SPPPanoHomeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    

    func setupView() {
        //
        let backBtn = UIButton(type: .custom)
        view.addSubview(backBtn)
        backBtn.setImage(UIImage(named: "pano_back_ic"), for: .normal)
        backBtn.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.left.equalTo(10)
            $0.width.height.equalTo(44)
        }
        backBtn.addTarget(self, action: #selector(backBtnClick(sender:)), for: .touchUpInside)
        //
        let titleLabel = UILabel(text: "Super Pano")
        titleLabel.font = UIFont(name: "Alstoria-Regular", size: 18)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        titleLabel.textColor = UIColor(hexString: "#FFFFFF")
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(backBtn)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(28)
            $0.width.equalTo(100)
        }
        //
        
        
        
    }

}

extension SPPPanoHomeVC {
    @objc func backBtnClick(sender: UIButton) {
        if self.navigationController == nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController()
        }
    }
    
    
}




