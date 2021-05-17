//
//  VideoViewController.swift
//  PanoMaker
//
//  Created by 薛忱 on 2019/11/8.
//  Copyright © 2019 薛忱. All rights reserved.
//

import UIKit

import Photos



class VideoViewController: UIViewController {
    
    let toolView = VideoToolView.init()
    var editView: VideoEditView?
    let imageToVideo = GPImageToVideoConverter.sharedInstance()
    var movieFile: GPUImageMovie?
    var displayFilter: GPUImageDisplayFilter?
    var writer: GPUImageMovieWriter?
    var targetimage: UIImage?
    var finisheToVideo: Bool? = false
    
    let collectionCellID = "VideoViewController"
    
    var filtersImage: [UIImage] = []
    var selectIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        let bgImgV = UIImageView(image: UIImage(named: "home_bg_pic"))
        bgImgV.contentMode = .scaleAspectFill
        view.addSubview(bgImgV)
        bgImgV.snp.makeConstraints {
            $0.top.left.right.bottom.equalToSuperview()
        }
        //
        NotificationCenter.default.addObserver(self, selector: #selector(inBackground), name: NSNotification.Name(rawValue:"inbackground"), object: nil)
        
        initializerBackButton()
        initialzierSaveImageButton()
        self.editView = VideoEditView.init(frame: CGRect(x: 0, y: 100, width: screen_width_int, height: screen_width_int), contentImage: targetimage ?? UIImage())
        self.editView?.delegate = self
        self.view.addSubview(editView ?? UIView())
        
         
        //
        let bottomBgView = UIView()
        bottomBgView.backgroundColor = .white
        bottomBgView.frame = CGRect(x: 0, y: 100 + screen_width_CGFloat + 20, width: screen_width_CGFloat, height: screen_hight_CGFloat - 100 - screen_width_CGFloat - 20)
        bottomBgView.corner(byRoundingCorners: [.topLeft, .topRight], radii: 46)
        self.view.addSubview(bottomBgView)
        //
        _ = toolView.then({ (tool) in
            tool.backgroundColor = UIColor.color(hexString: "#FFFFFF")
            tool.thumbnailImageView.image = targetimage
            tool.delegate = self
            bottomBgView.addSubview(tool)
            
            tool.snp.makeConstraints { (make) in
                make.left.right.equalTo(0)
                make.height.equalTo(170)
                make.centerY.equalToSuperview()
            }
        })
        
        
    }
    
    @objc func inBackground() {
        
        if finisheToVideo! {
            self.finisheToVideo = false
            self.imageToVideo.operation.cancel()
            self.writer?.cancelRecording()
            self.movieFile?.cancelProcessing()
//            SVProgressHUD.dismiss()
            HUD.hide()
            
            let title = ""
            let message = "Save process is interrupted, please try again."
            let okText = "OK"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okButton = UIAlertAction(title: okText, style: .cancel, handler: { (alert) in
                self.finisheToVideo = false
            })
            alert.addAction(okButton)
            
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
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
        
        let costheight: CGFloat = screen_hight_CGFloat - 100 - screen_width_CGFloat - 20
        
        let costframe = CGRect(x: 0, y: 100 + screen_width_CGFloat + 20, width: screen_width_CGFloat, height: costheight)
        let costView = CoinsView(frame: costframe, viewHeight: costheight)
        self.view.addSubview(costView)
        costView.backgroundColor = .clear
        costView.okButtonClick = {
            DispatchQueue.main.async {
                
                if CoinManager.default.coinCount >= CoinManager.default.coinCostCount {
                    CoinManager.default.costCoin(coin: CoinManager.default.coinCostCount)
                    self.startSaveVideo()
                } else {
                    DispatchQueue.main.async {
                        [weak self] in
                        guard let `self` = self else {return}
                        
                        self.showCoinNotEnoughAlert()
                    }
                }
                
            }
        }
    }
    
    func showCoinNotEnoughAlert() {
        
        showAlert(title: "", message: "Coins shortage. please buy coins first.", buttonTitles: ["Ok"], highlightedButtonIndex: 0) { (index) in
            
        }
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
        backBtn.addTarget(self, action: #selector(backBtnClick(sender:)), for: .touchUpInside)
        
        
    }
    @objc func backBtnClick(sender: UIButton) {
        if self.navigationController == nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController()
        }
    }
   
    func saveImageToSandbox(image: UIImage) -> String {
        let path = NSHomeDirectory()
        let pathimg = path + "/Documents/111.png"
        
        do {
            try image.pngData()?.write(to: URL.init(fileURLWithPath: pathimg))
        } catch {
            dPrint(item: "line -- ERROR")
            return ""
        }
        
        
        return pathimg
    }
    
    func startSaveVideo() {
        self.finisheToVideo = true
        HUD.show("Please do not exit or close while video saving.")
         
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            //            let urlStr = self.saveImageToSandbox(image: self.editView!.contentImageView.image ?? UIImage())
            //            var result = UIImage.init(contentsOfFile: urlStr)
            var result = self.editView!.contentImageView.image
            if isIpad {
                result = result!.originImageToScaleSize(size: CGSize(width: (self.editView?.contentImageView.frame.size.width ?? 1), height: (self.editView?.contentImageView.frame.size.height ?? 1)))
            } else {
                result = result!.originImageToScaleSize(size: CGSize(width: (self.editView?.contentImageView.frame.size.width ?? 1) * 2, height: (self.editView?.contentImageView.frame.size.height ?? 1) * 2))
            }
            
            self.imageToVideo.convert(result!, toVideoProgressCallback: { (progress) in
                dPrint(item: progress)
            }) { (videoPath, error) in
                
                DispatchQueue.main.async {
                    
                    dPrint(item: videoPath)
                    if videoPath.count > 0 {
                        
                        let isHorizontal = self.editView?.isHorizontal  ?? false
                        if !isHorizontal {
                            self.saveVideoToAlbum(videoUrl:URL.init(fileURLWithPath: videoPath))
                            return
                        }
                        
                        self.movieFile = GPUImageMovie.init(url: URL.init(fileURLWithPath: videoPath))
                        self.movieFile?.playAtActualSpeed = false
                        self.movieFile?.runBenchmark = false
                        
                        let imageSize = GPImageToVideoConverter.sharedInstance().originVideoSize()
                        var outputSizeWidth = 0
                        var outputSizeHeight = 0
                        
                        switch self.editView?.proporIndex {
                        case 1:
                            outputSizeWidth = screen_width_int + (4 - (screen_width_int % 4))
                            outputSizeHeight = screen_width_int + (4 - (screen_width_int % 4))
                            break
                            
                        case 2:
                            outputSizeWidth = screen_width_int + (4 - (screen_width_int % 4))
                            let height = outputSizeWidth / 4 * 5
                            outputSizeHeight = height + (4 - (height % 4))
                            break
                            
                        case 3:
                            outputSizeWidth = screen_width_int + (4 - (screen_width_int % 4))
                            let height = outputSizeWidth / 9 * 16
                            outputSizeHeight = height + (4 - (height % 4))
                            break
                            
                        default:
                            break
                        }
                        
                        
                        let outputSize = CGSize(width: outputSizeWidth, height: outputSizeHeight)
                        
                        self.displayFilter = GPUImageDisplayFilter.init()
                        self.displayFilter?.canvasSize = outputSize
                        self.displayFilter?.imageSize = imageSize
                        self.displayFilter?.totalFrames = 30 * 10
                        
                        let videoSettings = [AVVideoCodecKey : AVVideoCodecType.h264, AVVideoWidthKey : outputSize.width, AVVideoHeightKey : outputSize.height] as [String : Any]
                        self.writer = GPUImageMovieWriter.init(movieURL: PNVideoWriter.outputUrl(), size: outputSize, fileType: AVFileType.mp4.rawValue, outputSettings: videoSettings)
                        
                        self.movieFile?.enableSynchronizedEncoding(using: self.writer)
                        self.movieFile?.addTarget(self.displayFilter)
                        self.displayFilter?.addTarget(self.writer)
                        
                        unlink(PNVideoWriter.outputUrl().path)
                        self.writer?.startRecording()
                        self.movieFile?.startProcessing()
                        self.writer?.completionBlock = {
                            self.writer?.finishRecording(completionHandler: {
                                self.saveVideoToAlbum(videoUrl: PNVideoWriter.outputUrl())
                            })
                        }
                    }
                }
            }
        }
    }
    
    func saveVideoToAlbum(videoUrl: URL) {
        
        DispatchQueue.main.async {
            self.displayFilter?.removeTarget(self.writer)
            self.movieFile?.removeTarget(self.displayFilter)
            self.movieFile = nil
            self.displayFilter = nil
            self.writer = nil
            
            let status = PHPhotoLibrary.authorizationStatus()
            if status == PHAuthorizationStatus.authorized {
                self.finishedSaveVideo(videoUrl: videoUrl)
            } else if (status == PHAuthorizationStatus.restricted || status == PHAuthorizationStatus.denied) {
                HUD.hide()
                self.albumPermissionsAlet()
            } else {
                PHPhotoLibrary.requestAuthorization { [weak self] (status) in
                    if status == PHAuthorizationStatus.authorized {
                        self?.finishedSaveVideo(videoUrl: videoUrl)
                    }
                }
            }
        }
    }
    
    func finishedSaveVideo(videoUrl: URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoUrl)
        }) { (isSuccess: Bool, error: Error?) in
            self.finisheToVideo = false
            if isSuccess {
             
                
                DispatchQueue.main.async {
//                    SVProgressHUD.dismiss()
                    HUD.hide()
    //                MyInfo.costIcon(icon: costCoinsNum)
                    let title = ""
                    let message = "The Video Saved Successfully"
                    let okText = "OK"
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    let okButton = UIAlertAction(title: okText, style: .cancel, handler: { (alert) in
                        DispatchQueue.main.async {
                        }
                    })
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                let title = ""
                let message = "Save failed, please try it again."
                let okText = "OK"
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let okButton = UIAlertAction(title: okText, style: .cancel, handler: { (alert) in
                })
                alert.addAction(okButton)
                
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
}


extension VideoViewController: VideoToolViewDelegate, VideoEditViewDelegate {
    func startAnimation() {
        self.toolView.startAnimation()
    }
    
    func pauseAnimation() {
        self.toolView.pauseAnimation()
    }
    
    func selectProportion(sizeType: TSToolSizeProportionBtn.SizeType) {
        
        switch sizeType {
        case .size1_1:
            self.editView?.proporIndex = 1
            UIView.animate(withDuration: 0.2) {
                self.editView?.frame = CGRect(x: 0, y: 100, width: screen_width_int, height: screen_width_int)
                self.editView?.updateUI()
            }
            break
            
        case .size4_5:
            let width = (screen_width_int / 5 * 4)
            self.editView?.proporIndex = 2
            UIView.animate(withDuration: 0.2) {
                self.editView?.frame = CGRect(x: (screen_width_int - width) / 2, y: 100, width: width, height: screen_width_int)
                self.editView?.updateUI()
            }
            break
            
        case .size9_16:
            let width = (screen_width_int / 16 * 9)
            self.editView?.proporIndex = 3
            UIView.animate(withDuration: 0.2) {
                self.editView?.frame = CGRect(x: (screen_width_int - width) / 2, y: 100, width: width, height: screen_width_int)
                self.editView?.updateUI()
            }
            break
            
        default:
            break
        }
        
        
    }
}


