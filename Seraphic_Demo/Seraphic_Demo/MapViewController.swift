//
//  ViewController.swift
//  Seraphic_Demo
//
//  Created by Paritosh on 28/09/23.
//

import UIKit
import GoogleMaps
import GooglePlaces

// MARK: - MapViewController

class MapViewController: UIViewController {
    
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
    var placesClient: GMSPlacesClient!
    let suggestionsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.isHidden = true
        return tableView
    }()
    var autocompleteSuggestions: [String] = []
    var selectedSuggestion: String?
    var distance = [String]()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        truckCollectionView.dataSource = self
        truckCollectionView.delegate = self
        truckCollectionView.isPagingEnabled = true
        searchField.delegate = self
        placesClient = GMSPlacesClient.shared()
        configureUI()
        fetchDataFromApi()
        searchFieldUI()
        view.addSubview(suggestionsTableView)
        configureTableViewConstraints()
        suggestionsTableView.delegate = self
        suggestionsTableView.dataSource = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToFirstItem()
        
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
    func configureTableViewConstraints(){
        NSLayoutConstraint.activate([
            suggestionsTableView.topAnchor.constraint(equalTo: searchField.bottomAnchor),
            suggestionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor , constant: 20),
            suggestionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor , constant: -20),
            suggestionsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    func calculateDistance(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> Double {
        let sourceLocation = CLLocation(latitude: source.latitude, longitude: source.longitude)
        let destinationLocation = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        
        let distanceInMeters = sourceLocation.distance(from: destinationLocation)
        
        let distanceInKilometers = distanceInMeters / 1000.0
        
        return distanceInKilometers
    }
    private func setupCollectionView() {
        truckCollectionView.dataSource = self
        truckCollectionView.delegate = self
        truckCollectionView.isPagingEnabled = true
    }
    func reloadSuggestionsTableView() {
        suggestionsTableView.reloadData()
        suggestionsTableView.isHidden = autocompleteSuggestions.isEmpty
        
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
        googleMapView.animate(to: GMSCameraPosition.camera(withTarget: targetLocation, zoom: 12))
    }
    
    
    @IBAction func navigateToGoogleMaps(_ sender: UIButton) {
        let latitude = "30.7265"
        let longitude = "76.7589"
        let url = "comgooglemaps://?center=\(latitude),\(longitude)&zoom=12"
        
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
                                    GMSMarker(position: CLLocationCoordinate2D(latitude: 30.7730, longitude: 76.7935)),
                                    GMSMarker(position: CLLocationCoordinate2D(latitude: 30.7421, longitude: 76.8188)),
                                    GMSMarker(position: CLLocationCoordinate2D(latitude: 30.7045, longitude: 76.7843))])
        self.distance = Array(repeating: "", count: self.markers.count)
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
        searchField.searchBarStyle = .default
        searchField.tintColor = .clear
    }
    
}


// MARK: handled the map section here
extension MapViewController : GMSMapViewDelegate{
    func nightMode(){
        // Set up the initial camera position
        let camera = GMSCameraPosition.camera(withLatitude: 30.7265, longitude: 76.7589, zoom: 12)
        googleMapView.camera = camera
        googleMapView.mapType = .normal
        // Enable night mode
        if let nightTimeStylePath = Bundle.main.path(forResource: "NightStyle", ofType: "json") {
            do {
                let nightTimeStyleData = try Data(contentsOf: URL(fileURLWithPath: nightTimeStylePath))
                if let nightTimeStyle = String(data: nightTimeStyleData, encoding: .utf8) {
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
    /// Update the markers
    func updateMapMarker() {
        guard selectedMarkerIndex >= 0, selectedMarkerIndex < markers.count else {
            return
        }
        let selectedMarker = markers[selectedMarkerIndex]
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
        cell.distanceLbl.text = "Driver Distance : \(distance[indexPath.row])"
        
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
//MARK: Search Field changes
extension MapViewController : UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        
        // Construct the request URL
        let apiKey = googleMapKey
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let baseURL = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        let input = "input=\(encodedQuery)"
        let key = "key=\(apiKey)"
        let urlString = "\(baseURL)?\(input)&\(key)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        // Create and send the request
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Request error: \(error.localizedDescription)")
                // Handle the error
                return
            }
            
            if let data = data {
                do {
                    // Parse the JSON response
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    
                    // Extract and handle predictions
                    if let predictions = json?["predictions"] as? [[String: Any]] {
                        for prediction in predictions {
                            if let description = prediction["description"] as? String {
                                print("Place Prediction: \(description)")
                                self.handlePlacePrediction(prediction)
                            }
                        }
                    }
                } catch {
                    print("JSON parsing error: \(error.localizedDescription)")
                    // Handle the parsing error
                }
            }
        }
        
        task.resume()
        searchBar.resignFirstResponder()
    }
    func handlePlacePrediction(_ prediction: [String: Any]) {
        guard
            let placeID = prediction["place_id"] as? String,
            let apiKey = googleMapKey as? String else {
            print("Invalid place prediction data")
            return
        }
        
        // Construct the request URL to get place details
        let placeDetailURL = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeID)&key=\(apiKey)"
        
        guard let url = URL(string: placeDetailURL) else {
            print("Invalid URL for place details")
            return
        }
        
        // Create and send the request to get place details
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Request error: \(error.localizedDescription)")
                // Handle the error
                return
            }
            
            if let data = data {
                do {
                    // Parse the JSON response
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    
                    // Extract and handle place details
                    if let result = json?["result"] as? [String: Any],
                       let geometry = result["geometry"] as? [String: Any],
                       let location = geometry["location"] as? [String: Any],
                       let lat = location["lat"] as? Double,
                       let lng = location["lng"] as? Double {
                        let selectedLocation = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                        for i in 0 ..< self.markers.count {
                            let markerLocation = self.markers[i].position
                            let rawDistance = "\(self.calculateDistance(from: selectedLocation, to: markerLocation))"
                            let formatter = NumberFormatter()
                            formatter.minimumFractionDigits = 0
                            formatter.maximumFractionDigits = 2
                            formatter.numberStyle = .decimal
                            let roundedDistance = formatter.string(from: Double(rawDistance) as? NSNumber ?? 0.0)
                            self.distance[i] = "\(roundedDistance ?? "") km"
                            print("Distance to marker: \(roundedDistance) km")
                        }
                        // Place a marker on the map
                        DispatchQueue.main.async {
                            self.placeMarkerOnMap(latitude: lat, longitude: lng)
                        }
                    }
                } catch {
                    print("JSON parsing error: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
    }
    
    
    ///Function to place a marker on the map
    func placeMarkerOnMap(latitude: Double, longitude: Double) {
        let position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let marker = GMSMarker(position: position)
        marker.title = "Current Location"
        googleMapView.selectedMarker = marker
        marker.map = googleMapView
        googleMapView.animate(to: GMSCameraPosition.camera(withTarget: position, zoom: 12))
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        fetchAutocompleteSuggestions(for: searchText)
    }
    func fetchAutocompleteSuggestions(for query: String) {
        
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        
        placesClient.findAutocompletePredictions(fromQuery: query, filter: filter, sessionToken: nil) { (results, error) in
            if let error = error {
                print("Autocomplete error: \(error.localizedDescription)")
                return
            }
            let suggestions = results?.compactMap { $0.attributedFullText.string } ?? []
            self.autocompleteSuggestions = suggestions
            self.reloadSuggestionsTableView()
        }
    }
    
    func updateMapWithSelectedLocation(location: String) {
        fetchPlaceDetails(for: location)
    }
    
    // Function to fetch place details using Google Places API
    func fetchPlaceDetails(for location: String) {
        guard let apiKey = googleMapKey as? String  else {
            print("Google Maps API key is missing.")
            return
        }
        
        let baseURL = "https://maps.googleapis.com/maps/api/place/textsearch/json"
        let query = "query=\(location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        let key = "key=\(apiKey)"
        let urlString = "\(baseURL)?\(query)&\(key)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL for place details")
            return
        }
        
        // Create and send the request to get place details
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Request error: \(error.localizedDescription)")
                // Handle the error
                return
            }
            
            if let data = data {
                do {
                    // Parse the JSON response
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    
                    // Extract and handle place details
                    if let results = json?["results"] as? [[String: Any]], let firstResult = results.first,
                       let geometry = firstResult["geometry"] as? [String: Any],
                       let location = geometry["location"] as? [String: Any],
                       let lat = location["lat"] as? Double,
                       let lng = location["lng"] as? Double {
                        let selectedLocation = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                        for i in 0 ..< self.markers.count {
                            let markerLocation = self.markers[i].position
                            let rawDistance = "\(self.calculateDistance(from: selectedLocation, to: markerLocation))"
                            let formatter = NumberFormatter()
                            formatter.minimumFractionDigits = 0
                            formatter.maximumFractionDigits = 2
                            formatter.numberStyle = .decimal
                            let roundedDistance = formatter.string(from: Double(rawDistance) as? NSNumber ?? 0.0)
                            self.distance[i] = "\(roundedDistance ?? "") km"
                            print("Distance to marker: \(roundedDistance ?? "") km")
                        }
                        // Place a marker on the map
                        DispatchQueue.main.async {
                            self.placeMarkerOnMap(latitude: lat, longitude: lng)
                            self.truckCollectionView.reloadData()
                        }
                    }
                } catch {
                    print("JSON parsing error: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
    }
    
}
extension MapViewController : UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompleteSuggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = autocompleteSuggestions[indexPath.row]
        return cell
    }
    
    // Implement UITableViewDelegate methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle the selection of a suggestion
        selectedSuggestion = autocompleteSuggestions[indexPath.row]
        print("Selected suggestion: \(selectedSuggestion ?? "")")
        searchField.text = selectedSuggestion
        if let selectedLocation = selectedSuggestion {
            updateMapWithSelectedLocation(location: selectedLocation)
        }
        suggestionsTableView.isHidden = true
        autocompleteSuggestions.removeAll()
        searchField.resignFirstResponder()
        reloadSuggestionsTableView()
        truckCollectionView.reloadData()
    }
    
    
}
