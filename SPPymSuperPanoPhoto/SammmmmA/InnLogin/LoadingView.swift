//
//  LoadingView.swift
//  HighLighting
//
//  Created by 薛忱 on 2021/3/26.
//  Copyright © 2021 Charles. All rights reserved.
//

import UIKit
import WebKit

class LoadingView: UIView {
    
    let wkWebView = WKWebView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        wkWebView.frame = CGRect(x: 0,
                                 y: 0,
                                 width: UIScreen.main.bounds.width,
                                 height: UIScreen.main.bounds.height)
        
        if let url = Bundle.main.url(forResource: "Untitled", withExtension: "html") {
            let request = URLRequest(url: url)
            wkWebView.load(request)
        }
        self.addSubview(wkWebView)
        
        if let url = Bundle.main.url(forResource: "loding2", withExtension: "webp") {
            let request = URLRequest(url: url)
            
        }
        
    }
    
    required init?(coder: NSCoder) {
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
