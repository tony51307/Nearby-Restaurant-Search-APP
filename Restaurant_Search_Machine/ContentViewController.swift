//
//  ContentViewController.swift
//  Restaurant_Search_Machine
//
//  Created by mac03 on 2020/6/17.
//  Copyright © 2020 mac03. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import CoreLocation


class ContentViewController: UIViewController,URLSessionDelegate, URLSessionDownloadDelegate, UIPopoverPresentationControllerDelegate{
   
    let userDefault = UserDefaults()
    private let locationManager = CLLocationManager()

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var opentime: UILabel!
    @IBOutlet weak var walktime: UILabel!
    @IBOutlet weak var loveBtn: UIButton!
    
    @IBOutlet weak var openTimeBtn: UIButton!
    @IBOutlet weak var phone: UIButton!
    
    @IBOutlet weak var reviewBtn: UIButton!
    
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    
    @IBAction func seeReview(_ sender: UIButton) {
        
    }
    
    @IBAction func previousPhoto(_ sender: UIButton) {
        if photoDisplayNum != 0 {
            photoDisplayNum = photoDisplayNum - 1
            photo.image = photoList[photoDisplayNum]
        }else{
            photoDisplayNum = photoList.count - 1
            photo.image = photoList[photoDisplayNum]
        }
    }
    @IBAction func nextPhoto(_ sender: UIButton) {
        if photoDisplayNum != photoList.count - 1 {
            photoDisplayNum = photoDisplayNum + 1
            photo.image = photoList[photoDisplayNum]
        }else{
            photoDisplayNum = 0
            photo.image = photoList[photoDisplayNum]
        }
    }
    
    @IBAction func call(_ sender: UIButton) {
        let phoneURL = NSURL(string: ("tel://" + phone.currentTitle!).replacingOccurrences(of: " ", with: ""))
        let alert = UIAlertController(title: ("Call " + phone.currentTitle! + "?"), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Call", style: .default, handler: { (action) in
            UIApplication.shared.open(phoneURL as! URL, options: [:], completionHandler: nil)
            }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
        
    @IBOutlet weak var viewFullBtn: UIButton!
    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var viewOpenBtn: UIButton!
    @IBOutlet weak var callBtn: UIButton!
    
    
    var targetlat: Double = 0.0
    var targetlog: Double = 0.0
    var currentlog: Double = 0.0
    var currentlat: Double = 0.0
    var targetName: String = ""
    var photoList: [UIImage] = []
    var id: String = ""
    var currentAdress: String = ""
    var photoDisplayNum = 0
    var processTag: Int = 1
    var distance: Double = 0.0
    var isopen = 0
    var weekday_text:[String] = []
    var reviewList: [AnyObject] = []
    
    @IBAction func viewOpenTime(_ sender: UIButton) {
        performSegue(withIdentifier: "openTimesgue", sender: self)
    }
    @IBAction func lovePlace(_ sender: UIButton) {
        var idList = userDefault.value(forKey: "placeId") as! [String]
        var nameList = userDefault.value(forKey: "placeName") as! [String]
        var latList = userDefault.value(forKey: "placeLat") as! [Double]
        var logList = userDefault.value(forKey: "placeLog") as! [Double]
        if idList.contains(id){
            if let index = idList.firstIndex(of: id) {
                idList.remove(at: index)
                userDefault.setValue(idList, forKey: "placeId")
                nameList.remove(at: index)
                userDefault.setValue(nameList, forKey: "placeName")
                latList.remove(at: index)
                userDefault.setValue(latList, forKey: "placeLat")
                logList.remove(at: index)
                userDefault.setValue(logList, forKey: "placeLog")
            }
            
            let image = UIImage(named: "uncolored-love.png")
            loveBtn.setImage(image, for: .normal)
        }else{
            idList.append(id)
            userDefault.setValue(idList, forKey: "placeId")
            nameList.append(name.text!)
            userDefault.setValue(nameList, forKey: "placeName")
            latList.append(targetlat)
            userDefault.setValue(latList, forKey: "placeLat")
            logList.append(targetlog)
            userDefault.setValue(logList, forKey: "placeLog")
            let image = UIImage(named: "colored-love.png")
            loveBtn.setImage(image, for: .normal)
        }
    }
    
    
    @IBOutlet weak var mapView: GMSMapView!
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openTimesgue"{
           segue.destination.preferredContentSize = CGSize(width: 300, height: 180)
           segue.destination.popoverPresentationController?.delegate = self
           
           let vc_text = segue.destination as! OpenTimeViewController
           vc_text.OpenTimeList = weekday_text
            vc_text.numOfrow = weekday_text.count
        }else if segue.identifier == "toReview"{
            let vc_text = segue.destination as! ReviewTableViewController
            vc_text.reviewlist = reviewList
            vc_text.rating = rate.text!
        }else{
            let vc_text = segue.destination as! viewFullViewController
            vc_text.targetlat = targetlat
            vc_text.targetlog = targetlog
            vc_text.currentlog = currentlog
            vc_text.currentlat = currentlat
            vc_text.targetName = targetName

        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadIndicator.startAnimating()
        let targetLocation = CLLocation (latitude: targetlat, longitude:targetlog)
        distance = Double(curlocation!.distance(from: targetLocation))
        let List = userDefault.value(forKey: "placeId") as! [String]
        if List.contains(id){
            let image = UIImage(named: "colored-love.png")
            loveBtn.setImage(image, for: .normal)
        }
        viewOpenBtn.isEnabled = false
        callBtn.isEnabled = false
        viewFullBtn.isEnabled = false
        loadData()
        if isopen == 1{
            opentime.text = "⏰ Open"
            opentime.textColor = UIColor(red: 0, green: 255, blue: 0, alpha: 1)
            }else{
            opentime.text = "⏰ Closed"
            opentime.textColor = UIColor(red: 255, green: 0, blue: 0, alpha: 1)
        }

        let camera = GMSCameraPosition.camera(withLatitude: targetlat, longitude: targetlog, zoom: 15)
        mapView.camera = camera
        let position = CLLocationCoordinate2D(latitude: targetlat, longitude: targetlog)  // lat & long must be Double
        let marker = GMSMarker(position: position)
        marker.title = targetName
        marker.map = mapView
        mapView.isMyLocationEnabled = true
        // Do any additional setup after loading the view.
    }

   
    
    @objc func loadData(){
           processTag = 1
           let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/details/json?language=zh-TW&place_id="+id+"&key=") //enter the key for Google Map API
           
           let sessionWithConfigure = URLSessionConfiguration.default
           
        let session = URLSession(configuration: sessionWithConfigure, delegate: self as URLSessionDelegate, delegateQueue: OperationQueue.main)
           
           let dataTask = session.downloadTask(with: url! as URL)
           
           dataTask.resume()
           
       }
    
    func setImage(from url: String) {
        guard let imageURL = URL(string: url) else { return }
        // just not to cause a deadlock in UI!
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: imageURL) else { return }
            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                self.photoList.append(image!)
            }
        }
    }


    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
           // 處理Json數據
               do {
                   let jsonResult = try JSONSerialization.jsonObject(with:  NSData(contentsOf: location as! URL)! as Data, options: JSONSerialization.ReadingOptions()) as! [String : AnyObject]
                   name.text = (jsonResult["result"] as! AnyObject)["name"] as! String
                   address.text = "📍 "+((jsonResult["result"] as! AnyObject)["formatted_address"] as! String)
                if (jsonResult["result"] as! AnyObject)["opening_hours"]! != nil {
                       weekday_text = ((jsonResult["result"] as! AnyObject)["opening_hours"] as! AnyObject)["weekday_text"] as! [String]
                        isopen = ((jsonResult["result"] as! AnyObject)["opening_hours"] as! AnyObject)["open_now"] as! Int
                }else{
                    openTimeBtn.isHidden = true
                    opentime.text = "⏰ No open time available"
                }
                    if (jsonResult["result"] as! AnyObject)["international_phone_number"]! != nil {
                        phone.isEnabled = true
                        phone.setTitle((jsonResult["result"] as! AnyObject)["international_phone_number"] as! String, for: .normal)
                    }else{
                        phone.setTitle("No phone call available", for: .normal)
                        phone.setTitleColor(UIColor(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
                        phone.isEnabled = false
                    }
                if (jsonResult["result"] as! AnyObject)["photos"]! != nil{
                    for p in (jsonResult["result"] as! AnyObject)["photos"] as! [AnyObject]{
                        let url =  "https://maps.googleapis.com/maps/api/place/photo?maxwidth=1000&photoreference="+(p["photo_reference"] as! String)+"&key="//enter the key for Google Map API
                        let imageURL = URL(string: url)!
                        let imageData = try Data(contentsOf: imageURL)
                        let image = UIImage(data: imageData)
                        photoList.append(image!)
                    }
                }else{
                    photoList.append(UIImage(named: "restaurant.png")!)
                }
                photo.image = photoList[0]

                if (jsonResult["result"] as! AnyObject)["rating"]! != nil{
                    rate.text = "🌟 "+String((jsonResult["result"] as! AnyObject)["rating"] as! Double)
                    reviewList = (jsonResult["result"] as! AnyObject)["reviews"] as! [AnyObject]
                }else{
                    rate.text = "🌟 No rate available"
                }
                if (Double(distance)/1.5)/60 < 60{
                    walktime.text = "🚶‍♂️ " + String(format: "%.1f", (distance/1.5)/60) + " min"
                }else{
                    walktime.text = "🚶‍♂️ " + String(Int(((distance/1.5)/60)/60)) + " hour" + String(Int((distance/1.5)/60) % 60) + " min"
                }
                viewOpenBtn.isEnabled = true
                callBtn.isEnabled = true
                viewFullBtn.isEnabled = true
                reviewBtn.isEnabled = true
                 viewOpenBtn.setTitle("View open time", for: .normal)
                reviewBtn.setTitle("See reviews", for: .normal)
                loadIndicator.stopAnimating()

                } catch let error as NSError {
                   print(error)
               }
       }
    
    
        func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
           return .none
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
