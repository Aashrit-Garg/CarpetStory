//
//  CarpetTableViewController.swift
//  CarpetStory
//
//  Created by Aashrit Garg on 04/08/2018.
//  Copyright © 2018 Aashrit Garg. All rights reserved.
//

import UIKit
import UIKit
import FirebaseFirestore
import Alamofire
import AlamofireImage
import SVProgressHUD

class CarpetTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var carpetTableView: UITableView!
    
    // MARK: - Global Variable Initialised
    
    // One array created to store carpets for tableview. 
    var carpets = [Carpet]()
    let db = Firestore.firestore()
    var queryLength : Query!
    var queryBreadth : Query!
    var query : Query!
    
    var resultOfLength = [String]()
    var resultOfBreadth = [String]()
    
    var index : Int?
    var docID : String?
    let imageCache = NSCache<NSString, UIImage>()
    var searchCalled : Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        SVProgressHUD.dismiss()
        
        carpetTableView.delegate = self
        carpetTableView.dataSource = self
        carpetTableView.rowHeight = 250
        
        if searchCalled == true {
            
            getDocsFromQuery(query: queryLength!, selection: 1)
            getDocsFromQuery(query: queryBreadth!, selection: 2)
            
        } else {
            
            getDocsFromQuery(query: query, selection: 3)
        }
    }
    
    func getDocsFromQuery(query : Query, selection : Int) {
        
        query.addSnapshotListener { documentSnapshot, error in
            guard let documents = documentSnapshot?.documents else {
                print("Error fetching document changes: \(error!)")
                return
            }
            
            if documents.count != 0 {
                
                if selection == 1 {
                    
                    for i in 0 ..< documents.count {

                        self.resultOfLength.append(documents[i].documentID)
                    }
                } else if selection == 2 {
                    
                    for i in 0 ..< documents.count {

                        print("Fab1234 \(documents[i].documentID)")

                        if self.resultOfLength.contains(documents[i].documentID) {

                            let documentID = documents[i].documentID
                            self.getCarpetFromDoc(documentID: documentID)
                        }
                    }
                } else if selection == 3 {
                    
                    for i in 0 ..< documents.count {
                        let documentID = documents[i].documentID
                        self.getCarpetFromDoc(documentID: documentID)
                    }
                }
            } else {
                
                let alert = UIAlertController(title: "No carpets!", message: "Coudn't find carpets for mentioned size.", preferredStyle: .alert)
                let action = UIAlertAction(title: "Go Back", style: .default) { (action) in
                    _ = self.navigationController?.popViewController(animated: true)
                }
                
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    //MARK:- Get Document & Make Carpet Array
    
    func getCarpetFromDoc(documentID : String) {
        
        let docRef = db.collection("Carpets").document(documentID)
        
        SVProgressHUD.show()
        docRef.getDocument { (document, error) in
            
            if let document = document, document.exists {
                let dataDescription = document.data()
                
                let carpet : Carpet = Carpet(
                    name: dataDescription!["name"] as? String ?? "",
                    breadth: dataDescription!["breadth"] as? Int ?? 1,
                    length: dataDescription!["length"] as? Int ?? 1,
                    modelURL: dataDescription!["modelURL"] as? String ?? "",
                    description: dataDescription!["description"] as? String ?? "",
                    category: dataDescription!["category"] as? String ?? "",
                    mostViewed: true)
                self.carpets.append(carpet)
                self.docID = documentID
                
                self.carpetTableView.reloadData()
                
            } else {
                print("Document does not exist")
            }
            
            SVProgressHUD.dismiss()
        }
    }
    
    //MARK:- TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return carpets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "carpetCell", for: indexPath) as! CarpetTableViewCell
        if carpets.count != 0 {
            let carpet : Carpet = carpets[indexPath.row]
            cell.carpetName.text = carpet.name
            if let cachedImage = imageCache.object(forKey: NSString(string: (carpet.modelURL!))) {
                
                cell.carpetImage.image = cachedImage
            } else {
                
                Alamofire.request(carpet.modelURL!).responseImage { response in
                    debugPrint(response)
                    if let image = response.result.value {
                        self.imageCache.setObject(image, forKey: NSString(string: (carpet.modelURL!)))
                        cell.carpetImage.image = image
                        SVProgressHUD.dismiss()
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        index = indexPath.row
        SVProgressHUD.dismiss()
        performSegue(withIdentifier: "goToCarpetDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! CarpetViewController
        destinationVC.carpet = carpets[index!]
        destinationVC.docID = docID!
    }
}
