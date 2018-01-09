//
//  HomeViewController.swift
//  DiaryPhotoDemo
//
//  Created by Kiên Nguyễn on 12/22/17.
//  Copyright © 2017 Kien Nguyen. All rights reserved.
//

import UIKit
import Photos
import CoreLocation
import AddressBook
import Contacts

class HomeViewController: UIViewController {
    
    @IBOutlet weak var photosTableView: UITableView!
    var listImageInfor: [ImageInfor] = []
    var listImageHasLocation: [ImagesCreateByDate] = []
    var listImageCreateDate = [ImagesCreateByDate]()
    var assets: [PHAsset] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photosTableView.delegate = self
        photosTableView.dataSource = self
        photosTableView.register(UINib.init(nibName: "ListImageTableViewCell", bundle: nil), forCellReuseIdentifier: "ListImageCell")
        
        
        self.loadPhotoFromAlbum()
        
        
    }
    
    func loadPhotoFromAlbum(){
        let imageManager = PHImageManager()
        let requestOption = PHImageRequestOptions()
        requestOption.isSynchronous = true
        requestOption.deliveryMode = .fastFormat
//        requestOption.resizeMode = .fast
//        requestOption.version = .current
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        DispatchQueue.global(qos: .background).async{
            if fetchResult.count > 0 {
                print("num photo: \(fetchResult.count)")
                
                for i in 0..<fetchResult.count {
                    let asset = fetchResult.object(at: i)
                    
//                    self.assets.append(asset)
                    print("i: \(i)")
                    
//                    imageManager.requestImageData(for: asset, options: requestOption, resultHandler: {
//                         _, _, _, info in
//                        print("info: \(info)")
//                        if let fileName = (info?["PHImageFileURLKey"] as? NSURL)?.lastPathComponent/*, let imgData = imageData*/{
//                            let location = asset.location
//                            let createDate = asset.creationDate
//                            let imagePath = info?["PHImageFileURLKey"] as? URL
//                            let image = UIImage(data: imgData)

//                            let imageData = UIImagePNGRepresentation(image!)!
//                            let options = [
//                                kCGImageSourceCreateThumbnailWithTransform: true,
//                                kCGImageSourceCreateThumbnailFromImageAlways: true,
//                                kCGImageSourceThumbnailMaxPixelSize: 150] as CFDictionary
//                            let source = CGImageSourceCreateWithData(imageData as CFData, nil)!
//                            let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options)!
//                            let thumbnail = UIImage(cgImage: imageReference)
//
//                            print("location: \(location)")
//                            print("careate date: \(createDate)")
////                            print("image scale: \(image?.scale)")
////                            print("image size: \(image?.size)")
//                            print("image path: \(imagePath)")
//                            print("///////" + fileName + "////////")
//                            print("\n>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<\n")

//                            var hasLocation = false
//                            if location != nil{
//                                hasLocation = true
//                            }else{
//                                hasLocation = false
//                            }
//                            let imgInfor = ImageInfor(location: location, date: createDate, img: image!, imagePath: imagePath!, hasLocation: hasLocation)
//                            self.listImageInfor.append(imgInfor)
//                        }
//                    })
                
                    
                    imageManager.requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: requestOption, resultHandler: { image, info in

                        print("info: \(info)")
                        let imagePath = info?["PHImageFileURLKey"] as? URL
                        print("imagePath: \(imagePath)")
                        if let img = image{
//                            print("image scale: \(img.scale)")
                            print("image size: \(img.size)")
//                            print("path: \(asset.value(forKey:))")

                            let location = asset.location
                            let createDate = asset.creationDate

                            var hasLocation = false
                            if location != nil{
                                hasLocation = true
                            }else{
                                hasLocation = false
                            }
                            let imgInfor = ImageInfor(location: location, date: createDate, img: img, imagePath: imagePath!, hasLocation: hasLocation)
                            self.listImageInfor.append(imgInfor)
//                            print("location \(i): \(String(describing: asset.location))")
//                            print("time picked: \(i): \(String(describing: asset.creationDate))")


                        }
                    })
                }
                
                self.classifyImageByCreateDate(listImage: self.listImageInfor, completionHanler: {[weak self] data in
                    guard let strongSelf = self else{return}
                    //strongSelf.listImageCreateDate = data
                    strongSelf.listImageCreateDate = strongSelf.convertDictToArray(dict: data)
                    
//                    print(strongSelf.listImageCreateDate)
                    DispatchQueue.main.async {
                        strongSelf.photosTableView.reloadData()
                    }
                    
                })
            }
        }
        
    }
    
    func getAddressFromLocation(location: CLLocation) -> String{
        let geocoder = CLGeocoder()
        var place = "kaka"
        geocoder.reverseGeocodeLocation(location) { (data, error) -> Void in
            
            //get address and extract city and state
            let address = data![0].postalAddress!
            let city = address.city
            let detailAddress = address.street + ", " + address.subAdministrativeArea + ", " + address.subLocality
            //                                    let info = address.city + ", "  + address.country + ", " + address.isoCountryCode + ", " + address.postalCode + ", " + address.state + ", " + address.street + ", " + address.subAdministrativeArea + ", " + address.subLocality
            
            place = city + ", " + detailAddress
            //print(place)
            
        }
        return place
    }
    
    func convertDictToArray(dict: [String: [ImageInfor]]) -> [ImagesCreateByDate]{
        var dictArr = [ImagesCreateByDate]()
        for (key, value) in dict{
            let imgCreateByDate = ImagesCreateByDate(createDate: key, imagesCreateByDate: value)
            dictArr.append(imgCreateByDate)
        }
        
        return dictArr
    }
    
    func classifyImageByCreateDate(listImage: [ImageInfor], completionHanler: @escaping([String: [ImageInfor]]) -> Void){
        var listDictImageCreateDate = [String: [ImageInfor]]()
//    print("number image: \(listImage.count)")
            for img in listImage{
                
                if let createDate = img.createDate{
                    let dateFormater = DateFormatter()
                    dateFormater.dateFormat = "dd-MM-yyyy"
                    let createDateStr = dateFormater.string(from: createDate)
                    
                    if let location = img.location{
                        let geocoder = CLGeocoder()
                        
                        geocoder.reverseGeocodeLocation(location) { (data, error) -> Void in
                            
                            //get address and extract city and state
                            guard let data = data else {return}
                            let address = data[0].postalAddress!
                            let city = address.city
                            var detailAddress = ""
//                            if let subLocality = address.subLocality{
//                                detailAddress += subLocality
//                            }
//
//                            if let subAdministrativeArea = address.subAdministrativeArea{
//                                detailAddress += subAdministrativeArea
//                            }
                            if address.subLocality != ""{
                                detailAddress += address.subLocality
                            }
                            if address.subAdministrativeArea != ""{
                                detailAddress += address.subAdministrativeArea
                            }
//                            let detailAddress = address.subLocality + ", " + address.subAdministrativeArea
                            var place = city
                            if detailAddress != ""{
                                 place = ", " + detailAddress
                            }
                            
                            let key = createDateStr + "\n" + place
                            //print("key: \(key)")
                            
                            if listDictImageCreateDate.count > 0{
                                
                                if listDictImageCreateDate.keys.contains(key){
                                    listDictImageCreateDate[key]?.append(img)
                                }else{
                                    
                                    listDictImageCreateDate[key] = [ImageInfor]()
                                    listDictImageCreateDate[key]?.append(img)
                                }
                            }else{
                                listDictImageCreateDate[key] = [ImageInfor]()
                                listDictImageCreateDate[key]?.append(img)
                                print("ahihi")
                            }
                            completionHanler(listDictImageCreateDate)
                        }
                        
                    }else{
                        if listDictImageCreateDate.count > 0{
                            if listDictImageCreateDate.keys.contains(createDateStr){
                                listDictImageCreateDate[createDateStr]?.append(img)
                            }else{
                                
                                listDictImageCreateDate[createDateStr] = [ImageInfor]()
                                listDictImageCreateDate[createDateStr]?.append(img)
                            }
                        }else{
                            listDictImageCreateDate[createDateStr] = [ImageInfor]()
                            listDictImageCreateDate[createDateStr]?.append(img)
                            print("ahihi")
                        }
                    }
                    
                }
                completionHanler(listDictImageCreateDate)
            }
        
        //return convertDictToArray(dict: listDictImageCreateDate)
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return listImageCreateDate.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListImageCell", for: indexPath) as! ListImageTableViewCell
        
        let data = listImageCreateDate[indexPath.section]
        cell.imagesCreateByDate = data
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.width / 4 - 2
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return listImageCreateDate[section].createDate!
//    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = HeaderView()
        view.title.text = listImageCreateDate[section].createDate
        view.showAll.tag = section
        view.showAll.addTarget(self, action: #selector(showAllImage(sender:)), for: .touchUpInside)
        return view
    }
    
    
    @objc func showAllImage(sender: UIButton) {
        let section = sender.tag
        let vc = DetailImageViewController()
//        let vc = PlayVideoViewController()
//        let vc = ImagesMapViewController()
        vc.imagesCreateByDate = listImageCreateDate[section]
        vc.listImageCreateDate = listImageCreateDate
        navigationController?.pushViewController(vc, animated: true)
    }
}
