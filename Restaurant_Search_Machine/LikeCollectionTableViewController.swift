//
//  LikeCollectionTableViewController.swift
//  Restaurant_Search_Machine
//
//  Created by tony51307 on 2020/6/25.
//  Copyright © 2020 mac03. All rights reserved.
//

import UIKit

class LikeCollectionTableViewController: UITableViewController {
    
    
    var path = 0
    override func viewDidLoad() {
        super.viewDidLoad()
       self.navigationItem.rightBarButtonItem = self.editButtonItem

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let userDefault = UserDefaults()
        let namelist = userDefault.value(forKey: "placeName") as! [String]
        return namelist.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        }
        let userDefault = UserDefaults()
        let namelist = userDefault.value(forKey: "placeName") as! [String]
        cell?.textLabel?.text = "❤️  " + namelist[indexPath.row]
        cell?.textLabel?.adjustsFontSizeToFitWidth = true
        return cell!
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let userDefault = UserDefaults()
        var idList = userDefault.value(forKey: "placeId") as! [String]
        var nameList = userDefault.value(forKey: "placeName") as! [String]
        var latList = userDefault.value(forKey: "placeLat") as! [Double]
        var logList = userDefault.value(forKey: "placeLog") as! [Double]
        if editingStyle == .delete {
            // Delete the row from the data source
            idList.remove(at: indexPath.row)
            userDefault.setValue(idList, forKey: "placeId")
            nameList.remove(at: indexPath.row)
            userDefault.setValue(nameList, forKey: "placeName")
            latList.remove(at: indexPath.row)
            userDefault.setValue(latList, forKey: "placeLat")
            logList.remove(at: indexPath.row)
            userDefault.setValue(logList, forKey: "placeLog")
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }

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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        path = indexPath.row
        performSegue(withIdentifier: "likeToContent", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let userDefault = UserDefaults()
        var idList = userDefault.value(forKey: "placeId") as! [String]
        var nameList = userDefault.value(forKey: "placeName") as! [String]
        var latList = userDefault.value(forKey: "placeLat") as! [Double]
        var logList = userDefault.value(forKey: "placeLog") as! [Double]
        let vc_text = segue.destination as! ContentViewController
        vc_text.id = idList[path]
        vc_text.targetlog = logList[path]
        vc_text.targetlat = latList[path]
        vc_text.targetName = nameList[path]
        vc_text.currentlat = curlocation!.coordinate.latitude
        vc_text.currentlog = curlocation!.coordinate.longitude
    }

}
