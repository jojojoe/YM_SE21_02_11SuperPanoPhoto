//
//  PhotoAlbumDropDownView.swift
//  BlukEdit
//
//  Created by 薛忱 on 2019/8/26.
//  Copyright © 2019 薛忱. All rights reserved.
//

import UIKit

protocol PhotoALbumDropDownViewDelegate: class {
    func dropDownSelectIndex(index: Int)
}

class PhotoAlbumDropDownView: UIView {
    
    let cellID = "PhotoAlbumDropDownTableViewCell"
    var tableView: UITableView?
    var dataArray: Array<String>?
    var isShow: Bool = false
    weak var delegate: PhotoALbumDropDownViewDelegate?
    
    init(frame: CGRect, dataSouce: Array<String>) {
        super.init(frame: frame)
        self.dataArray = dataSouce
        self.backgroundColor = .white
        initializerTablview()
    }
    
    func initializerTablview() {
        self.tableView = UITableView().then { (tableView) in
            tableView.backgroundColor = .white
            tableView.delegate = self
            tableView.dataSource = self
            tableView.separatorStyle = .none
            tableView.showsVerticalScrollIndicator = false
            tableView.showsHorizontalScrollIndicator = false
            self.addSubview(tableView)
            tableView.snp.makeConstraints {
                $0.left.right.top.bottom.equalToSuperview()
            }
            
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension PhotoAlbumDropDownView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(PhotoAlbumDropDownTableViewCell.self, forCellReuseIdentifier: cellID)
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? PhotoAlbumDropDownTableViewCell
        if cell == nil {
            cell =  PhotoAlbumDropDownTableViewCell(style: .default, reuseIdentifier: cellID)
        }
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let myCell = cell as? PhotoAlbumDropDownTableViewCell
        myCell?.cellTitle?.text = self.dataArray?[indexPath.row] ?? ""
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.dropDownSelectIndex(index: indexPath.row)
    }
    
}
