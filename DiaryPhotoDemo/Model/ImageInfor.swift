//
//  ImageInfor.swift
//  DiaryPhotoDemo
//
//  Created by Kiên Nguyễn on 12/22/17.
//  Copyright © 2017 Kien Nguyen. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class ImageInfor: NSObject{
    
    var location: CLLocation?
    var createDate: Date?
    var image: UIImage?
    var hasLocation: Bool?
    
    init(location: CLLocation?, date: Date?, img: UIImage, hasLocation: Bool){
        self.location = location
        self.createDate = date
        self.image = img
        self.hasLocation = hasLocation
    }
}
