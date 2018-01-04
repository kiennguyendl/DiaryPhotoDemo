//
//  NewMapTableViewCell.swift
//  DiaryPhotoDemo
//
//  Created by Kiên Nguyễn on 1/4/18.
//  Copyright © 2018 Kien Nguyen. All rights reserved.
//

import UIKit

let kCameraLatitude = -33.8
let kCameraLongitude = 151.2
let kImageDimension = 60

class Person: NSObject, GMUClusterItem{
    var position: CLLocationCoordinate2D
    var imageUrl: String
    var cachedImage: UIImage?
    
    init(position: CLLocationCoordinate2D, imageUrl: String) {
        self.position = position
        self.imageUrl = imageUrl
    }
    
}


class ClusterRenderer : GMUDefaultClusterRenderer{
    override func shouldRender(as cluster: GMUCluster, atZoom zoom: Float) -> Bool {
        return cluster.count >= 2
    }
}



class NewMapTableViewCell: UITableViewCell {

    private var mapView: GMSMapView!
    private var clusterManager: GMUClusterManager!
    
    var location: CLLocationCoordinate2D?
    var images: [UIImage] = []
    var imagesCreateByDate: ImagesCreateByDate!{
        didSet{
            if let imagesInfors = imagesCreateByDate.imagesCreateByDate{
                location = imagesInfors[0].location?.coordinate
                for imageInfor in imagesInfors{
                    if let img = imageInfor.image{
                        images.append(img)
                    }
                }
            }
            
            loadView()
        }
    }
    
    @IBOutlet weak var view: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        loadView()
    }

    func randomPerson() -> [Person] {
//        Person(position: , imageUrl: "")
        let persons = [Person(position: CLLocationCoordinate2DMake(-33.8, 151.2), imageUrl: "https://c1.staticflickr.com/5/4125/5036248253_e405cc6961_s.jpg"),
                       Person(position: CLLocationCoordinate2DMake(-33.82, 151.1), imageUrl: "https://c2.staticflickr.com/2/1350/4726917149_2a7e7c579e_s.jpg"),
                       Person(position: CLLocationCoordinate2DMake(-33.9, 151.15), imageUrl: "https://c2.staticflickr.com/4/3101/3111525394_737eaf0dfd_s.jpg"),
                       Person(position: CLLocationCoordinate2DMake(-33.91, 151.05), imageUrl: "https://c2.staticflickr.com/4/3288/2887433330_7e7ed360b1_s.jpg"),
                       Person(position: CLLocationCoordinate2DMake(-33.7, 151.06), imageUrl: "https://c1.staticflickr.com/3/2405/2179915182_5a0ac98b49_s.jpg"),
                       Person(position: CLLocationCoordinate2DMake(-33.5, 151.18), imageUrl: "https://c1.staticflickr.com/9/8035/7893552556_3351c8a168_s.jpg"),
                       Person(position: CLLocationCoordinate2DMake(-34.0, 151.18), imageUrl: "https://c1.staticflickr.com/5/4125/5036231225_549f804980_s.jpg")]
        return persons
    }
    
    func loadView() {
        let camera = GMSCameraPosition.camera(withLatitude: kCameraLatitude, longitude: kCameraLongitude, zoom: 5)
        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), camera: camera)
        self.view.addSubview(mapView)
        
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = ClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        
        // Add people to the cluster manager.
        for item in randomPerson(){
            clusterManager.add(item)
        }
        
        clusterManager.cluster()
        clusterManager.setDelegate(self, mapDelegate: self)
    }
    
}


extension NewMapTableViewCell: GMUClusterManagerDelegate, GMSMapViewDelegate, GMUClusterRendererDelegate{
    
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
                                                 zoom: mapView.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.moveCamera(update)
        return false
    }
    
    // MARK: - GMUMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let poiItem = marker.userData as? POIItem {
            NSLog("Did tap marker for cluster item ")
        } else {
            NSLog("Did tap a normal marker")
        }
        return false
    }
    
//    func renderer(_ renderer: GMUClusterRenderer, markerFor object: Any) -> GMSMarker? {
//
//        let marker = GMSMarker()
//
//
//        return marker
//    }

    // Returns an image representing the cluster item marker.
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        if marker.userData is Person{
            let person = marker.userData as! Person
            marker.title = person.imageUrl
            marker.icon = imageForItem(item: person)
            // Center the marker at the center of the image.
            marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            
        }else if let cluster = marker.userData as? GMUCluster{
            marker.icon = imageForCluster(cluster: cluster)
        }
    }
    
    func imageForItem(item: GMUClusterItem) -> UIImage {
        let person = item as! Person
        if person.cachedImage == nil{
            // Note: synchronously download and resize the image. Ideally the image should either be cached
            // already or the download should happens asynchronously.
            person.cachedImage = imageWithContentsOfURL(url: person.imageUrl, size: CGSize(width: kImageDimension, height: kImageDimension))
        }
        return person.cachedImage!
    }
    
    // Returns an image representing the cluster marker. Only takes a maximum of 4
    // items in the cluster to create the mashed up image.
    func imageForCluster(cluster: GMUCluster) -> UIImage {
        let items = cluster.items
        var images: [UIImage] = []
        for i in 0..<items.count{
            images.append(imageForItem(item: items[i]))
            if i >= 4{
                break
            }
        }
        return imageFromImages(images: images, size: CGSize(width: kImageDimension * 2, height: kImageDimension * 2))
    }
    
    // Mashes up the images.
    func imageFromImages(images: [UIImage], size: CGSize) -> UIImage {
        if images.count <= 1{
            return images.first!
        }
        
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        if images.count == 2 || images.count == 3{
            // Draw left half.
            images[0].draw(in: CGRect(x: -size.width, y: 0, width: size.width, height: size.height))
        }
        
        if images.count == 2{
            // Draw right half.
            let halfOfImage2 = halfOfImage(image: images[1])
            halfOfImage2.draw(in: CGRect(x: size.width / 2, y: 0, width: size.width / 2, height: size.height))
        }else{
            // Draw top right quadrant.
            images[1].draw(in: CGRect(x: size.width / 2, y: 0, width: size.width / 2, height: size.height))
            // Draw bottom right quadrant.
            images[2].draw(in: CGRect(x: size.width / 2, y: size.height / 2, width: size.width / 2, height: size.height / 2))
        }
        
        if images.count >= 4{
            // Draw top left quadrant.
            images[0].draw(in: CGRect(x: 0, y: 0, width: size.width / 2, height: size.height / 2))
            // Draw bottom left quadrant.
            images[3].draw(in: CGRect(x: 0, y: size.height / 2, width: size.width / 2, height: size.height / 2))
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    // Returns a new image with half the width of the original.
    func halfOfImage(image: UIImage) -> UIImage {
        let scale = image.scale
        let width = image.size.width * scale
        let height = image.size.height * scale
        let rect = CGRect(x: width / 4, y: 0, width: width / 2, height: height)
        let imageRef = image.cgImage?.cropping(to: rect)
        let newImage = UIImage(cgImage: imageRef!, scale: scale, orientation: image.imageOrientation)
        return newImage
    }
    
    // Downloads and resize an image.
    func imageWithContentsOfURL(url: String, size: CGSize) -> UIImage {
            let url = URL(string: url)
            let data = try? Data(contentsOf: url!)
//            let data = try Data(contentsOf: URL(fileURLWithPath: url))
            let image = UIImage(data: data!)
            UIGraphicsBeginImageContextWithOptions(size, true, 0)
            image?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage!

        
    }
}
