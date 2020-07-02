//
//  ViewController.swift
//  StreetView
//
//  Created by 池田壮真 on 2020/06/20.
//  Copyright © 2020 Soma. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController, GMSMapViewDelegate {
    
    @IBOutlet weak var panoramaView: GMSPanoramaView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        panoramaView.moveNearCoordinate(CLLocationCoordinate2DMake(-33.732, 150.312))
        // Create a marker at the Eiffel Tower
        let position = CLLocationCoordinate2DMake(-33.732, 150.312)
        let marker = GMSMarker(position: position)

        // Add the marker to a GMSPanoramaView object named panoView
        marker.panoramaView = panoramaView
//        panoView.camera = GMSPanoramaCamera(heading: 120, pitch: -10, zoom: 1)

    }


}

