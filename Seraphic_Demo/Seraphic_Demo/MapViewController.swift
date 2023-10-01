//
//  ViewController.swift
//  Seraphic_Demo
//
//  Created by Paritosh on 28/09/23.
//

import UIKit
import GoogleMaps


// MARK: - MapViewController

class MapViewController: UIViewController , UISearchBarDelegate{
    
    // MARK: Outlets
    
    @IBOutlet weak var googleMapView: GMSMapView!
    
    
    @IBOutlet weak var truckCollectionView: UICollectionView!
    
    
    @IBOutlet weak var headerTitle: UILabel!
    


    @IBOutlet weak var pageControl: UIPageControl!
    
    
    @IBOutlet weak var searchField: UISearchBar!
    
    // MARK: Properties
    
    var currentInfoWindow: CustomInfoWindow?
    
    var selectedMarkerIndex: Int = 0
    var employees: [Employee] = [Employee].init(arrayLiteral: Employee(id: 0, employeeName: "Paritosh", employeeSalary: 10000, employeeAge: 24, profileImage: ""))
    
    let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: 30.7265, longitude: 76.7589))
    var markers: [GMSMarker] = []
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        truckCollectionView.dataSource = self
        truckCollectionView.delegate = self
        truckCollectionView.isPagingEnabled = true
        searchField.delegate = self
        configureUI()
        fetchDataFromApi()
        searchFieldUI()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToFirstItem()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            if let firstMarker = self.markers.first {
//                self.mapView(self.googleMapView, markerInfoWindow: firstMarker)
//            }
//        }

    }
    
    // MARK: UI Setup
    
    func configureUI(){
        setupMarkers()
        nightMode()
        registerCollectionCell()
        configurePageControl()
        setupCollectionView()
        truckCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        truckCollectionView.reloadData()
        
    }
    private func configurePageControl() {
        pageControl.numberOfPages = 4
        pageControl.currentPage = 0
        pageControl.layoutIfNeeded()
        pageControl.addTarget(self, action: #selector(pageControlValueChanged(_:)), for: .valueChanged)
    }
    
    private func setupCollectionView() {
        truckCollectionView.dataSource = self
        truckCollectionView.delegate = self
        truckCollectionView.isPagingEnabled = true
    }
    
    func registerCollectionCell(){
        let nib = UINib(nibName: "ShowDriverCollectionViewCell", bundle: nil)
        truckCollectionView.register(nib, forCellWithReuseIdentifier: "ShowDriverCollectionViewCell")
    }
    
    // MARK: Scroll to First Item
    
    private func scrollToFirstItem() {
        let indexPath = IndexPath(item: 0, section: 0)
        truckCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        pageControl.currentPage = 0
        pageControl.layoutIfNeeded()
    }
    
    
    // MARK: Actions
    
    @objc func pageControlValueChanged(_ sender: UIPageControl) {
        let targetX = CGFloat(sender.currentPage) * truckCollectionView.frame.size.width
        truckCollectionView.setContentOffset(CGPoint(x: targetX, y: 0), animated: true)
    }
    
    
    @IBAction func currentLocationBtnTapped(_ sender: UIButton) {
        let targetLocation = CLLocationCoordinate2D(latitude: 30.7265, longitude: 76.7589)
        googleMapView.animate(to: GMSCameraPosition.camera(withTarget: targetLocation, zoom: 17))
    }
    
    
    @IBAction func navigateToGoogleMaps(_ sender: UIButton) {
        let latitude = "30.7265"
                let longitude = "76.7589"
                let url = "comgooglemaps://?center=\(latitude),\(longitude)&zoom=17"

                if UIApplication.shared.canOpenURL(URL(string: url)!) {
                    UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
                } else {
                    let webURL = "https://www.google.com/maps/place/\(latitude),\(longitude)"
                    UIApplication.shared.open(URL(string: webURL)!, options: [:], completionHandler: nil)
                }
    }
    
    
    // MARK: Marker Setup
    
    private func setupMarkers() {
        markers.append(contentsOf: [GMSMarker(position: CLLocationCoordinate2D(latitude: 30.7265, longitude: 76.7589)),
                                    GMSMarker(position: CLLocationCoordinate2D(latitude: 30.7275, longitude: 76.7599)),
                                    GMSMarker(position: CLLocationCoordinate2D(latitude: 30.7255, longitude: 76.7579)),
                                    GMSMarker(position: CLLocationCoordinate2D(latitude: 30.7260, longitude: 76.7574))])
        updateMapMarker()
    }
    
    
    // MARK: Data Fetching
    
    func fetchDataFromApi(){
        APIManager.shared.getEmployeeDataByURL{ result in
            switch result {
            case .success(let employeeResponse):
                self.employees = employeeResponse.data
                self.truckCollectionView.reloadData()
                self.nightMode()
                self.googleMapView.selectedMarker = self.markers[0]
//                self.updateMapMarker()
                //                self.handleEmployeeData()
            case .failure(let error):
                print("Error fetching employee data: \(error)")
            }
        }
    }
    
    // MARK: Search Field
    
    func searchFieldUI(){
        searchField.layer.cornerRadius = 10.0
        searchField.placeholder = "Search"
        let dropIconImage = UIImage(named: "dropLocationImage")
        searchField.setImage(dropIconImage, for: .search, state: .normal)
        searchField.showsBookmarkButton = true
        searchField.setImage(UIImage(systemName: "arrow.triangle.2.circlepath"), for: .bookmark, state: .normal)
        
        // Customize the appearance of the search bar
        searchField.searchBarStyle = .default
        searchField.tintColor = .clear
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
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
        if employees.count > 1{
            for i in 0 ..< markers.count{
                markers[i].icon = UIImage(named: "marker_image 1")
                self.markers[i].title = self.employees[i].employeeName
                self.markers[i].map = googleMapView
                let ppimage = UIImage(named: "userIcon")
                let dropImage = UIImage(named: "marker_image 1")
                self.markers[i].icon = drawImageWithProfilePic(pp: ppimage ?? UIImage(), image: dropImage ?? UIImage())
                if i == 0{
                    googleMapView.selectedMarker = markers[i]
                }
                
            }
        }else{
            self.marker.title = "Paritosh"
            self.marker.isTappable = true
            marker.map = googleMapView
            let ppimage = UIImage(named: "userIcon")
            let dropImage = UIImage(named: "marker_image 1")
            self.marker.icon = drawImageWithProfilePic(pp: ppimage ?? UIImage(), image: dropImage ?? UIImage())//UIImage(named: "userIcon")
        }
        googleMapView.delegate = self
        
    }
    
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        // Close the current info window
        currentInfoWindow?.removeFromSuperview()
        
        let infoWindow = CustomInfoWindow(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
        infoWindow.backgroundColor = .white
        if let name = marker.title {
            infoWindow.configure(withName: name)
        }
        
        // Keep a reference to the current info window
        currentInfoWindow = infoWindow
        
        if let index = markers.firstIndex(of: marker) {
            // Update the selected marker index
            selectedMarkerIndex = index
            
            // Update the collection view to show the corresponding cell
            let indexPath = IndexPath(item: index, section: 0)
            truckCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        
        return infoWindow
    }
    
    func drawImageWithProfilePic(pp: UIImage, image: UIImage) -> UIImage {
        
        let imgView = UIImageView(image: image)
        let picImgView = UIImageView(image: pp)
        picImgView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        imgView.addSubview(picImgView)
        picImgView.center.x = imgView.center.x
        picImgView.center.y = imgView.center.y - 7
        picImgView.layer.cornerRadius = picImgView.frame.width/2
        picImgView.clipsToBounds = true
        imgView.setNeedsLayout()
        picImgView.setNeedsLayout()
        
        let newImage = imageWithView(view: imgView)
        marker.userData = index
        return newImage
    }
    
    func imageWithView(view: UIView) -> UIImage {
        var image: UIImage?
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return image ?? UIImage()
    }
    func updateMapMarker() {
        guard selectedMarkerIndex >= 0, selectedMarkerIndex < markers.count else {
            return
        }
        // Get the selected marker
        let selectedMarker = markers[selectedMarkerIndex]
        // Optionally, update other marker properties based on the selected index
        // Refresh the map view
        googleMapView.animate(toLocation: selectedMarker.position)
        if mapView(googleMapView, markerInfoWindow: selectedMarker) != nil {
            let infoWindow = CustomInfoWindow(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
            infoWindow.backgroundColor = .white
            if let name = selectedMarker.title {
                infoWindow.configure(withName: name)
            }
        }
    }
}


// MARK: Handled Collection View Data
extension MapViewController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout , UIScrollViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let maxItemsToShow = 4
        return min(maxItemsToShow, self.employees.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = truckCollectionView.dequeueReusableCell(withReuseIdentifier: "ShowDriverCollectionViewCell", for: indexPath) as? ShowDriverCollectionViewCell else {return UICollectionViewCell()}
        let employee = self.employees[indexPath.row]
        //            cell.carimageView.image = UIImage(named: employee.profileImage)
        cell.driverName.text = "Driver's Name : \(employee.employeeName)"
        cell.driverLocation.text = "Driver's Salary : \(employee.employeeSalary)"
        cell.driverEta.text = "Driver's Age : \(employee.employeeAge)"
        
        
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
        selectedMarkerIndex =  pageControl.currentPage
        updateMapMarker()
        // Get the selected marker and update the info window
        if markers.count > selectedMarkerIndex{
            let selectedMarker = markers[selectedMarkerIndex]
            if mapView(googleMapView, markerInfoWindow: selectedMarker) != nil {
                let infoWindow = CustomInfoWindow(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
                infoWindow.backgroundColor = .white
                if let name = selectedMarker.title {
                    infoWindow.configure(withName: name)
                }
                googleMapView.selectedMarker = selectedMarker
            }
        }
        
    }
    
}
extension MapViewController {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let filter = GMSAutocompleteFilter()
        filter.type = .geocode

        placesClient.findAutocompletePredictions(fromQuery: searchText, filter: filter, callback: { (results, error) in
            if let error = error {
                print("Autocomplete error: \(error.localizedDescription)")
                return
            }

            if let results = results {
                // Handle autocomplete predictions (results)
                // You can display these as suggestions in your UI
                for result in results {
                    print("Place ID: \(result.placeID), Description: \(result.attributedFullText.string)")
                }
            }
        })
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Perform the search and handle the selected place
        searchBar.resignFirstResponder()

        let filter = GMSAutocompleteFilter()
        filter.type = .geocode

        placesClient.findAutocompletePredictions(fromQuery: searchBar.text ?? "", filter: filter, callback: { (results, error) in
            if let error = error {
                print("Autocomplete error: \(error.localizedDescription)")
                return
            }

            if let results = results, let firstPlace = results.first {
                // Handle the selected place
                self.handleSelectedPlace(placeID: firstPlace.placeID)
            }
        })
    }

    func handleSelectedPlace(placeID: String) {
        placesClient.lookUpPlaceID(placeID, callback: { (place, error) in
            if let error = error {
                print("Place lookup error: \(error.localizedDescription)")
                return
            }

            if let place = place {
                // Handle the details of the selected place
                print("Place name: \(place.name ?? "")")
                print("Place coordinate: \(place.coordinate)")
                
                // Navigate to the selected location and show a marker
                self.navigateToLocation(coordinate: place.coordinate, placeName: place.name)
            }
        })
    }

    func navigateToLocation(coordinate: CLLocationCoordinate2D, placeName: String?) {
        // Center the map and show a marker at the selected location
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        googleMapView.camera = camera

        // Add a marker
        let marker = GMSMarker(position: coordinate)
        marker.title = placeName
        marker.map = googleMapView
    }
}
