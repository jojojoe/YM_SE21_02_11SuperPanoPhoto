//
//  SelectPhotoAlbumViewController.swift
//  PreviewInsta
//
//  Created by 薛忱 on 2019/10/30.
//  Copyright © 2019 薛忱. All rights reserved.
//

import UIKit


protocol SelectPhotoAlbumViewControllerDelegate: class {
    func selectImageArray(imageArray: UIImage)
}

class SelectPhotoAlbumViewController: UIViewController {
    
    var photoAlbum: PhotoAlbumView?
    var backBtn: UIButton = UIButton(type: .custom)
    let saveBtn = UIButton(type: .custom)
    weak var delegate: SelectPhotoAlbumViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bgImgV = UIImageView(image: UIImage(named: "home_bg_pic"))
        bgImgV.contentMode = .scaleAspectFill
        view.addSubview(bgImgV)
        bgImgV.snp.makeConstraints {
            $0.top.left.right.bottom.equalToSuperview()
        }
        
        
        //
        self.view.backgroundColor = .white
        initialzierBackButton()
        initialzierSaveImageButton()
        self.photoAlbum = PhotoAlbumView().then({ (photoView) in
            photoView.backgroundColor = UIColor.color(hexString: "#FFFFFF")
            photoView.collectionView?.backgroundColor = UIColor.color(hexString: "#FFFFFF")
            self.view.addSubview(photoView)
            photoView.snp.makeConstraints {
                $0.top.equalTo(backBtn.snp.bottom)
                $0.left.right.equalTo(0)
                $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            }
            
        })
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0) {
            GetSystemPermissions.getPhotoPermissions {[weak self] (agree) in
                if agree {
                    self?.photoAlbum?.startAllPhoto()
                } else {
                    self?.permissionsAlet()
                }
            }
        }
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func initialzierSaveImageButton() {
        
        
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
        HUD.show("Retrieving Data")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.photoAlbum?.getAssetImage(block: {[weak self] (arrayImage) in
                DispatchQueue.main.async {
                    HUD.hide()
                    if arrayImage.count > 0 {
                        
                        let resultImage = arrayImage[0]
                        if resultImage.size.width > 0 && resultImage.size.height > 0 {
                            
                            self?.jumpToViewController(image: resultImage)

                        } else {
                            
                            HUD.error("Oops, something wrong. Please select other photos.")
                        }
                    } else {
                        
                        HUD.error("Please choose a Panorama photo to continue.")
                    }
                }
            })
        }
        
        
    }
    
    func jumpToViewController(image: UIImage) {
        
        DispatchQueue.main.async {
            
            let selectVideoOrImageVC = SelectToVideoOrImageViewController(previewImg: image)
            
            self.pushVC(selectVideoOrImageVC, animate: true)
             
        }
    }
    
    func initialzierBackButton() {
        
        view.addSubview(backBtn)
        backBtn.setImage(UIImage(named: "pano_back_ic"), for: .normal)
        backBtn.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.left.equalTo(10)
            $0.width.height.equalTo(44)
        }
        backBtn.addTarget(self, action: #selector(backBtnClick(sender:)), for: .touchUpInside)
        
        

    }
    @objc func backBtnClick(sender: UIButton) {
        if self.navigationController == nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController()
        }
    }
    
    func permissionsAlet() {
        let alert = UIAlertController(title: "", message: "You have declined access to photo, please active it in Settings>Privacy>Photo.", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { [weak self] (actioin) in
            self?.openSettingPage()
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func openSettingPage() {
        let url = NSURL.init(string: UIApplication.openSettingsURLString)
        let canOpen = UIApplication.shared.canOpenURL(url! as URL)
        if canOpen {
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
     

}
