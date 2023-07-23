//
//  SearchViewController.swift
//  LocationLog
//
//  Created by Quinn on 22/09/2021.
//

import UIKit
import MapKit

protocol HistoryVCShowDateProtocol {
    func goToDate(dateUTC: Date)
}



class SearchViewController: UIViewController {

    let searchCompleter = MKLocalSearchCompleter()
    var searchCompleterResults = [MKLocalSearchCompletion]()
    var criticalRect: CGRect?
    var fullSearchResults = [LogItem]()
    var uniqueDatesForTableView = [DateItem]()
    var delegate: HistoryVCShowDateProtocol?
    var geoSearchVC: GeoSearchViewController?
    var geoContainerViewShown = false
    let annotationsLimit = 10000
    lazy var geoContainerViewOffset = geoContainerView.frame.height + 50
    var annotationsLimitReached = false

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var shadedView: UIView!
    @IBOutlet weak var sizingFrame: UIView!
    @IBOutlet weak var searchButton: LLButton!
    @IBOutlet weak var clearButton: LLButton!
    @IBOutlet weak var viewDateButton: LLButton!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var geoContainerView: UIView!
    @IBOutlet weak var containerViewCenterY: NSLayoutConstraint!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBAction func searchButtonTapped(_ sender: LLButton) {
        cancelGeoViewFromThisVC()
        performSearch()
    }
    
    @IBAction func clearButtonTapped(_ sender: LLButton) {
        cancelGeoViewFromThisVC()
        clearMapAndTableView()
    }
    
    @IBAction func viewDateButtonTapped(_ sender: LLButton) {
        if geoContainerViewShown {
            hideGeoContainerView()
            geoSearchVC?.searchBar.endEditing(true)
        }  else {
            showGeoContainerView()
            geoSearchVC?.searchBar.becomeFirstResponder()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureShadedView()
        configureSizingFrame()
        configureMapView()
        configureSearchTableView()
        clearButton.turnOff()
        configureCriticalRect()
        updateInfoLabelText()
        containerViewCenterY.constant = -geoContainerViewOffset
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.mapType         = PersistenceManager.getMapTypePreference()
    }
    
    // Manually correct shaded view (due to bug in layout?)
    func configureShadedView() {
        shadedView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shadedView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor),
            shadedView.widthAnchor.constraint(equalTo: view.widthAnchor),
            shadedView.topAnchor.constraint(equalTo: mapView.topAnchor),
            shadedView.bottomAnchor.constraint(equalTo: mapView.bottomAnchor)
        ])
        view.layoutIfNeeded()
    }
    
    
    func configureCriticalRect() {
        // To identify top padding of safe area inset
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let topPadding = window?.safeAreaInsets.top ?? 0
        
        let distanceFromEdge    = Double(20)
        let distanceFromTop     = Double(5) + topPadding
        let distanceFromBottom  = Double(40) + topPadding
        let originX             = distanceFromEdge
        let originY             = Double(view.safeAreaInsets.top) + distanceFromTop
        let width               = view.bounds.width - (2 * originX)
        let height              = view.frame.height - sizingFrame.frame.height - originY - distanceFromBottom
        criticalRect            = CGRect(x: originX, y: originY, width: width, height: height)
        shadedView.makeClearHole(rect: criticalRect!)
    }

    
    func configureSizingFrame() {
        sizingFrame.layer.cornerRadius  = 20
        sizingFrame.clipsToBounds       = true
        sizingFrame.layer.borderWidth   = 2
        sizingFrame.layer.borderColor   = Colors.llPink.cgColor
    }


    func configureMapView() {
        // Move the logo and legal link is a result of 20-pixel rounded corners of sizing frame
        mapView.layoutMargins               = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        //Shift centre of map to comepnsate for slight offset due to 20-pixel rounded corners of sizing frame
        let currentOffsetforSizingFrame     = CGFloat(20)
        let currentMapHeight                = mapView.frame.height
        let percentageOffset                = currentOffsetforSizingFrame / currentMapHeight
        let latitudeSpan                    = mapView.region.span.latitudeDelta.magnitude
        let offsetLatitude                  = latitudeSpan * Double(percentageOffset)
        let currentOriginLatitude           = mapView.region.center.latitude.magnitude
        let newOriginalLatitude             = currentOriginLatitude - (offsetLatitude/2)
        let amendedOriginLatitude           = CLLocationDegrees(Float(newOriginalLatitude))
        mapView.region.center.latitude      = amendedOriginLatitude
        mapView.delegate                    = self
    }
    
    
    func configureSearchTableView() {
        searchTableView.dataSource    = self
        searchTableView.delegate      = self
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier     == Segues.geoSearchSegue {
            if let destVC       = segue.destination as? GeoSearchViewController {
                geoSearchVC     = destVC
                destVC.delegate = self
                destVC.region   = mapView.region
            }
        }
    }
    
    
    func configureGeoContainerView() {
        containerViewCenterY.constant = 0
    }
    
    
    func showGeoContainerView() {
        containerViewCenterY.constant           = -geoContainerViewOffset
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) { [weak self] in
            guard let self                      = self else { return }
            self.containerViewCenterY.constant  = 0
            self.view.layoutIfNeeded()
        }
        viewDateButton.togglePressed()
        geoContainerViewShown                   = true
    }

    
    func hideGeoContainerView() {
        containerViewCenterY.constant           = 0
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) { [weak self] in
            guard let self = self else { return }
            self.containerViewCenterY.constant  = -self.geoContainerViewOffset
            self.view.layoutIfNeeded()
        }
        viewDateButton.togglePressed()
        geoContainerViewShown                   = false
    }
    
    
    func jumpToCompletionLocation(to mkCompletion: MKLocalSearchCompletion) {
        //Fetch actual location item from 'completion' item
        SearchHelper.getRegionFromCompletion(mkCompletion: mkCompletion) {
            [weak self] region in
            guard let self  = self else { return }
            guard region    != nil else { return }
            self.mapView.setRegion(region!, animated: true)
        }
    }
    
    
    func enableClearButton() {
        clearButton.isUserInteractionEnabled    = true
        clearButton.alpha                       = 1
    }
    
    
    func disableClearButton() {
        clearButton.isUserInteractionEnabled    = false
        clearButton.alpha                       = 0.3
    }
    
    
    func performSearch() {
        clearMapAndTableView()
        guard let criticalRect  = criticalRect else { return }
        let searchRect          = MapManager.calculateSearchMapRect(searchSquare: criticalRect, mapView: mapView)
        let polygon             = MapManager.getPolygonFromRect(rect: searchRect)
        mapView.addOverlay(polygon)
        fullSearchResults       = CoreDataManager.fetchLogItemsWithinRect(within: searchRect)
        uniqueDatesForTableView = getUniqueDateItemsFromLogItems(logItems: fullSearchResults)
        updateMapAnnotations()
        searchTableView.reloadData()
        clearButton.turnOn()
        updateInfoLabelText()
    }
    
    
    func updateMapAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        annotationsLimitReached = false
        var annotations                 = [LLAnnotation]()
        if searchTableView.indexPathForSelectedRow == nil {
            // Nothing selected, so annotations from full search results
            annotations                 = MapManager.annotationsFromLogItems(from: fullSearchResults, for: .search)
        } else {
            // Date selected in TableView, so annotations just from that date only
            let row = searchTableView.indexPathForSelectedRow!.row
            let dateString              = uniqueDatesForTableView[row].dateAsString
            var filteredLogItems        = [LogItem]()
            for item in fullSearchResults {
                if item.dateAsString    == dateString {
                    filteredLogItems.append(item)
                }
            }
            annotations                 = MapManager.annotationsFromLogItems(from: filteredLogItems, for: .search)
        }
        if annotations.count > annotationsLimit {
            annotations.removeAll()
            annotationsLimitReached = true
        }
        mapView.addAnnotations(annotations)
    }

    
    func getUniqueDateItemsFromLogItems(logItems: [LogItem]) -> [DateItem] {
        var dateItemsToReturn                                   = [DateItem]()
        var dictionaryOfUniqueLogItemDates                      = [String:LogItem]()
        for item in logItems {
            if item.dateAsString                                != nil {
            dictionaryOfUniqueLogItemDates[item.dateAsString!]  = item
            }
        }
        for uniqueItem in dictionaryOfUniqueLogItemDates {
            if  uniqueItem.value.dateAndTimeUTC                 != nil &&
                uniqueItem.value.dateAsString                   != nil &&
                uniqueItem.value.weekdayAsString                != nil {
                let newDateItem                                 = DateItem(
                    dateAndTimeUTC: uniqueItem.value.dateAndTimeUTC!,
                    dateAsString: uniqueItem.value.dateAsString!,
                    weekdayAsString: uniqueItem.value.weekdayAsString!)
                dateItemsToReturn.append(newDateItem)
            }
        }
        dateItemsToReturn.sort {
            $0.dateAndTimeUTC > $1.dateAndTimeUTC
        }
        return dateItemsToReturn
    }
    
    
    func clearMapAndTableView() {
        mapView.removeAnnotations(mapView.annotations)
        annotationsLimitReached = false
        mapView.removeOverlays(mapView.overlays)
        fullSearchResults.removeAll()
        uniqueDatesForTableView.removeAll()
        searchTableView.reloadData()
        clearButton.turnOff()
        updateInfoLabelText()
    }
    
    
    func viewSelectedDate() {
        guard searchTableView.indexPathForSelectedRow?.row  != nil else { return }
        let date = uniqueDatesForTableView[searchTableView.indexPathForSelectedRow!.row].dateAndTimeUTC
        delegate?.goToDate(dateUTC: date)
        tabBarController?.selectedIndex = 0
    }
    
        
    func updateInfoLabelText() {
        infoLabel.textColor                 = .gray
        if clearButton.isEnabled            == false {
            infoLabel.text                  = "Press 'Search' to view logs within the area shown"
        } else if annotationsLimitReached   == true {
            infoLabel.text                  = "Too many logs to display on map at once"
            infoLabel.textColor             = Colors.llPink
        }
        else if searchTableView.indexPathForSelectedRow != nil {
            let numberOfPins                = String(mapView.annotations.count)
            infoLabel.text                  = "Showing the \(numberOfPins) logs for selected date"
        }
        else {
            let numberOfPins                = String(mapView.annotations.count)
            let numberOfDates               = String(uniqueDatesForTableView.count)
            infoLabel.text                  = "Showing all \(numberOfPins) logs for \(numberOfDates) dates"
        }
    }
    
    
    func cancelGeoViewFromThisVC() {
        if geoContainerViewShown { hideGeoContainerView() }
        geoSearchVC?.searchBar.resignFirstResponder()
    }
}



extension SearchViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uniqueDatesForTableView.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell        = tableView.dequeueReusableCell(withIdentifier: Identifiers.searchResultsCell) as! LLSearchTableViewCell
        cell.dateItem   = uniqueDatesForTableView[indexPath.row]
        cell.configure()
        cell.delegate   = self
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        cancelGeoViewFromThisVC()
        if tableView.indexPathForSelectedRow == indexPath {
            tableView.deselectRow(at: indexPath, animated: false)
            updateMapAnnotations()
            updateInfoLabelText()
            return nil
        }
        return indexPath
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateMapAnnotations()
        updateInfoLabelText()
    }
}



extension SearchViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer                    = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor            = Colors.llPink
        renderer.lineWidth              = 2
        return renderer
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is LLAnnotation else { return nil }
        let annotationView              = MapManager.configureAnnotationView(for: annotation, in: mapView, for: .search)
        return annotationView
    }

    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation            = view.annotation as? LLAnnotation else { return }
        delegate?.goToDate(dateUTC: annotation.dateAndTimeUTC)
        tabBarController?.selectedIndex = 0
    }
}



extension SearchViewController: SearchVCGeoSearchProtocol {

    func cancelPressed() {
        hideGeoContainerView()
    }
    
    
    func geoLocationPicked(completionResult: MKLocalSearchCompletion, name: String) {
        hideGeoContainerView()
        SearchHelper.getRegionFromCompletion(mkCompletion: completionResult) {
            [weak self] region in
            guard let self  = self else { return }
            guard region    != nil else { return }
            self.mapView.setRegion(region!, animated: false)
            self.searchButtonTapped(self.searchButton)
        }
    }
}



extension SearchViewController: SearchTableViewProtocol {
    func didTapButton(date: Date) {
        cancelGeoViewFromThisVC()
        delegate?.goToDate(dateUTC: date)
        tabBarController?.selectedIndex = 0
    }
}
