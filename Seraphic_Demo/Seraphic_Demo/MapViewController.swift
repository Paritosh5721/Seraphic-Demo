//
//  ViewController.swift
//  Seraphic_Demo
//
//  Created by Paritosh on 28/09/23.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {
    
    
    @IBOutlet weak var googleMapView: GMSMapView!
    
    
    @IBOutlet weak var truckCollectionView: UICollectionView!
    
    
    @IBOutlet weak var headerTitle: UILabel!
    
    
    
    @IBOutlet weak var pageControl: UIPageControl!
    let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: 30.7265, longitude: 76.7589))
    override func viewDidLoad() {
        super.viewDidLoad()
        truckCollectionView.dataSource = self
        truckCollectionView.delegate = self
        truckCollectionView.isPagingEnabled = true
        configureUI()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Scroll the collection view to the first item
        let indexPath = IndexPath(item: 0, section: 0)
        truckCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        
        // Update the current page and layout
        pageControl.currentPage = 0
        pageControl.layoutIfNeeded()
    }
    func configureUI(){
        nightMode()
        registerCollectionCell()
        pageControl.numberOfPages = 4
        pageControl.currentPage = 0
        truckCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        pageControl.layoutIfNeeded()
        
        truckCollectionView.reloadData()
        pageControl.addTarget(self, action: #selector(pageControlValueChanged(_:)), for: .valueChanged)
        
    }
    @objc func pageControlValueChanged(_ sender: UIPageControl) {
        let targetX = CGFloat(sender.currentPage) * truckCollectionView.frame.size.width
        truckCollectionView.setContentOffset(CGPoint(x: targetX, y: 0), animated: true)
    }
    func registerCollectionCell(){
        let nib = UINib(nibName: "ShowDriverCollectionViewCell", bundle: nil)
        truckCollectionView.register(nib, forCellWithReuseIdentifier: "ShowDriverCollectionViewCell")
    }

    
    
}


// MARK: handled the map section here
extension MapViewController : GMSMapViewDelegate{
    func nightMode(){
        // Set up the initial camera position
        let camera = GMSCameraPosition.camera(withLatitude: 30.7265, longitude: 76.7589, zoom: 17)
        
        // Create a GMSMapView with the specified camera position
        //        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        googleMapView.camera = camera
       
        // Set the map type to satellite
        googleMapView.mapType = .normal
        
        // Enable night mode
        if let nightTimeStylePath = Bundle.main.path(forResource: "NightStyle", ofType: "json") {
            do {
                // Get the JSON data from the file
                let nightTimeStyleData = try Data(contentsOf: URL(fileURLWithPath: nightTimeStylePath))
                
                // Convert the data to a string
                if let nightTimeStyle = String(data: nightTimeStyleData, encoding: .utf8) {
                    // Set the map style
                    googleMapView.mapStyle = try GMSMapStyle(jsonString: nightTimeStyle)
                    googleMapView.clear()
                } else {
                    print("Failed to convert JSON data to string.")
                }
            } catch {
                print("Failed to load or apply night mode style. Error: \(error)")
            }
        } else {
            print("NightStyle.json not found in the bundle.")
        }
        marker.icon = UIImage(named: "marker_image 1")
        self.marker.title = "Paritosh"
        self.marker.isTappable = true
        marker.map = googleMapView
        googleMapView.delegate = self
//        googleMapView.selectedMarker = marker
//        googleMapView.selectedMarker = nil
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        // Handle marker tap
        // Create and display your custom info window
        let customInfoWindow = CustomInfoWindow()
        customInfoWindow.configure(withName: marker.title ?? "")
        customInfoWindow.center = mapView.projection.point(for: marker.position)
        customInfoWindow.center.y -= 100  // Adjust the vertical offset as needed

        mapView.addSubview(customInfoWindow)

        return true
    }
    
//    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
//
//        let infoWindow = CustomInfoWindow(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
//            infoWindow.backgroundColor = .white
//            if let name = marker.title {
//                infoWindow.configure(withName: name)
//            }
//
//            return infoWindow
//    }
}





// MARK: Handled Collection View Data
extension MapViewController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout , UIScrollViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = truckCollectionView.dequeueReusableCell(withReuseIdentifier: "ShowDriverCollectionViewCell", for: indexPath) as? ShowDriverCollectionViewCell else {return UICollectionViewCell()}
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Set your cell size here
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = pageIndex
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: truckCollectionView.contentOffset, size: truckCollectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        if let indexPath = truckCollectionView.indexPathForItem(at: visiblePoint) {
            pageControl.currentPage = indexPath.item
        }
    }

}
