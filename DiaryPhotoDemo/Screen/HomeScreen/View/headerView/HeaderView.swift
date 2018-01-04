//
//  HeaderView.swift
//  DiaryPhotoDemo
//
//  Created by Kiên Nguyễn on 12/25/17.
//  Copyright © 2017 Kien Nguyen. All rights reserved.
//

import Foundation
import UIKit

class HeaderView: UIView {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var showAll: UIButton!
    
    @IBOutlet fileprivate var contentView:UIView?
    
    override init(frame: CGRect) { // for using CustomView in code
        super.init(frame: frame)
        self.loadViewFromXIB()
    }
    
    required init?(coder aDecoder: NSCoder) { // for using CustomView in IB
        super.init(coder: aDecoder)
        self.loadViewFromXIB()
    }
    
    func loadViewFromXIB() {
        let bundle = Bundle(for:type(of: self))
        let view = bundle.loadNibNamed(NSStringFromClass(type(of: self)).components(separatedBy: ".").last!, owner: self, options: nil)?.first as? UIView
        guard let contentView = view else { return }
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(contentView)
    }
    
}
