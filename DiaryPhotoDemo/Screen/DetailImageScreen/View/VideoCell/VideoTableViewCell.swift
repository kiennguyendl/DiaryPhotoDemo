//
//  VideoTableViewCell.swift
//  DiaryPhotoDemo
//
//  Created by Kiên Nguyễn on 1/2/18.
//  Copyright © 2018 Kien Nguyen. All rights reserved.
//

import UIKit

protocol VideoCellProtocol {
    func createVideo(images: [UIImage])
}
class VideoTableViewCell: UITableViewCell {

    var delegate: VideoCellProtocol?
    var images: [UIImage]!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func createVideo(_ sender: Any) {
        delegate?.createVideo(images: images)
    }
}
