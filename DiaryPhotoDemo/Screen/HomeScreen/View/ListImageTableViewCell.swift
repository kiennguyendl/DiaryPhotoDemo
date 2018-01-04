//
//  ListImageTableViewCell.swift
//  DiaryPhotoDemo
//
//  Created by Kiên Nguyễn on 12/25/17.
//  Copyright © 2017 Kien Nguyen. All rights reserved.
//

import UIKit

class ListImageTableViewCell: UITableViewCell {

    @IBOutlet weak var listImagesCollectionView: UICollectionView!
    var listImage = [ImageInfor]()
    var imagesCreateByDate: ImagesCreateByDate?{
        didSet{
            if let imagesCreateByDate = imagesCreateByDate{
                if let listImg = imagesCreateByDate.imagesCreateByDate{
                    listImage = listImg
                    listImagesCollectionView.reloadData()
                }
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        listImagesCollectionView.delegate = self
        listImagesCollectionView.dataSource = self
        listImagesCollectionView.register(UINib.init(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "imageCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension ListImageTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
        cell.imageView.image = listImage[indexPath.row].image!
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        
        return CGSize(width: height, height: height)
    }
}
