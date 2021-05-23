//
//  PopoverViewController.swift
//  Restaurant_Search_Machine
//
//  Created by CSIE_MAC03 on 2020/6/10.
//  Copyright © 2020 mac03. All rights reserved.
//

import UIKit

class PopoverViewController: UIViewController {

    @IBOutlet weak var Distance_Stepper: UIStepper!
    @IBOutlet weak var distance_display: UILabel!
    @IBOutlet weak var Distance_Switch: UISwitch!
    
    @IBOutlet weak var Rating_Switch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        distance_display.text = "Search Distance: "+String(search_distance) + " m"
        Distance_Stepper.value = Double(search_distance)
        Distance_Switch.setOn(distance_sort, animated: true)
        Rating_Switch.setOn(rating_sort, animated: true)


    }
    
    @IBAction func distance_stepper(_ sender: UIStepper) {
        if search_distance != Int(sender.value){
            search_distance = Int(sender.value)
            Distance_Stepper.value = sender.value
        }
        search_distance = Int(sender.value)
        Distance_Stepper.value = sender.value

        distance_display.text = "Search Distance: "+String(search_distance) + " m"
        
    }

    @IBAction func distance_switch(_ sender: UISwitch) {
        if sender.isOn{
            distance_sort = true
            rating_sort = false
            Distance_Switch.setOn(true, animated: true)
            Rating_Switch.setOn(false, animated: true)
        }else{
            rating_sort = true
            distance_sort = false
            Distance_Switch.setOn(false, animated: true)
            Rating_Switch.setOn(true, animated: true)

        }
        
    }
    
    @IBAction func rating_switch(_ sender: UISwitch) {
        if sender.isOn{
            rating_sort = true
            distance_sort = false

            Rating_Switch.setOn(true, animated: true)
            Distance_Switch.setOn(false, animated: true)

        }else{
            distance_sort = true

            rating_sort = false
            Rating_Switch.setOn(false, animated: true)
            Distance_Switch.setOn(true, animated: true)

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
