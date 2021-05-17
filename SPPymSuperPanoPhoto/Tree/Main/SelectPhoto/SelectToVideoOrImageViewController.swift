//
//  SelectToVideoOrImageViewController.swift
//  PanoMaker
//
//  Created by 薛忱 on 2019/11/6.
//  Copyright © 2019 薛忱. All rights reserved.
//

import UIKit

class SelectToVideoOrImageViewController: UIViewController {

    let mainImageBgScrollView = UIScrollView()
    let mainImageView = UIImageView()
    var backBtn: UIButton = UIButton(type: .custom)
    
    var previewImg: UIImage
    
    init(previewImg: UIImage) {
        self.previewImg = previewImg
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        view.addSubview(mainImageBgScrollView)
        mainImageBgScrollView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.centerY).offset(0)
            $0.height.equalTo(200)
        }
        
        _ = mainImageView.then({ (imageView) in
            imageView.contentMode = .scaleAspectFill
            imageView.layer.masksToBounds = true
            mainImageBgScrollView.addSubview(imageView)
            
            mainImageView.image = previewImg
            let height: CGFloat = 200
            let width: CGFloat = height * (previewImg.size.width / previewImg.size.height)
            imageView.snp.makeConstraints {
                $0.left.right.top.bottom.equalToSuperview()
                $0.width.equalTo(width)
                $0.height.equalTo(height)
            }
          
        })
        //
        let bottomView = UIView()
        bottomView.backgroundColor = .clear
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.top.equalTo(mainImageView.snp.bottom)
            $0.width.equalTo(1)
        }
        
        //
        let videoBgBtn = UIButton(type: .custom)
        view.addSubview(videoBgBtn)
        videoBgBtn.backgroundColor = .white
        videoBgBtn.layer.cornerRadius = 32
        videoBgBtn.snp.makeConstraints {
            $0.right.equalTo(view.snp.centerX).offset(-12)
            $0.centerY.equalTo(bottomView)
            $0.width.height.equalTo(110)
        }
        videoBgBtn.addTarget(self, action: #selector(videoPanoBtnClick(sender:)), for: .touchUpInside)
        
        let videoImage = UIImageView().then { (imageView) in
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(named: "pano_video_ic")
            self.view.addSubview(imageView)
            imageView.snp.makeConstraints {
                $0.width.equalTo(58/2)
                $0.height.equalTo(48/2)
                $0.centerX.equalTo(videoBgBtn)
                $0.bottom.equalTo(videoBgBtn.snp.centerY)
            }
             
        }
        
        let proImageView = UIImageView()
        proImageView.image = UIImage(named: "pic_pro_ic")
        self.view.addSubview(proImageView)
        proImageView.snp.makeConstraints { (make) in
            make.width.equalTo(22)
            make.height.equalTo(22)
            make.top.equalTo(videoBgBtn)
            make.right.equalTo(videoBgBtn)
        }
        
        let videoTitle = UILabel().then { (label) in
            label.text = "Video"
            label.textAlignment = .center
            
            label.textColor = UIColor.black.withAlphaComponent(0.5)
            label.font = UIFont(name: "Alstoria-Regular", size: 18)
            self.view.addSubview(label)
            label.snp.makeConstraints {
                $0.height.equalTo(18)
                $0.top.equalTo(videoImage.snp.bottom).offset(7)
                $0.centerX.equalTo(videoImage.snp.centerX)
                $0.width.greaterThanOrEqualTo(1)
            }
            
        }
        
        //
        let slideBgBtn = UIButton(type: .custom)
        view.addSubview(slideBgBtn)
        slideBgBtn.backgroundColor = .white
        slideBgBtn.layer.cornerRadius = 32
        slideBgBtn.snp.makeConstraints {
            $0.left.equalTo(view.snp.centerX).offset(12)
            $0.centerY.equalTo(bottomView)
            $0.width.height.equalTo(110)
        }
        slideBgBtn.addTarget(self, action: #selector(slideBgBtnBtnClick(sender:)), for: .touchUpInside)
        //
        let slideImage = UIImageView().then { (imageView) in
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(named: "pano_slide_ic")
            self.view.addSubview(imageView)
            imageView.snp.makeConstraints {
                $0.width.equalTo(48/2)
                $0.height.equalTo(46/2)
                $0.centerX.equalTo(slideBgBtn)
                $0.bottom.equalTo(slideBgBtn.snp.centerY)
            }
            
        }
        
        let slideTitle = UILabel().then { (label) in
            label.text = "Slide"
            label.textAlignment = .center
            
            label.textColor = UIColor.black.withAlphaComponent(0.5)
            label.font = UIFont(name: "Alstoria-Regular", size: 18)
            self.view.addSubview(label)
            label.snp.makeConstraints {
                $0.height.equalTo(18)
                $0.top.equalTo(videoImage.snp.bottom).offset(7)
                $0.centerX.equalTo(slideImage.snp.centerX)
                $0.width.greaterThanOrEqualTo(1)
            }
             
        }
        
    }
    
    private func initializerBackButton() {
        view.addSubview(backBtn)
        backBtn.setImage(UIImage(named: "pano_back_ic"), for: .normal)
        backBtn.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.left.equalTo(10)
            $0.width.height.equalTo(44)
        }
        backBtn.addTarget(self, action: #selector(backBtnClick(sender:)), for: .touchUpInside)
        //
        let topTitleLabel = UILabel()
        topTitleLabel.font = UIFont(name: "Alstoria-Regular", size: 18)
        topTitleLabel.text = "Super Pano"
        topTitleLabel.textColor = .white
        view.addSubview(topTitleLabel)
        topTitleLabel.snp.makeConstraints {
            $0.centerY.equalTo(backBtn)
            $0.centerX.equalToSuperview()
            $0.width.greaterThanOrEqualTo(1)
            $0.height.greaterThanOrEqualTo(1)
        }
        //
        
    }
    
    @objc func backBtnClick(sender: UIButton) {
        if self.navigationController == nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController()
        }
    }
    
    @objc func videoPanoBtnClick(sender: UIButton) {
        let videoVC = VideoViewController()
        videoVC.targetimage = self.mainImageView.image
        self.navigationController?.pushViewController(videoVC, animated: true)

    }
    @objc func slideBgBtnBtnClick(sender: UIButton) {
        let slideVC = SlideViewController()
        slideVC.targetimage = self.mainImageView.image ?? UIImage()
        self.navigationController?.pushViewController(slideVC, animated: true)

    }
    
 
  
    
}
