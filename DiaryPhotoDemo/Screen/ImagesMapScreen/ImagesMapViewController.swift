//
//  ImagesMapViewController.swift
//  DiaryPhotoDemo
//
//  Created by Kiên Nguyễn on 1/4/18.
//  Copyright © 2018 Kien Nguyen. All rights reserved.
//

import UIKit
import GoogleMaps


class ImagesMapViewController: UIViewController {

    @IBOutlet weak var viewDisplayMap: UIView!
    private var mapView: GMSMapView!
    private var clusterManager: GMUClusterManager!
    var listImageHasLocation = [ImagesCreateByDate]()
    var location: CLLocationCoordinate2D?
    var listImageCreateDate: [ImagesCreateByDate]?{
        didSet{
            if let listImageCreateDate = listImageCreateDate{
                for imageCreateDate in listImageCreateDate{
                    //location = imageCreateDate.imagesCreateByDate![0].location
                    if imageCreateDate.imagesCreateByDate![0].location != nil{
                        listImageHasLocation.append(imageCreateDate)
                    }
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let camera = GMSCameraPosition.camera(withLatitude: (location?.latitude)!, longitude: (location?.longitude)!, zoom: 10)
        mapView = GMSMapView.map(withFrame: self.viewDisplayMap.bounds, camera: camera)
        self.viewDisplayMap.addSubview(mapView)
        
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = ClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        
        // Add people to the cluster manager.
//        for item in randomPerson(){
//            clusterManager.add(item)
//        }
        
        createClusterItems()
        
        clusterManager.cluster()
        clusterManager.setDelegate(self, mapDelegate: self)
    }
    
    func createClusterItems() {
        
        for imageHasLocation in listImageHasLocation{
            
            let location = imageHasLocation.imagesCreateByDate![0].location?.coordinate
            let lat = location?.latitude
            let lng = location?.longitude
            
            let image = imageHasLocation.imagesCreateByDate![0].image
            
            let item = POIItem(position: CLLocationCoordinate2DMake(lat!, lng!), image: image!)
            
            clusterManager.add(item)
        }
        
    }

}

extension ImagesMapViewController: GMUClusterManagerDelegate, GMSMapViewDelegate, GMUClusterRendererDelegate{
    
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
            NSLog("Did tap marker for cluster item")
        } else {
            NSLog("Did tap a normal marker")
        }
        return false
    }
    
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        if marker.userData is POIItem{
            let item = marker.userData as! POIItem
            //marker.title = person.imageUrl
            marker.icon = imageForItem(item: item)
            // Center the marker at the center of the image.
            marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            
        }else if let cluster = marker.userData as? GMUCluster{
            marker.icon = imageForCluster(cluster: cluster)
        }
    }
    
    func imageForItem(item: GMUClusterItem) -> UIImage {
        let item = item as! POIItem
        
        //        let scale = item.image.scale
        let size = CGSize(width: kImageDimension, height: kImageDimension)
        UIGraphicsBeginImageContextWithOptions( size, true, 0)
        let image = item.image
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }
    
    func imageForCluster(cluster: GMUCluster) -> UIImage {
        let items = cluster.items
        var images: [UIImage] = []
        for i in 0..<items.count{
            images.append(imageForItem(item: items[i]))
            if i >= 4{
                break
            }
        }
        return imageFromImages(images: images, size: CGSize(width: kImageDimension * 1, height: kImageDimension * 1))
    }
    
    func imageFromImages(images: [UIImage], size: CGSize) -> UIImage {
        if images.count <= 1{
            return images.first!
        }
        
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        if images.count == 2 || images.count == 3{
            // Draw left half.
            images[0].draw(in: CGRect(x: -size.width / 4, y: 0, width: size.width, height: size.height))
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
}
