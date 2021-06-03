//
//  SSPPhotoMultiSlideEditVC.swift
//  SPPymSuperPanoPhoto
//
//  Created by JOJO on 2021/5/12.
//

import UIKit
import Photos
import DeviceKit

class SSPPhotoMultiSlideEditVC: UIViewController {
    var backBtn = UIButton(type: .custom)
    var contentImgs: [UIImage] = []
    var contentImgsFiltered: [UIImage] = []
    var mobanList: [String] = []
    var photoCanvasView: PhotoMultiCanvasView?
    var slideHorVerCanvasView: SSPSlideHorVerCanvasView?
    
    var isTemplate: Bool = true
    var isPro: Bool = false
    
    
    
    init(images: [UIImage]) {
        contentImgs = images
        contentImgsFiltered = images
        super.init(nibName: nil, bundle: nil)
        if images.count == 1 {
            mobanList = DataManager.default.slideMoban1List
        } else if images.count == 2 {
            mobanList = DataManager.default.slideMoban2List
        } else if images.count == 3 {
            mobanList = DataManager.default.slideMoban3List
        } else if images.count == 4 {
            mobanList = DataManager.default.slideMoban4List
        } else if images.count == 5 {
            mobanList = DataManager.default.slideMoban5List
        } else if images.count == 6 {
            mobanList = DataManager.default.slideMoban6List
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupContentView()
    }
    

    

}

extension SSPPhotoMultiSlideEditVC {
    func setupView() {
        let bgImgV = UIImageView(image: UIImage(named: "home_bg_pic"))
        bgImgV.contentMode = .scaleAspectFill
        view.addSubview(bgImgV)
        bgImgV.snp.makeConstraints {
            $0.top.left.right.bottom.equalToSuperview()
        }
        //
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
        //
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
    
    func setupContentView() {
        //
        var topOff: CGFloat = 100
        
            
        var canvasWidth: CGFloat = UIScreen.main.bounds.width
        if Device.current.diagonal <= 5.5 || Device.current.diagonal >= 7.5 {
            canvasWidth = 280
            topOff = 65
        }
        let leftOff: CGFloat = (UIScreen.main.bounds.width - canvasWidth) / 2
        
        
        let photoCanvasView = PhotoMultiCanvasView(frame: CGRect(x: leftOff, y: topOff, width: canvasWidth, height: canvasWidth), mobanName: mobanList.first ?? "moban1_1", images: contentImgs)
        photoCanvasView.clipsToBounds = true
        self.photoCanvasView = photoCanvasView
        view.addSubview(photoCanvasView)
        
        //
        let slideHorVerCanvasView = SSPSlideHorVerCanvasView(frame: CGRect(x: leftOff, y: topOff, width: canvasWidth, height: canvasWidth), images: contentImgs)
        self.slideHorVerCanvasView = slideHorVerCanvasView
        view.addSubview(slideHorVerCanvasView)
        
        //
        
        let height = screen_hight_CGFloat - (topOff + canvasWidth + 10)
        let bottomFrame = CGRect(x: 0, y: topOff + canvasWidth + 10, width: screen_width_CGFloat, height: height)
        let bottomToolBar = SSPMultiSlideToolView(frame: bottomFrame, viewHeight: height, mobanList: mobanList)
        view.addSubview(bottomToolBar)
        bottomToolBar.filterClickBlock = {
            [weak self] filterType in
            guard let `self` = self else {return}
            DispatchQueue.main.async {
                var filteredImgs: [UIImage] = []
                
                for img in self.contentImgs {
                    let imgProcess = SSPFilterManager.default.processImage(image: img, filter: filterType)
                    filteredImgs.append(imgProcess)
                }
                self.contentImgsFiltered = filteredImgs
                if self.photoCanvasView?.isHidden == false {
                    
                } else {
                    
                }
                self.photoCanvasView?.updateFilter(filteredImgs: filteredImgs)
                self.slideHorVerCanvasView?.updateContentFilteredImgs(imgs: filteredImgs)
            }
        }
        bottomToolBar.mobanClickBlock = {
            [weak self] moban, isPro in
            guard let `self` = self else {return}
            DispatchQueue.main.async {
                self.isPro = isPro
                self.photoCanvasView?.updateMoban(moban: "\(moban).svg", imgs: self.contentImgsFiltered)
                self.isTemplate = true
                
                self.photoCanvasView?.isHidden = false
                self.slideHorVerCanvasView?.isHidden = true
            }
            
        }
        bottomToolBar.bottomActionClick = {
            [weak self] type in
            guard let `self` = self else {return}
         
            
        }
        bottomToolBar.slideHorBtnClickBlock = {
            [weak self] in
            guard let `self` = self else {return}
            self.isTemplate = false
            self.photoCanvasView?.isHidden = true
            self.slideHorVerCanvasView?.isHidden = false
            self.slideHorVerCanvasView?.updateSlideType(slide: .hor, imgs: self.contentImgsFiltered)
        }
        bottomToolBar.slideVerBtnClickBlock = {
            [weak self] in
            guard let `self` = self else {return}
            self.isTemplate = false
            self.photoCanvasView?.isHidden = true
            self.slideHorVerCanvasView?.isHidden = false
            self.slideHorVerCanvasView?.updateSlideType(slide: .ver, imgs: self.contentImgsFiltered)
        }
        
    }
    
    
    
    
    
}

extension SSPPhotoMultiSlideEditVC {
    func saveTemplate() {

        if let img = photoCanvasView?.screenshot {
            if isPro == true {
//                let costheight: CGFloat = screen_hight_CGFloat - 100 - screen_width_CGFloat - 20
//                let costframe = CGRect(x: 0, y: 100 + screen_width_CGFloat + 20, width: screen_width_CGFloat, height: costheight)
                
                var costheight: CGFloat = screen_hight_CGFloat - 100 - screen_width_CGFloat - 20
                
                if Device.current.diagonal <= 5.5 || Device.current.diagonal >= 7.9 {
                    costheight = 312
                }
                let costframe = CGRect(x: 0, y: screen_hight_CGFloat - costheight, width: screen_width_CGFloat, height: costheight)
                
                let costView = CoinsView(frame: costframe, viewHeight: costheight)
                self.view.addSubview(costView)
                costView.backgroundColor = .clear
                costView.okButtonClick = {
                    DispatchQueue.main.async {
                        [weak self] in
                        guard let `self` = self else {return}
                        if CoinManager.default.coinCount >= CoinManager.default.coinCostCount {
                            CoinManager.default.costCoin(coin: CoinManager.default.coinCostCount)
                            self.saveImgsToAlbum(imgs: [img])
                        } else {
                            DispatchQueue.main.async {
                                [weak self] in
                                guard let `self` = self else {return}
                                
                                self.showCoinNotEnoughAlert()
                            }
                        }
                        
                    }
                }
            } else {
                saveImgsToAlbum(imgs: [img])
            }
            
        }
    }
    
    func saveSlide() {
        if let scrollView = self.slideHorVerCanvasView?.scrollBgView, let imageViews = self.slideHorVerCanvasView?.contentImageViews {
            let saveBgView = UIView()
            saveBgView.backgroundColor = .white
            saveBgView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
            
            for imgV in imageViews {
                let saveImgV = UIImageView(image: imgV.image)
                saveBgView.addSubview(saveImgV)
                saveImgV.frame = imgV.frame
            }
            if let savgImg = saveBgView.screenshot {
                saveImgsToAlbum(imgs: [savgImg])
            }
        }

    }
}

extension SSPPhotoMultiSlideEditVC {
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
    func showCoinNotEnoughAlert() {
        
        showAlert(title: "", message: "Coins shortage. please buy coins first.", buttonTitles: ["Ok"], highlightedButtonIndex: 0) { (index) in
            DispatchQueue.main.async {
                [weak self] in
                guard let `self` = self else {return}
                self.navigationController?.pushViewController(SPPymStoreVC())
            }
        }
    }
}


extension SSPPhotoMultiSlideEditVC {
    @objc func makeBtnBackClick(sender: UIButton) {
        if self.navigationController != nil {
            self.navigationController?.popViewController()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func saveImageButtonClick(button: UIButton) {
        if isTemplate == true {
            saveTemplate()
        } else {
            saveSlide()
        }
    }
    
}




