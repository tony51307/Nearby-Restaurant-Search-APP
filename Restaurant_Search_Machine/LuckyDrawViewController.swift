//
//  LuckyDrawViewController.swift
//  Restaurant_Search_Machine
//
//  Created by mac03 on 2020/6/18.
//  Copyright © 2020 mac03. All rights reserved.
//

import UIKit
import CoreLocation

class LuckyDrawViewController: UIViewController,UIPickerViewAccessibilityDelegate,UIPickerViewDataSource  {
    var pickerView:UIPickerView!
    var pickerViewDataSize:Int!
    var pickerViewData = [String]()
    
    var data:[String] = []
    var coordinateList:[CLLocationCoordinate2D] = []

    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
      return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      return pickerViewDataSize
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      return pickerViewData[row % pickerViewData.count]
    }
    
    func setUpPickerView(data:[String]) {
      pickerViewData = data
      pickerView = UIPickerView()
      pickerView.dataSource = self
      pickerView.delegate = self
      pickerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 3)
        pickerView.isUserInteractionEnabled = false
      pickerView.center = view.center
      view.addSubview(pickerView)
      pickerViewDataSize = 100 * pickerViewData.count
      pickerView.selectRow(pickerViewDataSize / 2, inComponent: 0, animated: false)
    }
    
    var result = ""
    
    func randomPicker() {

      let position = self.pickerViewDataSize / 2 +   pickerView.selectedRow(inComponent: 0) % self.pickerViewData.count
      self.pickerView.selectRow(position, inComponent: 0, animated: false)
      var row = self.pickerViewDataSize / 2
      let random = row + Int(arc4random() % UInt32(pickerViewDataSize / pickerViewData.count))
      Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
        if row < random {
          row += 1
          self.pickerView.selectRow(row, inComponent: 0, animated: true)
        } else {
          timer.invalidate()
            let controller = UIAlertController(title: "Let's go!", message: self.pickerViewData[row % self.pickerViewData.count], preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Direct me!", style: .default) { (_) in
                let url = URL(string: "comgooglemaps://?saddr=&daddr="+String(self.coordinateList[row % self.pickerViewData.count].latitude)+","+String(self.coordinateList[row % self.pickerViewData.count].longitude)+"&directionsmode=driving")
                      
                      if UIApplication.shared.canOpenURL(url!) {
                          UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                      } else {
                          // 若手機沒安裝 Google Map App 則導到 App Store(id443904275 為 Google Map App 的 ID)
                          let appStoreGoogleMapURL = URL(string: "itms-apps://itunes.apple.com/app/id585027354")!
                          UIApplication.shared.open(appStoreGoogleMapURL, options: [:], completionHandler: nil)
                      }
            }
            controller.addAction(okAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            controller.addAction(cancelAction)
            self.present(controller, animated: true, completion: nil)
        }
      }
    }

    
   override func viewDidLoad() {
       super.viewDidLoad()
    setUpPickerView(data: data)
       // Do any additional setup after loading the view.
    drawBtn.titleLabel?.adjustsFontSizeToFitWidth = true
   }

    @IBOutlet weak var drawBtn: UIButton!
    
    
    
    


    
    @IBAction func pickButton(_ sender: UIButton) {
        randomPicker()
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



    
