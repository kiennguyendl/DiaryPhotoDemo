//
//  ImagesCreateByDate.swift
//  DiaryPhotoDemo
//
//  Created by Kiên Nguyễn on 12/25/17.
//  Copyright © 2017 Kien Nguyen. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class ImagesCreateByDate: NSObject{
    var createDate: String?
    var imagesCreateByDate: [ImageInfor]?
    
    init(createDate: String, imagesCreateByDate: [ImageInfor]){
        self.createDate = createDate
        self.imagesCreateByDate = imagesCreateByDate
    }
}
