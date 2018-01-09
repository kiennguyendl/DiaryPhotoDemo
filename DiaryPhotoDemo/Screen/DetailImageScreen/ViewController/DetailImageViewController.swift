//
//  DetailImageViewController.swift
//  DiaryPhotoDemo
//
//  Created by Kiên Nguyễn on 12/22/17.
//  Copyright © 2017 Kien Nguyen. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

class DetailImageViewController: UIViewController {
    
    
    @IBOutlet weak var tableViewDetail: UITableView!
    
    var images: [UIImage] = []
    var imageURL: [URL] = []
    
    var listImageCreateDate = [ImagesCreateByDate]()
    var location: CLLocationCoordinate2D?
    var imagesCreateByDate: ImagesCreateByDate!{
        didSet{
            if let imagesInfors = imagesCreateByDate.imagesCreateByDate{
                location = imagesInfors[0].location?.coordinate
                for imageInfor in imagesInfors{
                    if let img = imageInfor.image, let url = imageInfor.imagePath{
                        images.append(img)
                        imageURL.append(url)
                    }
                }
            }
            //tableViewDetail.reloadData()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTableView()
    }

    func initTableView() {
        tableViewDetail.delegate = self
        tableViewDetail.dataSource = self
        
        tableViewDetail.register(UINib.init(nibName: "VideoTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoCell")
        tableViewDetail.register(UINib.init(nibName: "MapTableViewCell", bundle: nil), forCellReuseIdentifier: "MapCell")
    }

}

extension DetailImageViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //var cell = UITableViewCell()
        let currentSection = indexPath.section
        
        if currentSection == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoTableViewCell
            //cell.images = images
            cell.images = images
            cell.delegate = self
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapCell", for: indexPath) as! MapTableViewCell
            cell.imagesCreateByDate = imagesCreateByDate
            //cell.delegate = self
            return cell
        }
        //return UICollectionViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentSection = indexPath.section
        
        if currentSection == 0{
            return CGFloat(self.view.frame.height / 3)
        }else{
            return CGFloat(self.view.frame.height / 3)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0
        }else{
            return 50
        }
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        <#code#>
//    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section != 0{
            return "Places"
        }
        return ""
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentSection = indexPath.section
        if currentSection == 1{
            print("kien test")
            let vc = ImagesMapViewController()
            vc.listImageCreateDate = listImageCreateDate
            vc.location = location
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}


extension DetailImageViewController: VideoCellProtocol{
    func createVideo(images: [UIImage]) {
        let vc = PlayVideoViewController()
//        vc.images = images
        vc.imagesURL = imageURL
        navigationController?.pushViewController(vc, animated: true)
    }
}

//extension DetailImageViewController: MapCellProtocol{
//    func showMap(location: CLLocationCoordinate2D) {
//        let vc = ImagesMapViewController()
//        vc.listImageCreateDate = listImageCreateDate
//        vc.location = location
//        navigationController?.pushViewController(vc, animated: true)
//    }
//}

