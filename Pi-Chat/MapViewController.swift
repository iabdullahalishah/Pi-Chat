//
//  MapViewController.swift
//  Pi-Chat
//
//  Created by Abdullah  Ali Shah on 31/08/2018.
//  Copyright © 2018 Abdullah  Ali Shah. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var location: CLLocation!
    var spann = MKCoordinateSpan()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Map"
        spann.longitudeDelta = 0.03
        spann.latitudeDelta = 0.03
        print("Span value is \(spann)")
        setupUI()
        createRightButton()
        // Do any additional setup after loading the view.
    }

    //MARK: Setup UI
    func setupUI() {
        var region = MKCoordinateRegion()
        region.center.longitude = location.coordinate.longitude
        region.center.latitude = location.coordinate.latitude
        region.span.latitudeDelta = 0.01
        region.span.longitudeDelta = 0.01
        mapView.setRegion(region, animated: false)
        mapView.showsUserLocation = true
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        mapView.addAnnotation(annotation)
    }
    
    //MARK: Open in Maps
    func createRightButton() {
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Open In Maps", style: .plain, target: self, action: #selector(self.openInMap))]
    }
    
    @objc func openInMap() {
        let coordinatews = location.coordinate
        let regionSpan = MKCoordinateRegion(center: coordinatews, span: spann)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinatews, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "User's Location"
        mapItem.openInMaps(launchOptions: options)
    }
    
    
    
}
