//
//  TableViewController.swift
//  Restaurant_Search_Machine
//
//  Created by mac03 on 2020/6/5.
//  Copyright © 2020 mac03. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import GooglePlaces
import GoogleMaps

var search_distance:Int = 1500
var distance_sort: Bool = true
var rating_sort: Bool = false
var curlocation: CLLocation? = nil


class DetailCell: UITableViewCell{
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var open: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var shopName: UILabel!
    @IBOutlet weak var address: UILabel!
}


class TableViewController: UITableViewController , CLLocationManagerDelegate,MKMapViewDelegate,URLSessionDelegate, URLSessionDownloadDelegate, UIPopoverPresentationControllerDelegate{
    var dataArray = [AnyObject]()
    var shopList:[shopdata] = []
    var displayList:[shopdata] = []
    var popover = 1
    struct shopdata{
        var name: String
        var address: String
        var id: String
        var photo = ""
        var distance: Double = 0.0
        var rating = 0.0
        var open = 0
        var lat: Double
        var lng: Double
        var image: UIImage? = nil
       }


    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
       return .none
    }
    @IBAction func LuckyDrawBtn(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "LuckyDrawSegue", sender: self)
    }
    
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var DrawBtn: UIButton!
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // 處理Json數據
        do {
            let jsonResult = try JSONSerialization.jsonObject(with:  NSData(contentsOf: location as! URL)! as Data, options: JSONSerialization.ReadingOptions()) as! [String : AnyObject]
            dataArray = jsonResult["results"] as! [AnyObject]
            shopList.removeAll()
            for p in dataArray{
                var newshop: shopdata = shopdata( name:p["name"] as? String ?? "",  address: p["vicinity"] as? String ?? "", id:p["place_id"] as? String ?? "", distance: 0.0,  lat: ((p["geometry"] as AnyObject)["location"] as AnyObject)["lat"] as? Double ?? 0, lng: ((p["geometry"] as AnyObject)["location"] as AnyObject)["lng"] as? Double ?? 0)
                let targetLocation = CLLocation (latitude: ((p["geometry"] as! AnyObject)["location"] as! AnyObject)["lat"] as! Double, longitude: ((p["geometry"] as! AnyObject)["location"] as! AnyObject)["lng"] as! Double)
                let d = Double(currentLocation.distance(from: targetLocation))
                newshop.distance = d
                
                if  (p["opening_hours"] as AnyObject)["open_now"] != nil{
                    newshop.open = (p["opening_hours"] as AnyObject)["open_now"] as? Int ?? 0
                }
                if  p["rating"] != nil{
                    newshop.rating = p["rating"] as? Double ?? 0.0
                }
                
                if p["photos"]! != nil{
                    newshop.photo = (p["photos"] as! [AnyObject])[0]["photo_reference"] as? String ?? ""
                    let url = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=120&photoreference="+newshop.photo+"&key=" //enter the key for Google Map API
                    newshop.image = setImage(from: url)

                }else{
                    newshop.image = UIImage(named: "restaurant.png")!
                }
                shopList.append(newshop)

            }
            
            self.tableView.reloadData()
            self.refreshControl!.endRefreshing()
            LuckyDrawBtn.isEnabled = true
            filterBtn.isEnabled = true
            DrawBtn.isEnabled = true
        } catch let error as NSError {
            print(error)
        }
    }
    
    
    
    var locationManager = CLLocationManager()
    var  currentLocation = CLLocation()

    @IBOutlet weak var LuckyDrawBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefault = UserDefaults()
        if userDefault.value(forKey: "placeId") == nil{
            userDefault.setValue([],forKey: "placeId" )
        }
        
        if userDefault.value(forKey: "placeName") == nil{
            userDefault.setValue([],forKey: "placeName" )
        }
        
        if userDefault.value(forKey: "placeAddress") == nil{
            userDefault.setValue([],forKey: "placeAddress" )
        }
        
        if userDefault.value(forKey: "placeLat") == nil{
            userDefault.setValue([],forKey: "placeLat" )
        }
        
        if userDefault.value(forKey: "placeLog") == nil{
            userDefault.setValue([],forKey: "placeLog" )
        }
        
        LuckyDrawBtn.isEnabled = false
        filterBtn.isEnabled = false
        
        // Initialize the location manager.
        // Ask for Authorisation from the User.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        refreshControl = UIRefreshControl()
        self.tableView.addSubview(refreshControl!)
        refreshControl!.addTarget(self, action: #selector(loadData), for: UIControl.Event.valueChanged)
        refreshControl!.beginRefreshing()

        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                
            self.loadData()

        }

        
    }
    
    @objc func reload(){
        self.tableView.reloadData()
    }
    
    @objc func loadData(){
        LuckyDrawBtn.isEnabled = false
        filterBtn.isEnabled = false
        
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?language=zh-TW&location="+String(currentLocation.coordinate.latitude)+","+String(currentLocation.coordinate.longitude)+"&radius="+String(search_distance)+"&type=restaurant&key=")//enter the key for Google Map API
        
        let sessionWithConfigure = URLSessionConfiguration.default
        
        let session = URLSession(configuration: sessionWithConfigure, delegate: self as! URLSessionDelegate, delegateQueue: OperationQueue.main)
        
        let dataTask = session.downloadTask(with: url! as URL)
        
        dataTask.resume()
        self.tableView.reloadData()
        
    }
    
    
    func setImage(from url: String) -> UIImage{
        let imageURL = URL(string: url)
        let imageData = try? Data(contentsOf: imageURL!)
        let image = UIImage(data: imageData!)
        return image!
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = (manager.location)!
        curlocation = currentLocation
        
    }

    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        displayList.removeAll()
        for shop in shopList{
            if Float(shop.distance)<=Float(search_distance){
                displayList.append(shop)
            }
        }
        
        if distance_sort == true{
            displayList.sort { (lhs, rhs) in return lhs.distance < rhs.distance }
        }
        if rating_sort == true{
            displayList.sort { (lhs, rhs) in return lhs.rating < rhs.rating }
        }
        
        return displayList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! DetailCell
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell") as! DetailCell
        }
        
        cell.accessoryType = .disclosureIndicator
        cell.shopName.text = displayList[indexPath.row].name as? String
        if displayList[indexPath.row].distance < 1000{
            cell.detail.text = "距離: <1km"
        }else if displayList[indexPath.row].distance > 10000{
            cell.detail?.text = "距離: >10km"
        }else{
            cell.detail?.text = "距離: "+String(format: "%.2f", displayList[indexPath.row].distance/1000)+" km"
        }
        
        
        
        
        cell.shopName.text = displayList[indexPath.row].name
        
        if displayList[indexPath.row].rating == 0.0{
            cell.rate.text = "No Review"
        }else{
            cell.rate.text = "⭐ "+String(displayList[indexPath.row].rating)
        }
        
        cell.address.text = displayList[indexPath.row].address
        
        if displayList[indexPath.row].open == 0{
            cell.open.text = "Closed"
            cell.open.textColor = UIColor(red: 255, green: 0, blue: 0, alpha: 1)
        }else{
            cell.open.text = "Open"
            cell.open.textColor = UIColor(red: 0, green: 255, blue: 0, alpha: 1)
        }
        
        cell.imageView!.image = displayList[indexPath.row].image

        return cell
    }
    
    var path = 0
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        path = indexPath.row
        performSegue(withIdentifier: "mySegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mySegue"{
            let vc_text = segue.destination as! ContentViewController
            vc_text.id = displayList[path].id
            vc_text.targetlog = displayList[path].lng
            vc_text.targetlat = displayList[path].lat
            vc_text.targetName = displayList[path].name
            vc_text.currentlat = currentLocation.coordinate.latitude
            vc_text.currentlog = currentLocation.coordinate.longitude

        }else if segue.identifier == "LuckyDrawSegue"{
            let vc_text = segue.destination as! LuckyDrawViewController
            var newlist:[String] = []
            for s in displayList{
                newlist.append(s.name)
            }
            vc_text.data = newlist
            var newlist2:[CLLocationCoordinate2D] = []
            for s in displayList{
                newlist2.append(CLLocationCoordinate2D(latitude: s.lat, longitude: s.lng))
            }
            vc_text.coordinateList = newlist2
        }else{
           segue.destination.preferredContentSize = CGSize(width: 300, height: 180)
           segue.destination.popoverPresentationController?.delegate = self
        }
     }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    

}

