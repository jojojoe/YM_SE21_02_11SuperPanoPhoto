//
//  PhotoAlbumView.swift
//  BlukEdit
//
//  Created by 薛忱 on 2019/8/26.
//  Copyright © 2019 薛忱. All rights reserved.
//

import UIKit
import Photos
import ZKProgressHUD
import Then

class PhotoAlbumView: UIView {

    typealias getImageCallBack = (_ imageArray : Array<UIImage>) -> Void
    
    var assetArray: [PHAsset]?
    var assetImageThumbnail: [UIImage]?
    var collectionView: UICollectionView?
    var photoAlbumCollectionArray: Array<PHAssetCollection>?
    var photoAlbumCollectionTitleArray: Array<String>?
    let collectionCellID = "PhotoAlbumCollectionViewCell"
//    let imageWidth = (screen_width_int - 8) / 3
    let imageHeight = (UIScreen.main.bounds.width - 8) / 3
    let imageWidth = UIScreen.main.bounds.width - 4
    var selectAssetCollectionIndex = 0
    var assetCollectionTitle: UILabel = UILabel()
    var dropDownView: PhotoAlbumDropDownView?
    var selectPHAsset: Array<PHAsset>?
    let default_image = UIImage(named: "buzhidaoqigeshenmemingzi")
    var selectPHAssetNumber: Array<Int>?
    var callBack: getImageCallBack?
    let selectMaxPhotoNum = 1
    var noHaveImage = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.selectPHAsset = Array.init()
        self.selectPHAssetNumber = Array.init()
        let decorateView = UIView().then { (decorate) in
            decorate.backgroundColor = .white
            self.addSubview(decorate)
            decorate.snp.makeConstraints {
                $0.left.right.top.equalTo(0)
                $0.height.equalTo(34)
            }
           
        }
        
        self.assetCollectionTitle = UILabel().then({ (label) in
            label.text = ""
            label.textAlignment = .center
            label.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
            decorateView.addSubview(label)
            label.snp.makeConstraints {
                $0.centerX.equalTo(decorateView)
                $0.top.bottom.equalToSuperview()
            }
             
        })
        
        _ = UIButton().then({ (button) in
            button.backgroundColor = UIColor.clear
            button.addTarget(self, action: #selector(changPhotoCollectionClick(button:)), for: .touchUpInside)
            decorateView.addSubview(button)
            button.snp.makeConstraints {
                $0.width.equalTo(50)
                $0.top.bottom.equalTo(0)
                $0.centerX.equalTo(decorateView)
            }
            
        })
        
        // colleciton view
        initializerCollectionView()
        
        
        //drop Down View
        self.dropDownView = PhotoAlbumDropDownView.init(frame: CGRect.zero, dataSouce: self.photoAlbumCollectionTitleArray ?? [])
        self.dropDownView?.backgroundColor = .white

        self.dropDownView?.layer.borderColor = UIColor(hexString: "#000000")?.withAlphaComponent(0.3).cgColor
        self.dropDownView?.layer.borderWidth = 1.0
        self.dropDownView?.delegate = self
        self.addSubview(self.dropDownView ?? UIView())
        self.dropDownView?.snp.makeConstraints({
            $0.width.equalTo(120)
            $0.centerX.equalTo(self.assetCollectionTitle)
            $0.top.equalTo(self.assetCollectionTitle.snp.bottom)
            $0.height.equalTo(0)
            
        })
         
    }
    
    @objc func changPhotoCollectionClick(button: UIButton) {
        
//        if self.dropDownView?.isShow ?? true {
//            packUpDropDown()
//        } else {
//            showDropDown()
//        }
    }
    
    // 下拉列表收起
    private func packUpDropDown() {
        UIView.animate(withDuration: 0.3) {
            self.dropDownView?.snp.updateConstraints({
                $0.height.equalTo(0)
            })
            
            self.dropDownView?.superview?.layoutIfNeeded()
            self.dropDownView?.isShow = false
        }
    }
    
    // 下拉列表展示
    private func showDropDown() {
        UIView.animate(withDuration: 0.3) {
            self.dropDownView?.snp.updateConstraints({
                $0.height.equalTo(160)
            })
            
            self.dropDownView?.superview?.layoutIfNeeded()
            self.dropDownView?.isShow = true
        }
    }
    
    private func initializerCollectionView() {
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: imageWidth, height: imageHeight)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout).then({ (myCollection) in
            myCollection.backgroundColor = .white
            myCollection.delegate = self
            myCollection.dataSource = self
            myCollection.showsVerticalScrollIndicator = false
            myCollection.showsHorizontalScrollIndicator = false
            myCollection.register(PhotoAlbumCollectionViewCell.self, forCellWithReuseIdentifier: collectionCellID)
            self.addSubview(myCollection)
            myCollection.snp.makeConstraints {
                $0.left.top.bottom.right.equalToSuperview()
            }
        })
        
    }
    
    //开始处理图片显示
    func startAllPhoto() {
        debugPrint("y1s1: startAllPhoto()")
        
        if AppDelegate.hasLoadPanoPhotoAsset == false {
            HUD.show(nil)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                HUD.hide()
            }
        }
        DispatchQueue.global().async {
            [weak self] in
            guard let `self` = self else {return}
            self.getPhotoAlbum()
            AppDelegate.hasLoadPanoPhotoAsset = true
        }
    }
    
    // 选择相册后刷新
    func reloadPhotoForPhotoCollection() {
        debugPrint("y1s1: reloadPhotoForPhotoCollection()")
        selectAssetCollection()
        self.dropDownView?.dataArray = self.photoAlbumCollectionTitleArray
        self.dropDownView?.tableView?.reloadData()
        
    }
    
    // get all albumCollection and albumCollection title
    private func getPhotoAlbum() {
        self.photoAlbumCollectionArray = Array.init()
        self.photoAlbumCollectionTitleArray = Array.init()
        
        let sysfetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumPanoramas, options: nil)

        sysfetchResult.enumerateObjects { (assetCollection, Index, stop) in
 
            self.photoAlbumCollectionArray?.append(assetCollection)
            self.photoAlbumCollectionTitleArray?.append(assetCollection.localizedTitle ?? "Not Name")
        }
        DispatchQueue.main.async {
            [weak self] in
            guard let `self` = self else {return}
            self.reloadPhotoForPhotoCollection()
        }
        
    }
    
    //展示已经选择的相册下的照片
    private func selectAssetCollection() {
        self.assetCollectionTitle.text = self.photoAlbumCollectionTitleArray?[self.selectAssetCollectionIndex]
        self.getAssetCollectionThumbnailImage(assetCollection: self.photoAlbumCollectionArray?[self.selectAssetCollectionIndex] ?? PHAssetCollection.init())
    }
    
    // get all asset
    private func getAllPhoto() -> Array<PHAsset> {
        let options = PHFetchOptions.init()
        options.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: true)]
        options.predicate = NSPredicate.init(format: "mediaType == %ld OR mediaType == %ld", PHAssetMediaType.video.rawValue, PHAssetMediaType.image.rawValue)
        let assetsFetchResults = PHAsset.fetchAssets(with: options)
        
        var arrayAsset: [PHAsset] = Array.init()
        
        assetsFetchResults.enumerateObjects { (asset, index, stop) in
            arrayAsset.append(asset)
        }
        self.assetArray = arrayAsset
        return self.assetArray ?? []
    }
    
    // 获取某个相册下所有asset
    private func getAssetCollectionPhoto(assetCollection: PHAssetCollection) -> Array<PHAsset> {
        let options = PHFetchOptions.init()
        options.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: true)]
//        options.predicate = NSPredicate.init(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        
        let assetFetchResult = PHAsset.fetchAssets(in: assetCollection, options: options)
        self.assetArray = Array.init()
        
        assetFetchResult.enumerateObjects { (asset, index, stop) in
            
            // 过滤竖图
            let phAsset = asset as PHAsset
            if phAsset.pixelWidth > phAsset.pixelHeight {
                self.assetArray?.append(asset)
            }
        }
        
        self.assetImageThumbnail = [UIImage](repeating: UIImage(), count: self.assetArray?.count ?? 0)
        return self.assetArray ?? []
    }
    
    // 获取所有的 缩略图
    private func getAllAssetThumbnailImage() {
        for asset in self.getAllPhoto() {
            self.getAssetThumbnail(asset: asset)
        }
    }
    
    // 获取某个相册下的 缩略图
    private func getAssetCollectionThumbnailImage(assetCollection: PHAssetCollection) {
        
        // 每次遍历前 都要清空 缩略图数组
        self.assetArray = Array.init()
        self.assetImageThumbnail = Array.init()
        self.getAssetCollectionPhoto(assetCollection: assetCollection)
        
        if self.assetArray?.count == 0 {
            self.noHaveImage = true
        } else {
            self.noHaveImage = false
        }
        
        self.collectionView?.reloadData()
 
    }
    
    // 获取缩略图
    private func getAssetThumbnail(asset: PHAsset) {
        
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = false
        option.deliveryMode = .opportunistic
        option.resizeMode = .fast
        option.isNetworkAccessAllowed = true
        
        let imageWidth = (UIScreen.main.bounds.width - 35) / 4
        let scale = CGFloat(UIScreen.main.scale)
        DispatchQueue.global().async {
            manager.requestImage(for: asset,
                                 targetSize: CGSize(width: CGFloat(imageWidth) * scale, height: CGFloat(imageWidth) * scale),
                                 contentMode: .aspectFit,
                                 options: option) {[weak self] (thoumbnailImage, info) in
                                    // 判断是否是返回的低清的缩略图
                                    let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                                    if isDegraded || thoumbnailImage == nil {
                                        return
                                    }
                                    self?.assetImageThumbnail?.append(thoumbnailImage ?? UIImage())
                DispatchQueue.main.async {
                    self?.collectionView?.reloadData()
                }
                                    
            }
        }
        
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    // 获取已经选择的高清图片
    func getAssetImage(block: @escaping getImageCallBack) {
        
        callBack = block
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.version = .current
        option.deliveryMode = .highQualityFormat
        option.isSynchronous = true
        option.isNetworkAccessAllowed = true
        let imageWidth = (UIScreen.main.bounds.width - 120)
        let scale = CGFloat(UIScreen.main.scale)
        let queue = OperationQueue.main
        queue.maxConcurrentOperationCount = 1
        var arrayImage: Array<UIImage> = Array.init()
        
        if self.selectPHAssetNumber?.count == 0 {
            if self.callBack != nil {
                self.callBack!(arrayImage)
                return
            }
        }
        
        if self.noHaveImage {
            arrayImage.append(UIImage(named: "buzhidaoqigeshenmemingzi")!)
            if self.callBack != nil {
                self.callBack!(arrayImage)
                return
            }
        }
                
        for i in self.selectPHAssetNumber ?? [] {
            
            queue.addOperation {
                let asset = self.assetArray?[i]
                
                manager.requestImage(for: asset ?? PHAsset.init(),
                                     targetSize: CGSize(width: CGFloat(imageWidth) * scale, height: CGFloat(imageWidth) * scale),
                                     contentMode: .aspectFill,
                                     options: option) {[weak self] (image, info) in
                                        arrayImage.append(image ?? UIImage())
                                        if arrayImage.count == self?.selectPHAssetNumber?.count {
                                            if self?.callBack != nil {
                                                self?.callBack!(arrayImage)
                                            }
                                        }
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension PhotoAlbumView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         
        return self.noHaveImage ? 1 : (self.assetArray?.count ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellID, for: indexPath) as? PhotoAlbumCollectionViewCell
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let mycell = cell as? PhotoAlbumCollectionViewCell
        
        if self.noHaveImage {
            mycell?.mainImage.image = UIImage(named: "buzhidaoqigeshenmemingzi")
        } else {
            // 先判断数组内是否有
            let image = self.assetImageThumbnail?[indexPath.row]
            if self.assetImageThumbnail?.count == 0 || image?.size.width == 0 {
                let asset = self.assetArray?[indexPath.row] ?? PHAsset()
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                option.isSynchronous = false
                option.deliveryMode = .opportunistic
                option.resizeMode = .fast
                option.isNetworkAccessAllowed = true
                
                let imageWidth = self.imageWidth
                let scale = CGFloat(UIScreen.main.scale)
                
                mycell?.reqressentedAssetIdentifier = asset.localIdentifier
                manager.requestImage(for: asset,
                                     targetSize: CGSize(width: CGFloat(imageWidth) * scale, height: CGFloat(imageHeight) * scale),
                                     contentMode: .aspectFit,
                                     options: option) {[weak self] (thoumbnailImage, info) in
                                        // 判断是否是返回的低清的缩略图
                                        let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                                        if isDegraded || thoumbnailImage == nil {
                                            return
                                        }
                                        
                                        if mycell?.reqressentedAssetIdentifier == asset.localIdentifier {
                                            mycell?.mainImage.image = thoumbnailImage
                                            self?.assetImageThumbnail?[indexPath.row] = thoumbnailImage ?? UIImage()
                                        }
                }
            } else {
                mycell?.mainImage.image = self.assetImageThumbnail?[indexPath.row]
            }
        }
        
        if selectPHAssetNumber?.count == 0 {
            mycell?.selectView.isHidden = true
            mycell?.cellMaskView.isHidden = true
        } else {
            let isContains = selectPHAssetNumber?.contains(where: { (item) -> Bool in
                return item == indexPath.row
            })
            
            if isContains ?? false  {
                mycell?.selectView.isHidden = false
            } else {
                mycell?.selectView.isHidden = true
            }
            
            if (selectPHAssetNumber?.count ?? 0 >= selectMaxPhotoNum) && !(isContains ?? false)   {
                mycell?.cellMaskView.isHidden = false
            } else {
                mycell?.cellMaskView.isHidden = true
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let isContains = selectPHAssetNumber?.contains(where: { (item) -> Bool in
            return item == indexPath.row
        })
        
        if isContains == true {
            
        } else {
            selectPHAssetNumber?.removeAll()
            selectPHAssetNumber?.append(indexPath.row)
            collectionView.reloadData()
        }
        
        
//        if (isContains ?? false) || (selectPHAssetNumber?.count ?? 0) >= selectMaxPhotoNum {
//            for (index, obj) in (selectPHAssetNumber?.enumerated())! {
//                if obj == indexPath.row {
//                    selectPHAssetNumber?.remove(at: index)
//                    break
//                }
//            }
//        } else {
//
//            if (selectPHAssetNumber?.count ?? 0) >= selectMaxPhotoNum {
//
//            } else {
//                selectPHAssetNumber?.append(indexPath.row)
//            }
//
//        }
//
//        collectionView.reloadData()
    }
    
    func initialzierSelect() {
        self.selectPHAssetNumber = Array.init()
        self.collectionView?.reloadData()
    }
}

extension PhotoAlbumView: PhotoALbumDropDownViewDelegate {
    func dropDownSelectIndex(index: Int) {
        self.selectAssetCollectionIndex = index
        packUpDropDown()
        reloadPhotoForPhotoCollection()
    }
    
}
