//
//  SPPymSettingVC.swift
//  SPPymSuperPanoPhoto
//
//  Created by JOJO on 2021/5/8.
//

import UIKit
import MessageUI
import StoreKit
import Defaults
import NoticeObserveKit


let AppName: String = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "Insta Gird"
let purchaseUrl = ""
let TermsofuseURLStr = "http://certain-direction.surge.sh/Terms_of_use.html"
let PrivacyPolicyURLStr = "http://adorable-muscle.surge.sh/Privacy_Agreement.html"

let feedbackEmail: String = "xjabsuauxnd@yandex.com"
let AppAppStoreID: String = ""



class SPPymSettingVC: UIViewController {
    var backBtn = UIButton(type: .custom)
//    let privacyBtn = UIButton(type: .custom)
//    let termsBtn = UIButton(type: .custom)
//    let feedbackBtn = UIButton(type: .custom)
    let loginBtn = UIButton(type: .custom)
    
//    let logoutBtn = UIButton(type: .custom)
    
    let userNameLabel = UILabel()
    
    
    let feedbackBtn = SettingContentBtn(frame: .zero, name: "Feedback", iconImage: UIImage(named: "feedback_ic")!)
    let privacyLinkBtn = SettingContentBtn(frame: .zero, name: "Privacy Link", iconImage: UIImage(named: "link_ic")!)
    let termsBtn = SettingContentBtn(frame: .zero, name: "Terms of use", iconImage: UIImage(named: "trems_of_use_ic")!)
    let logoutBtn = SettingContentBtn(frame: .zero, name: "Log Out", iconImage: UIImage(named: "log_out_ic")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let bgImgV = UIImageView(image: UIImage(named: "home_bg_pic"))
        bgImgV.contentMode = .scaleAspectFill
        view.addSubview(bgImgV)
        bgImgV.snp.makeConstraints {
            $0.top.right.left.bottom.equalToSuperview()
        }
        setupView()
        setupContentView()
        updateUserAccountStatus()
        
    }
    
    func setupView() {
        
        backBtn = makeBtnBack()
        func makeBtnBack() -> UIButton {
            let btn = UIButton(type: .custom)
            btn.setImage(UIImage(named: "pano_back_ic"), for: .normal)
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
        
        
        var topTitle = UILabel()
        topTitle = makeLabelTopTitle()
        view.addSubview(topTitle)
        topTitle.snp.makeConstraints {
            $0.centerY.equalTo(backBtn)
            $0.centerX.equalToSuperview()
            $0.width.greaterThanOrEqualTo(1)
            $0.height.greaterThanOrEqualTo(1)
        }
        
        func makeLabelTopTitle() -> UILabel {
            let label = UILabel()
            label.font = UIFont(name: "Alstoria-Regular", size: 18)
            label.textColor = UIColor(hexString: "#FFFFFF")
            label.text = "Setting"
            label.textAlignment = .center
            label.numberOfLines = 0
            label.adjustsFontSizeToFitWidth = true
            label.backgroundColor = .clear
            
            return label
        }
    }
    @objc func makeBtnBackClick(sender: UIButton) {
        if self.navigationController != nil {
            self.navigationController?.popViewController()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func setupContentView() {
        // feedback
        
        view.addSubview(feedbackBtn)
        feedbackBtn.clickBlock = {
            [weak self] in
            guard let `self` = self else {return}
            self.feedback()
        }
        feedbackBtn.snp.makeConstraints {
            $0.width.height.equalTo(110)
            $0.top.equalTo(backBtn.snp.bottom).offset(210)
            $0.right.equalTo(view.safeAreaLayoutGuide.snp.centerX).offset(-12)
        }
        // privacy link
        
        view.addSubview(privacyLinkBtn)
        privacyLinkBtn.clickBlock = {
            [weak self] in
            guard let `self` = self else {return}
            UIApplication.shared.openURL(url: PrivacyPolicyURLStr)
        }
        privacyLinkBtn.snp.makeConstraints {
            $0.width.height.equalTo(110)
            $0.top.equalTo(feedbackBtn.snp.top)
            $0.left.equalTo(view.safeAreaLayoutGuide.snp.centerX).offset(12)
        }
        // terms
        
        view.addSubview(termsBtn)
        termsBtn.clickBlock = {
            [weak self] in
            guard let `self` = self else {return}
            UIApplication.shared.openURL(url: TermsofuseURLStr)
        }
        termsBtn.snp.makeConstraints {
            $0.width.height.equalTo(110)
            $0.top.equalTo(feedbackBtn.snp.bottom).offset(24)
            $0.left.equalTo(feedbackBtn.snp.left)
        }
        // logout
        
        view.addSubview(logoutBtn)
        logoutBtn.clickBlock = {
            [weak self] in
            guard let `self` = self else {return}
            LoginManage.shared.logout()
            self.updateUserAccountStatus()
        }
        logoutBtn.snp.makeConstraints {
            $0.width.height.equalTo(110)
            $0.top.equalTo(termsBtn.snp.top)
            $0.left.equalTo(privacyLinkBtn.snp.left)
        }
        //
        //
        view.addSubview(loginBtn)
        loginBtn.setImage(UIImage(named: "setting_profile_ic"), for: .normal)
        loginBtn.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(backBtn.snp.bottom).offset(60)
            $0.width.height.equalTo(56)
        }
        loginBtn.addTarget(self, action: #selector(loginBtnClick(sender:)), for: .touchUpInside)
        //
        userNameLabel.font = UIFont(name: "Avenir-Black", size: 18)
        userNameLabel.textColor = .white
        userNameLabel.text = "Click on the avatar to login"
        view.addSubview(userNameLabel)
        userNameLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(loginBtn.snp.bottom).offset(20)
            $0.width.greaterThanOrEqualTo(1)
            $0.height.greaterThanOrEqualTo(1)
        }
        
    }
    
    
    
    
    
    
    
}

extension SPPymSettingVC {
 
    @objc func loginBtnClick(sender: UIButton) {
        self.showLoginVC()
        
    }
    
    
    
    func showLoginVC() {
        if LoginManage.currentLoginUser() == nil {
            let loginVC = LoginManage.shared.obtainVC()
            loginVC.modalTransitionStyle = .crossDissolve
            loginVC.modalPresentationStyle = .fullScreen
            
            self.present(loginVC, animated: true) {
            }
        }
    }
    func updateUserAccountStatus() {
        if let userModel = LoginManage.currentLoginUser() {
            let userName  = userModel.userName
            userNameLabel.text = (userName?.count ?? 0) > 0 ? userName : ""
            logoutBtn.isHidden = false
            loginBtn.isUserInteractionEnabled = false
            
        } else {
            userNameLabel.text = "Click on the avatar to login"
            logoutBtn.isHidden = true
            loginBtn.isUserInteractionEnabled = true
            
        }
    }
}

extension SPPymSettingVC: MFMailComposeViewControllerDelegate {
    func feedback() {
        //首先要判断设备具不具备发送邮件功能
        if MFMailComposeViewController.canSendMail(){
            //获取系统版本号
            let systemVersion = UIDevice.current.systemVersion
            let modelName = UIDevice.current.modelName
            
            let infoDic = Bundle.main.infoDictionary
            // 获取App的版本号
            let appVersion = infoDic?["CFBundleShortVersionString"] ?? "8.8.8"
            // 获取App的名称
            let appName = "\(AppName)"

            
            let controller = MFMailComposeViewController()
            //设置代理
            controller.mailComposeDelegate = self
            //设置主题
            controller.setSubject("\(appName) Feedback")
            //设置收件人
            // FIXME: feed back email
            controller.setToRecipients([feedbackEmail])
            //设置邮件正文内容（支持html）
         controller.setMessageBody("\n\n\nSystem Version：\(systemVersion)\n Device Name：\(modelName)\n App Name：\(appName)\n App Version：\(appVersion )", isHTML: false)
            
            //打开界面
         self.present(controller, animated: true, completion: nil)
        }else{
            HUD.error("The device doesn't support email")
        }
    }
    
    //发送邮件代理方法
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
    }
 }


class SettingContentBtn: UIButton {
    var clickBlock: (()->Void)?
    var nameTitle: String
    var iconImage: UIImage
    init(frame: CGRect, name: String, iconImage: UIImage) {
        self.nameTitle = name
        self.iconImage = iconImage
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
        self.layer.cornerRadius = 32
        //
        let iconImgV = UIImageView(image: iconImage)
        addSubview(iconImgV)
        iconImgV.snp.makeConstraints {
            $0.width.height.equalTo(28)
            $0.centerY.equalToSuperview().offset(-10)
            $0.centerX.equalToSuperview()
        }
        //
        var label = UILabel()
        label = makeLabel()
        addSubview(label)
        
        label.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(iconImgV.snp.bottom).offset(9)
            $0.left.equalTo(snp.left).offset(4)
            $0.height.greaterThanOrEqualTo(1)
        }
        func makeLabel() -> UILabel {
            let label = UILabel()
            label.font = UIFont(name: "Alstoria-Regular", size: 16)
            label.textColor = UIColor(hexString: "#EF4C96")
            label.text = nameTitle
            label.textAlignment = .center
            label.numberOfLines = 1
            label.adjustsFontSizeToFitWidth = true
            label.backgroundColor = .clear
            return label
        }
         
        
    }
    
}
