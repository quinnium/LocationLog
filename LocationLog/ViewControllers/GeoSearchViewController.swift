//
//  GeoSearchViewController.swift
//  LocationLog
//
//  Created by Quinn on 09/11/2021.
//

import UIKit
import MapKit

protocol SearchVCGeoSearchProtocol {
    func geoLocationPicked(completionResult: MKLocalSearchCompletion, name: String)
    func cancelPressed()
}



class GeoSearchViewController: UIViewController {

    let searchCompleter         = MKLocalSearchCompleter()
    var searchCompleterResults  = [MKLocalSearchCompletion]()
    var region: MKCoordinateRegion?
    var delegate: SearchVCGeoSearchProtocol?

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func cancelButton(_ sender: Any) {
        searchBar.resignFirstResponder()
        delegate?.cancelPressed()
    }
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchBar()
        configureSearchCompleter()
        configureTableView()
    }

    
    func configureSearchBar() {
        searchBar.delegate                          = self
        searchBar.searchTextField.placeholder       = "Search for location"
        searchBar.searchBarStyle                    = .minimal
    }
    
    
    func configureSearchCompleter() {
        searchCompleter.resultTypes     = .query
        searchCompleter.delegate        = self
        guard region != nil else { return }
        searchCompleter.region          = region!
    }
    
    
    func configureTableView() {
        tableView.dataSource            = self
        tableView.delegate              = self
    }
    
    
    func dismissKeyboard() {
        searchBar.endEditing(true)
    }
}



extension GeoSearchViewController: UISearchBarDelegate {
       
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText                   == "" {
            searchCompleterResults.removeAll()
            tableView.reloadData()
        }
        searchCompleter.queryFragment   = searchText
    }
}



extension GeoSearchViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchCompleterResults = completer.results
        tableView.reloadData()
    }
}



extension GeoSearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchCompleterResults.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell        = tableView.dequeueReusableCell(withIdentifier: Identifiers.geoSearchResultsCell, for: indexPath)
        let cellLabel   = cell.viewWithTag(1) as! UILabel
        let completion  = searchCompleterResults[indexPath.row]
        cellLabel.text  = SearchHelper.getStringFromCompletion(completion: completion)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mkCompletion    = searchCompleterResults[indexPath.row]
        let text            = (tableView.cellForRow(at: indexPath)?.viewWithTag(1) as? UILabel)?.text ?? ""
        delegate?.geoLocationPicked(completionResult: mkCompletion, name: text)
        tableView.deselectRow(at: indexPath, animated: true)
        dismissKeyboard()
    }
}
