//
//  SlideViewController.swift
//  PanoMaker
//
//  Created by 薛忱 on 2019/11/7.
//  Copyright © 2019 薛忱. All rights reserved.
//

import UIKit
import Photos
import DeviceKit


class SlideViewController: UIViewController {

    var editView: SlideEditView?
    var toolView: SlideToolView?
    var targetimage: UIImage = UIImage()
    
    var photoNum: Int = 2
    let collectionCellID = "SlideViewController"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        let bgImgV = UIImageView(image: UIImage(named: "home_bg_pic"))
        bgImgV.contentMode = .scaleAspectFill
        view.addSubview(bgImgV)
        bgImgV.snp.makeConstraints {
            $0.top.left.right.bottom.equalToSuperview()
        }
        
        initializerBackButton()
        initialzierSaveImageButton()
        
        self.editView = SlideEditView.init(frame: CGRect(x: 0, y: 100, width: screen_width_int, height: screen_width_int / 18 * 16 + 10), contentImage: targetimage)
        self.editView?.backgroundColor = UIColor.clear
        self.editView?.scrolleView.backgroundColor = .clear
        self.view.addSubview(self.editView!)
         
        //
        let bottomBgView = UIView()
        bottomBgView.backgroundColor = .white
        bottomBgView.frame = CGRect(x: 0, y: 100 + screen_width_CGFloat + 20, width: screen_width_CGFloat, height: screen_hight_CGFloat - 100 - screen_width_CGFloat - 20)
        bottomBgView.corner(byRoundingCorners: [.topLeft, .topRight], radii: 46)
        self.view.addSubview(bottomBgView)
        
        self.toolView = SlideToolView().then({ (tool) in
            tool.backgroundColor = UIColor.color(hexString: "#FFFFFF")
            tool.delegate = self
            bottomBgView.addSubview(tool)
            var height: CGFloat = 170
            if Device.current.diagonal <= 5.5 || Device.current.diagonal >= 7.9 {
                height = 145
            }
            tool.snp.makeConstraints { (make) in
                make.left.right.equalTo(0)
                make.height.equalTo(height)
                make.centerY.equalToSuperview()
            }
        })
        
        self.editView?.changeGuideView(pageNum: 1, proportion: .size1_1)
    }
    
    private func initializerBackButton() {
        var backBtn: UIButton = UIButton(type: .custom)
        view.addSubview(backBtn)
        backBtn.setImage(UIImage(named: "pano_back_ic"), for: .normal)
        backBtn.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.left.equalTo(10)
            $0.width.height.equalTo(44)
        }
        backBtn.addTarget(self, action: #selector(backButtonClick(button:)), for: .touchUpInside)
    }
    
    @objc func backButtonClick(button: UIButton) {
        if self.navigationController == nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController()
        }
    }
    
    private func initialzierSaveImageButton() {
        let saveBtn = UIButton(type: .custom)
        saveBtn.setImage(UIImage(named: "edit_save_ic"), for: .normal)
        view.addSubview(saveBtn)
        saveBtn.addTarget(self, action: #selector(saveImageButtonClick(button:)), for: .touchUpInside)
        saveBtn.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.right.equalTo(-10)
            $0.width.height.equalTo(44)
        }
    }
    
    @objc func saveImageButtonClick(button: UIButton) {
        dPrint(item: button.tag)
        HUD.show()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            [weak self] in
            guard let `self` = self else {return}
            self.saveImage()
        }
        
    }
    
    func saveImage() {
        self.editView?.guideView.isHidden = true
        var resultImage = self.editView?.contentImageView.image ?? UIImage()
        resultImage = resultImage.originImageToScaleSize(size: CGSize(width: resultImage.size.width, height: resultImage.size.height))
        self.editView?.guideView.isHidden = false
        
        let diffrent = resultImage.size.height / ((self.editView?.contentImageView.frame.size.height ?? 0))
        var imageList: [UIImage] = []
        
        for subView in self.editView?.guideView.subviews ?? [] {
            
            let contentOffsetX = (self.editView?.scrolleView.contentOffset.x ?? 1) * diffrent
            let contentOffsetY = (self.editView?.scrolleView.contentOffset.y ?? 1) * diffrent
            
            let rect = CGRect(x: (subView.frame.origin.x * diffrent + contentOffsetX), y: contentOffsetY , width: subView.frame.size.width * diffrent, height: subView.frame.size.height * diffrent)
            let img = UIImage.init(cgImage: ((resultImage.cgImage?.cropping(to: rect))!))
            imageList.append(img)
        }
        saveImgsToAlbum(imgs: imageList)

    }
     
    
}

extension SlideViewController {
    func saveImgsToAlbum(imgs: [UIImage]) {
        HUD.hide()
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            saveToAlbumPhotoAction(images: imgs)
        } else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization({[weak self] (status) in
                guard let `self` = self else {return}
                DispatchQueue.main.async {
                    if status != .authorized {
                        return
                    }
                    self.saveToAlbumPhotoAction(images: imgs)
                }
            })
        } else {
            // 权限提示
            albumPermissionsAlet()
        }
    }
    
    func saveToAlbumPhotoAction(images: [UIImage]) {
        DispatchQueue.main.async(execute: {
            PHPhotoLibrary.shared().performChanges({
                [weak self] in
                guard let `self` = self else {return}
                for img in images {
                    PHAssetChangeRequest.creationRequestForAsset(from: img)
                }
                DispatchQueue.main.async {
                    [weak self] in
                    guard let `self` = self else {return}
                    self.showSaveSuccessAlert()
                }
                
            }) { (finish, error) in
                if error != nil {
                    HUD.error("Sorry! please try again")
                }
            }
        })
    }
    
    func showSaveSuccessAlert() {
        

        DispatchQueue.main.async {
            let title = ""
            let message = "Photo Storage Successful."
            let okText = "OK"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okButton = UIAlertAction(title: okText, style: .cancel, handler: { (alert) in
                 DispatchQueue.main.async {
                 }
            })
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    func albumPermissionsAlet() {
        let alert = UIAlertController(title: "Ooops!", message: "You have declined access to photos, please active it in Settings>Privacy>Photos.", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { [weak self] (actioin) in
            self?.openSystemAppSetting()
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func openSystemAppSetting() {
        let url = NSURL.init(string: UIApplication.openSettingsURLString)
        let canOpen = UIApplication.shared.canOpenURL(url! as URL)
        if canOpen {
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
 
}


extension SlideViewController: SlideToolViewDelegate {
//    func selectProportion(sizeType: TSToolSizeProportionBtn.SizeType) {
//        self.editView?.changeGuideView(pageNum: 0, proportion: sizeType)
//    }
//
//    func selectPagenum(pageNum: Int) {
//        self.editView?.changeGuideView(pageNum: tag, proportion: 0)
//        self.photoNum = tag - 2000 + 2
//    }
//
    func updateSlideEditView(sizeType: TSToolSizeProportionBtn.SizeType, pageNum: Int) {
        self.editView?.changeGuideView(pageNum: pageNum, proportion: sizeType)
    }
}

