//
//  viewFullViewController.swift
//  Restaurant_Search_Machine
//
//  Created by mac03 on 2020/6/19.
//  Copyright © 2020 mac03. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
class viewFullViewController: UIViewController {
    
    var targetlat: Double = 0.0
    var targetlog: Double = 0.0
    var currentlog: Double = 0.0
    var currentlat: Double = 0.0
    var targetName: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: targetlat, longitude: targetlog, zoom: 12)
        let mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        self.view.addSubview(mapView)

        // Creates a marker in the center of the map.
        let position = CLLocationCoordinate2D(latitude: targetlat, longitude: targetlog)  // lat & long must be Double
        let userposition = CLLocationCoordinate2D(latitude: currentlat, longitude: currentlog)  // lat & long must be Double

        let marker = GMSMarker(position: position)
        marker.title = targetName
        marker.map = mapView
        mapView.isMyLocationEnabled = true

        // Do any additional setup after loading the view.
    }
    

    @IBAction func toGoogleMap(_ sender: UIButton) {
        let url = URL(string: "comgooglemaps://?saddr=&daddr="+String(targetlat)+","+String(targetlog)+"&directionsmode=driving")
        
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            // 若手機沒安裝 Google Map App 則導到 App Store(id443904275 為 Google Map App 的 ID)
            let appStoreGoogleMapURL = URL(string: "itms-apps://itunes.apple.com/app/id585027354")!
            UIApplication.shared.open(appStoreGoogleMapURL, options: [:], completionHandler: nil)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
