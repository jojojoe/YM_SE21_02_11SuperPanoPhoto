//
//  SSPMultiSlideFilterView.swift
//  SPPymSuperPanoPhoto
//
//  Created by JOJO on 2021/5/12.
//

import UIKit
import YPImagePicker




class SSPMultiSlideFilterView: UIView {

    var collection: UICollectionView!
    var filtersLoader: UIActivityIndicatorView!
    var currentSelectFilterName: String = ""
    var filterClickBlock: ((YPFilter)->Void)?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLoadFilter()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLoadFilter() {
        DispatchQueue.global().async {
            SSPFilterManager.default.processFilterThumbImages(image: UIImage(named: "origan_ic")!)
            
            DispatchQueue.main.async {
                self.collection.reloadData()
                self.collection.selectItem(at: IndexPath(row: 0, section: 0),
                                            animated: false,
                                            scrollPosition: UICollectionView.ScrollPosition.bottom)
                self.filtersLoader.stopAnimating()
            }
        }
    }
    
   
    func setupView() {
        
        filtersLoader = UIActivityIndicatorView(style: .medium)
        filtersLoader.hidesWhenStopped = true
        filtersLoader.startAnimating()
        addSubview(filtersLoader)
        filtersLoader.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.greaterThanOrEqualTo(24)
        }
        
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collection = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.backgroundColor = .clear
        collection.delegate = self
        collection.dataSource = self
        addSubview(collection)
        collection.snp.makeConstraints {
            $0.top.bottom.right.left.equalToSuperview()
        }
        collection.register(cellWithClass: SSPMultiSlideFilterCell.self)
    }
    
    
}

extension SSPMultiSlideFilterView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: SSPMultiSlideFilterCell.self, for: indexPath)
        let img = SSPFilterManager.default.filteredThumbnailImagesArray[indexPath.item]
        cell.topIconImgV.image = img
        let fitlerName = SSPFilterManager.default.filters[indexPath.item].name
        
        cell.nameLabel.text = fitlerName
        if currentSelectFilterName == fitlerName {
            cell.selectImgV.isHidden = false
        } else {
            cell.selectImgV.isHidden = true
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SSPFilterManager.default.filteredThumbnailImagesArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
}

extension SSPMultiSlideFilterView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 88, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 32
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 32
    }
    
}

extension SSPMultiSlideFilterView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filter = SSPFilterManager.default.filters[indexPath.item]
        self.currentSelectFilterName = filter.name
        self.filterClickBlock?(filter)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
}

class SSPMultiSlideFilterCell: UICollectionViewCell {
    let topIconImgV = UIImageView()
    let selectImgV = UIImageView()
    let nameLabel = UILabel()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        topIconImgV.clipsToBounds = true
        topIconImgV.layer.cornerRadius = 32
        topIconImgV.contentMode = .scaleAspectFill
        contentView.addSubview(topIconImgV)
        topIconImgV.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(88)
        }
        //
        contentView.addSubview(selectImgV)
        selectImgV.image = UIImage(named: "edit_select_ic")
        selectImgV.snp.makeConstraints {
            $0.top.right.equalToSuperview()
            $0.width.height.equalTo(19)
        }
        //
        contentView.addSubview(nameLabel)
        nameLabel.textAlignment = .center
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.font = UIFont(name: "Avenir-Black", size: 14)
        nameLabel.textColor = UIColor(hexString: "#EF4C96")
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(topIconImgV.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
            $0.left.equalToSuperview()
            $0.height.greaterThanOrEqualTo(1)
        }
    }
}

class SSPFilterManager: NSObject {
    
    var filters: [YPFilter] = []
    static let `default` = SSPFilterManager()
    var filteredThumbnailImagesArray: [UIImage] = []
    var thumbnailImageForFiltering: CIImage?
    
    
    func processFilterThumbImages(image: UIImage) {
        filters = YPImagePickerConfiguration().filters
        
        thumbnailImageForFiltering = thumbFromImage(image)
        self.filteredThumbnailImagesArray = self.filters.map { filter -> UIImage in
            if let applier = filter.applier,
                let thumbnailImage = self.thumbnailImageForFiltering,
                let outputImage = applier(thumbnailImage) {
                return outputImage.toUIImage()
            } else {
                return image
            }
        }
    }
    func processImage(image: UIImage, filter: YPFilter) -> UIImage {
        let thumbImg = thumbFromImage(image)
        if let applier = filter.applier,
            let outputImage = applier(thumbImg) {
            return outputImage.toUIImage()
        }
        return image
    }
    
    func thumbFromImage(_ img: UIImage) -> CIImage {
        let k = img.size.width / img.size.height
        let scale = UIScreen.main.scale
        let thumbnailHeight: CGFloat = 300 * scale
        let thumbnailWidth = thumbnailHeight * k
        let thumbnailSize = CGSize(width: thumbnailWidth, height: thumbnailHeight)
        UIGraphicsBeginImageContext(thumbnailSize)
        img.draw(in: CGRect(x: 0, y: 0, width: thumbnailSize.width, height: thumbnailSize.height))
        let smallImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return smallImage!.toCIImage()!
    }
    
    
}


extension CIImage {
    func toUIImage() -> UIImage {
        /*
            If need to reduce the process time, than use next code.
            But ot produce a bug with wrong filling in the simulator.
            return UIImage(ciImage: self)
         */
        let context: CIContext = CIContext.init(options: nil)
        let cgImage: CGImage = context.createCGImage(self, from: self.extent)!
        let image: UIImage = UIImage(cgImage: cgImage)
        return image
    }
    
    func toCGImage() -> CGImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(self, from: self.extent) {
            return cgImage
        }
        return nil
    }
}

extension UIImage {
    
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Kudos to Trevor Harmon and his UIImage+Resize category from
    // which this code is heavily inspired.
    func resetOrientation() -> UIImage {
        // Image has no orientation, so keep the same
        if imageOrientation == .up {
            return self
        }
        
        // Process the transform corresponding to the current orientation
        var transform = CGAffineTransform.identity
        switch imageOrientation {
        case .down, .downMirrored:           // EXIF = 3, 4
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
            
        case .left, .leftMirrored:           // EXIF = 6, 5
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2))
            
        case .right, .rightMirrored:          // EXIF = 8, 7
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -CGFloat((Double.pi / 2)))
        default:
            ()
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored:     // EXIF = 2, 4
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored, .rightMirrored:   //EXIF = 5, 7
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            ()
        }
        
        // Draw a new image with the calculated transform
        let context = CGContext(data: nil,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: cgImage!.bitsPerComponent,
                                bytesPerRow: 0,
                                space: cgImage!.colorSpace!,
                                bitmapInfo: cgImage!.bitmapInfo.rawValue)
        context?.concatenate(transform)
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context?.draw(cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            context?.draw(cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        
        if let newImageRef =  context?.makeImage() {
            let newImage = UIImage(cgImage: newImageRef)
            return newImage
        }
        
        // In case things go wrong, still return self.
        return self
    }
    
    fileprivate func cappedSize(for size: CGSize, cappedAt: CGFloat) -> CGSize {
        var cappedWidth: CGFloat = 0
        var cappedHeight: CGFloat = 0
        if size.width > size.height {
            // Landscape
            let heightRatio = size.height / size.width
            cappedWidth = min(size.width, cappedAt)
            cappedHeight = cappedWidth * heightRatio
        } else if size.height > size.width {
            // Portrait
            let widthRatio = size.width / size.height
            cappedHeight = min(size.height, cappedAt)
            cappedWidth = cappedHeight * widthRatio
        } else {
            // Squared
            cappedWidth = min(size.width, cappedAt)
            cappedHeight = min(size.height, cappedAt)
        }
        return CGSize(width: cappedWidth, height: cappedHeight)
    }
    
    func toCIImage() -> CIImage? {
        return self.ciImage ?? CIImage(cgImage: self.cgImage!)
    }
}

