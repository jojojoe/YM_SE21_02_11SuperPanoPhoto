//
//  APLoginVC.swift
//  CAymCircleAvatarForTT
//
//  Created by JOJO on 2021/4/16.
//

import UIKit
import FirebaseAuth
import FirebaseUI
import Firebase
import AuthenticationServices
import DeviceKit
import SnapKit

class APLoginVC: FUIAuthPickerViewController, FUIAuthDelegate {
    
    let ppUrl = "http://late-language.surge.sh/Privacy_Agreement.htm"
    let touUrl = "http://late-language.surge.sh/Terms_of_use.htm"
    
    let def_fontName = ""
    
    override init(nibName: String?, bundle: Bundle?, authUI: FUIAuth) {
        super.init(nibName: "FUIAuthPickerViewController", bundle: bundle, authUI: authUI)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var buttons: [UIButton] = []
    var collection: UICollectionView!
    let bgImageView = UIImageView()
    let pageControl = UIPageControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.findButtons(subView: self.view)
        setupView()
        
    }
    
    func findButtons(subView: UIView) {
        
        if subView.isKind(of: UIButton.classForCoder()) {
            
            if let button = subView as? UIButton {
                buttons.append(button)
            }
            return
        } else {
            subView.backgroundColor = .clear
        }
        
        for sv in subView.subviews {
            findButtons(subView: sv)
        }
    }
    
    @objc func closebuttonClick(button: UIButton) {
        self.dismiss(animated: true) {
        }
    }
    
    @objc func appleButtonClick(button: UIButton) {
        let requestID = ASAuthorizationAppleIDProvider().createRequest()
                // 这里请求了用户的姓名和email
                requestID.requestedScopes = [.fullName, .email]
                
                let controller = ASAuthorizationController(authorizationRequests: [requestID])
                controller.delegate = self
                controller.presentationContextProvider = self
                controller.performRequests()
    }
    
    func customFont(fontName: String, size: CGFloat) -> UIFont {
        let stringArray: Array = fontName.components(separatedBy: ".")
        let path = Bundle.main.path(forResource: stringArray[0], ofType: stringArray[1])
        let fontData = NSData.init(contentsOfFile: path ?? "")
        
        let fontdataProvider = CGDataProvider(data: CFBridgingRetain(fontData) as! CFData)
        let fontRef = CGFont.init(fontdataProvider!)!
        
        var fontError = Unmanaged<CFError>?.init(nilLiteral: ())
        CTFontManagerRegisterGraphicsFont(fontRef, &fontError)
        
        let fontName: String =  fontRef.postScriptName as String? ?? ""
        let font = UIFont(name: fontName, size: size)
        
        fontError?.release()
        
        return font ?? UIFont(name: def_fontName, size: size)!
    }
    
    @objc func buttonClick(button: UIButton) {
        
        switch button.tag {
            
        case 1001:
            let url = URL(string: ppUrl)
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            break
            
        case 1002:
            let url = URL(string: touUrl)
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            break

        default:
            break
        }
    }
 
}

extension APLoginVC {
    func setupView() {
        
        let appleButton = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
        appleButton.addTarget(self, action: #selector(appleButtonClick(button:)), for: .touchUpInside)
        self.view.addSubview(appleButton)
        appleButton.snp.makeConstraints { (make) in
            make.width.equalTo(280)
            make.height.equalTo(48)
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-170)
        }
        
        let googleButton = buttons[0]
        googleButton.layer.cornerRadius = 8
        googleButton.layer.masksToBounds = true
        googleButton.setTitle(" Sign in with Google", for: .normal)
        googleButton.setTitleColor(.black, for: .normal)
        googleButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        googleButton.frame = CGRect.zero
        googleButton.backgroundColor = .white
        googleButton.contentHorizontalAlignment = .center
        self.view.addSubview(googleButton)
        googleButton.snp.makeConstraints { (make) in
            make.width.equalTo(280)
            make.height.equalTo(48)
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-106)
        }

        // Do any additional setup after loading the view.
        
        bgImageView.image = UIImage(named: "")
        bgImageView.backgroundColor = UIColor(hexString: "#000000")
        bgImageView.contentMode = .scaleAspectFill
        self.view.insertSubview(bgImageView, at: 0)
        bgImageView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(0)
        }
        
        let topView = UIView()
        topView.backgroundColor = UIColor.clear
        self.view.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(44)
        }
        
        let closebutton = UIButton()
        closebutton.alpha = 1
        closebutton.setImage(UIImage(named: "splash_icon_close"), for: .normal)
        closebutton.addTarget(self, action: #selector(closebuttonClick(button:)), for: .touchUpInside)
        topView.addSubview(closebutton)
        closebutton.snp.makeConstraints { (make) in
            make.width.height.equalTo(44)
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
        }
         
        let contentBgView = UIView()
        contentBgView.backgroundColor = .clear
        view.addSubview(contentBgView)
        var padding: CGFloat = -290
        if Device.current.diagonal == 4.7 {
            padding = -260
        }
        contentBgView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(topView.snp.bottom).offset(40)
            $0.bottom.equalToSuperview().offset(padding)
        }
        //
        let iconImgV = UIImageView(image: UIImage(named: "splash_img"))
        iconImgV.contentMode = .scaleAspectFit
        contentBgView.addSubview(iconImgV)
        iconImgV.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalTo(22)
            $0.centerX.equalToSuperview()
            $0.height.equalTo((UIScreen.main.bounds.size.width - 22 * 2) * (1018.0/736.0))
        }
        
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        collection = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
//        collection.isPagingEnabled = true
//        collection.clipsToBounds = false
//        collection.showsVerticalScrollIndicator = false
//        collection.showsHorizontalScrollIndicator = false
//        collection.backgroundColor = .clear
//        collection.delegate = self
//        collection.dataSource = self
//        contentBgView.addSubview(collection)
//        collection.snp.makeConstraints {
//            $0.top.bottom.right.left.equalToSuperview()
//        }
//        collection.register(cellWithClass: APLoginSplashCell.self)
        
        //
//        contentBgView.addSubview(pageControl)
//        pageControl.numberOfPages = 3
//        pageControl.currentPage = 0
//        pageControl.pageIndicatorTintColor = UIColor(hexString: "#FFFFFF")?.withAlphaComponent(0.7)
//        pageControl.currentPageIndicatorTintColor = UIColor(hexString: "#FFFFFF")
//        pageControl.snp.makeConstraints {
//            $0.centerX.equalToSuperview()
//            $0.height.equalTo(10)
//            $0.width.greaterThanOrEqualTo(10)
//            $0.bottom.equalToSuperview()
//        }
    //
        let bottomView = UIView()
        bottomView.backgroundColor = .clear
        self.view.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.width.equalTo(200)
            make.height.equalTo(40)
            make.bottom.equalTo(-20)
            make.centerX.equalTo(self.view)
        }
        
        let ppButton = UIButton()
        let str = NSMutableAttributedString(string: "Privacy Policy &")
        let strRange = NSRange.init(location: 0, length: str.length)
        //此处必须转为NSNumber格式传给value，不然会报错
        let number = NSNumber(integerLiteral: NSUnderlineStyle.single.rawValue)
        str.addAttributes([NSAttributedString.Key.underlineStyle: number,
                           NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "#FFFFFF")?.withAlphaComponent(0.8) ?? .white,
                           NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 12)!],
                          range: strRange)
        ppButton.setAttributedTitle(str, for: UIControl.State.normal)
        ppButton.contentHorizontalAlignment = .right
        ppButton.tag = 1001
        ppButton.addTarget(self, action: #selector(buttonClick(button:)), for: .touchUpInside)
        bottomView.addSubview(ppButton)
        ppButton.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(40)
            make.bottom.equalTo(-20)
            make.left.equalTo(0)
        }
        
        let tou = UIButton()
        let toustr = NSMutableAttributedString(string: " Terms of Use")
        let toustrRange = NSRange.init(location: 0, length: toustr.length)
        //此处必须转为NSNumber格式传给value，不然会报错
        let tounumber = NSNumber(integerLiteral: NSUnderlineStyle.single.rawValue)
        toustr.addAttributes([NSAttributedString.Key.underlineStyle: tounumber,
                              NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "#FFFFFF")?.withAlphaComponent(0.8) ?? .white,
                           NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 12)!],
                          range: toustrRange)
        tou.setAttributedTitle(toustr, for: UIControl.State.normal)
        tou.contentHorizontalAlignment = .left
        tou.tag = 1002
        tou.addTarget(self, action: #selector(buttonClick(button:)), for: .touchUpInside)
        bottomView.addSubview(tou)
        tou.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(40)
            make.bottom.equalTo(-20)
            make.right.equalTo(-2)
        }
    }
}

extension APLoginVC: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // 请求完成，但是有错误
    }
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        // 请求完成， 用户通过验证
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // 拿到用户的验证信息，这里可以跟自己服务器所存储的信息进行校验，比如用户名是否存在等。
            //                let detailVC = DetailVC(cred: credential)
            //                self.present(detailVC, animated: true, completion: nil)
            
            print(credential)
            LoginManage.saveAppleUserIDAndUserName(userID: credential.user, userName: credential.email ?? "")
            self.dismiss(animated: true) {
            }
            
        } else {
            
        }
    }
}

extension APLoginVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return (UIApplication.shared.delegate as! AppDelegate).window!
    }
}


extension APLoginVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: APLoginSplashCell.self, for: indexPath)
        
        var iconName: String = ""
        var info: String = ""
        if indexPath.item == 0 {
            iconName = "splash_gift"
            info = "Let's customize the prizes for the lucky draw!"
        } else if indexPath.item == 1 {
            iconName = "splash_phone"
            info = "Number of the gift picker winners!"
        } else if indexPath.item == 2 {
            iconName = "splash_trophy"
            info = "Randomly find the luckiest one!"
        }
        cell.contentImgV.image = UIImage(named: iconName)
        cell.infoLabel.text = info
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
}

extension APLoginVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

extension APLoginVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
    
    
}

extension APLoginVC {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let point = CGPoint(x: collection.bounds.size.width / 2, y: collection.bounds.size.height / 2)
        let cPoint = collection.convert(point, from: self.view)
        let indexPath = collection.indexPathForItem(at: cPoint)
        if indexPath?.item == 0 {
            bgImageView.backgroundColor = UIColor(hexString: "#38E8B1")
        } else if indexPath?.item == 1 {
            bgImageView.backgroundColor = UIColor(hexString: "#C191FF")
        } else if indexPath?.item == 2 {
            bgImageView.backgroundColor = UIColor(hexString: "#FF6A78")
        }
        pageControl.currentPage = indexPath?.item ?? 0
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
    }
}



class APLoginSplashCell: UICollectionViewCell {
    let contentImgV = UIImageView()
    let infoLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        
        
        infoLabel.font = UIFont(name: "ArialRoundedMTBold", size: 24)
        infoLabel.textColor = .white
        infoLabel.numberOfLines = 0
        contentView.addSubview(infoLabel)
        infoLabel.textAlignment = .center
        infoLabel.snp.makeConstraints {
//            $0.top.equalTo(contentImgV.snp.bottom)
            $0.height.equalTo(80)
            $0.bottom.equalToSuperview().offset(-20)
            $0.left.equalTo(20)
            $0.centerX.equalToSuperview()
        }
        //
        contentImgV.contentMode = .scaleAspectFill
        contentImgV.clipsToBounds = false
        contentView.addSubview(contentImgV)
        contentImgV.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.width.equalTo((282.0/328.0) * (size.height * 2/3))
//            $0.height.equalTo(size.height * 2/3)
            $0.bottom.equalTo(infoLabel.snp.top).offset(-30)
            $0.centerX.equalToSuperview()
        }
        //
    }
}
