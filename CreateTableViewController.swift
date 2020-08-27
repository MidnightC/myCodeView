//
//  CreateTableViewController.swift
//  Evitopia
//
//  Created by admin on 24/11/2019.
//  Copyright © 2019 evitopia. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

struct cellData {
    var opened = Bool()
    var title = String()
    var sectionData = [String]()
    var imageData = [String]()
    var detailData = [String]()
    var arrow = String()
    var arrow_cell = [String]()
    var idData = [String]()
}

struct selected {
    var row = Int()
    var section = Int()
}

class CreateTableViewController: UITableViewController {
    
    var createName = ""
    var tableViewData = [cellData]()
    var exMuscle = [String]()
    var exWork = [String]()
    var id = Int()
    var addTitle = String()
    var idDay = ""
    var idUserCreate = ""
    var idWorkoutCreate = ""
    var dayDataEx = [String]()
    var dayDataMus = [String]()
    var muscles = ["Deltoids", "Chest", "Abs", "Biceps", "Forearm", "Quads", "Traps", "Triceps", "Back deltoids", "Back", "Buttocks", "Legs", "Calves"]
    var opened = Bool()
    var arrow = ""
    
    private var documents: [DocumentSnapshot] = []
    public var exercises: [Exercise] = []
    private var listener : ListenerRegistration!
    
    fileprivate func baseQuery() -> Query {
        return Firestore.firestore().collection("###")//.limit(to: 50)
    }
     
    fileprivate var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Create workout"
    }
    
    ///
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener.remove()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        id = 0

        self.query = baseQuery()

        self.listener =  query?.addSnapshotListener { (documents, error) in
            guard let snapshot = documents else {
                print("Error fetching documents results: \(error!)")
                return
            }
             
            let results = snapshot.documents.map { (document) -> Exercise in
                if let exercise = Exercise(dictionary: document.data(), id: document.documentID) {
                    return exercise
                } else {
                    fatalError("Unable to initialize type \(Exercise.self) with dictionary \(document.data())")
                }
            }
            
            var masEx: [String] = []
            var masSub: [String] = []
            var masImg: [String] = []
            var masCell: [String] = []
            var masId: [String] = []
            
            self.exercises = results
            self.documents = snapshot.documents
            
            let ref = Firestore.firestore().collection("###").document(self.idDay)
            ref.getDocument { (snapshot, err) in
            if let data = snapshot?.data() {
                self.dayDataEx = data["exercises"] as! [String]
                
                for m in self.muscles {
                    for i in self.exercises {
                        if i.muscle == m {
                            masEx.append(i.title)
                            masSub.append(i.text)
                            masCell.append("uncheck")
                            masImg.append(i.image)
                            masId.append(i.id)
                        }
                    }
                    
                    for ex in self.dayDataEx {
                        if let index = masId.firstIndex(of: ex) {
                            print(index)
                            masCell[index] = "check"
                            self.exWork.append(ex)
                            self.exMuscle.append(m)
                        }
                    }
                    
                    self.opened = false
                    self.arrow = "arrow_down"

                    if self.dayDataMus.firstIndex(of: m) != nil {
                        self.opened = true
                        self.arrow = "arrow_up"
                    }

                    self.tableViewData.append(cellData(opened: self.opened, title: m, sectionData: masEx, imageData: masImg, detailData: masSub, arrow: self.arrow, arrow_cell: masCell, idData: masId))
                    masEx = []
                    masSub = []
                    masImg = []
                    masCell = []
                    masId = []
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                   print("Couldn't find the document")
               }
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableViewData[section].opened == true {
            return tableViewData[section].sectionData.count + 1
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataIndex = indexPath.row - 1
        if indexPath.row == 0 { //header
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            else {
                return UITableViewCell()
            }
            cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: 20)
            cell.textLabel?.text = tableViewData[indexPath.section].title
            cell.detailTextLabel?.text = nil
            let imageView: UIImageView = UIImageView(frame:CGRect(x: 0, y: 0, width: 10, height: 10))
            imageView.image = UIImage(named:tableViewData[indexPath.section].arrow)
            imageView.contentMode = .scaleAspectFit
            cell.imageView?.image = nil
            cell.accessoryView = imageView
            return cell
        } else {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else { return UITableViewCell() }
            cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
            cell.textLabel?.text = tableViewData[indexPath.section].sectionData[dataIndex]
            
            let fileManager = FileManager.default
            let documentDir = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let localFile = documentDir.appendingPathComponent("\(tableViewData[indexPath.section].imageData[dataIndex]).png")
            
            let urlPrewiew = localFile
            let data = NSData(contentsOf: urlPrewiew as URL)
            
            let storageRef = Storage.storage().reference(withPath: "previewExercise/\(tableViewData[indexPath.section].imageData[dataIndex]).png")
            
            if fileManager.fileExists(atPath: localFile.path) {

                cell.imageView?.image = UIImage(data: data! as Data)
            } else {
                storageRef.write(toFile: localFile) { (url, error) in
                    if let error = error {
                        print("Got an error fetching data: \(error.localizedDescription)")
                        return
                    }
                    if let url = url {
                        print("File was downloaded to \(url.absoluteString)")
                        let localFile = documentDir.appendingPathComponent("\(self.tableViewData[indexPath.section].imageData[dataIndex]).png")
                        let urlPrewiew = localFile
                        let data = NSData(contentsOf: urlPrewiew as URL)
                        cell.imageView?.image = UIImage(data: data! as Data)
                    }
                }
            }
            
            let imageView: UIImageView = UIImageView(frame:CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.image = UIImage(named:tableViewData[indexPath.section].arrow_cell[dataIndex])
            imageView.contentMode = .scaleAspectFit
            cell.accessoryView = imageView
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if tableViewData[indexPath.section].opened == true {
                tableViewData[indexPath.section].opened = false
                tableViewData[indexPath.section].arrow = "arrow_down"
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            } else {
                tableViewData[indexPath.section].opened = true
                tableViewData[indexPath.section].arrow = "arrow_up"
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            }
        } else {
            let indx = indexPath.section
            if tableViewData[indx].arrow_cell[indexPath.row - 1] != "check" {
                tableViewData[indx].arrow_cell[indexPath.row - 1] = "check"
                exWork.append(tableViewData[indx].idData[indexPath.row - 1])
                exMuscle.append(tableViewData[indx].title)
                print(self.exWork)
            } else {
                tableViewData[indx].arrow_cell[indexPath.row - 1] = "uncheck"
                let indexEx = exWork.firstIndex(of: tableViewData[indx].idData[indexPath.row - 1])
                exWork.remove(at: indexEx!)
                exMuscle.remove(at: indexEx!)
            }
            let sections = IndexSet.init(integer: indx)
            tableView.reloadSections(sections, with: .none)
        }
        
    }
    
    @IBAction func done(_ sender: Any) {
        //add data
        if exMuscle != [] {
            func removeDublicate (ab: [String]) -> [String] {
            var answer1:[String] = []
                
            for i in ab {
              if !answer1.contains(i) {
                  answer1.append(i)
              }
            }
                
            return answer1
        }
            
        let f = removeDublicate(ab: exMuscle)
        
        let description = f.joined(separator: ", ")

        let collection = Firestore.firestore().collection("###")

        collection.document(self.idDay).updateData(
            ["exercises": self.exWork,
             "muscles": self.exMuscle,
             "description": description,
             "status": "completed"
            ]) { err in
             if let err = err {
                 print("Error updating document: \(err)")
             } else {
                 print("Document successfully updated")
             }
        }
        
        self.navigationController?.popViewController(animated: true)//close view controller

        } else {
            let alert = UIAlertController(title: "Error", message: "Please, select exercises for your workout", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
