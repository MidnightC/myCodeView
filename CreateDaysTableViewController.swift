import UIKit
import Firebase

class CreateDaysTableViewController: UITableViewController {
    
    var documents: [DocumentSnapshot] = []
    var days: [workoutDays] = []
    var listener: ListenerRegistration!
    
    var idUser = ""
    var idWorkout = ""
    var id = Int()
    var countDaysCompleted = Int()
    var addTitle: String = ""
    var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
            }
        }
    }
    
    func baseQuery() -> Query {
        return
    Firestore.firestore().collection("###").whereField("###", isEqualTo: idUser).whereField("###", isEqualTo: idWorkout).order(by: "id")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener.remove()
    }
    
    override func viewWillAppear(_ animated: Bool) {
      
        self.query = baseQuery()
        
        self.listener = query?.addSnapshotListener { (documents, error) in
            guard let snapshot = documents else {
                print("Error fetching documents results: \(error!)")
                return
            }
            
            let results = snapshot.documents.map { (document) -> workoutDays in
                if let day = workoutDays(dictionary: document.data(), id: document.documentID) {
                    return day
                } else {
                    fatalError("Unable to initialize type \(workoutDays.self) with dictionary \(document.data())")
                }
            }
            
            self.days = results
            self.documents = snapshot.documents
            self.id = 0
            for i in self.days {
                if i.number > self.id {
                    self.id = i.number
                }
            }
            
            if self.days.count >= 1 {
                for i in 0...self.days.count - 1 {
                    self.days[i].title = "Day " + String(i + 1)
                }
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    // MARK: - Table view data source

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
         return true
     }
     
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
            if (editingStyle == .delete) {
                let item = days[indexPath.row]
                Firestore.firestore().collection("###").document(item.id).delete()
            }
     }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
         
        let item = days[indexPath.row]
        cell.textLabel!.text = item.title
        cell.detailTextLabel!.text = item.description
        let imageView: UIImageView = UIImageView(frame:CGRect(x: 0, y: 0, width: 20, height: 20))
        imageView.image = UIImage(named:item.status)
        imageView.contentMode = .scaleAspectFit
        cell.imageView?.image = nil
        cell.accessoryView = imageView

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "create" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = segue.destination as! CreateTableViewController
                let value = days[indexPath.row]
                controller.idDay = value.id
                controller.idWorkoutCreate = value.workoutID
                controller.idUserCreate = value.userID
            }
        }
    }
    
    @IBAction func addDay(_ sender: Any) {
        let db = Firestore.firestore()
        var docRef: DocumentReference? = nil
        docRef = db.collection("###").addDocument(data: [
            "###": self.idWorkout, "###": self.id + 1, "###": "not completed", "###": "", "description": "", "###": [], "###": self.idUser])
        { err in
              if let err = err {
                  print("Error adding document: \(err)")
              } else {
                  print("Document added with ID: \(docRef!.documentID)")
              }
        }
        self.tableView.reloadData()
    }
    
    @IBAction func finish(_ sender: Any) {
        self.countDaysCompleted = 0
        for i in self.days {
            if i.status == "completed" {
                self.countDaysCompleted += 1
            }
        }
        
        if self.days.count == countDaysCompleted {

            let alertVC : UIAlertController = UIAlertController(title: "New workout", message: "Enter a name for your workout", preferredStyle: .alert)

            alertVC.addTextField { (UITextField) in
                
            }

            let cancelAction = UIAlertAction.init(title: "Cancel", style: .destructive, handler: nil)

            alertVC.addAction(cancelAction)

            //Alert action closure
            let addAction = UIAlertAction.init(title: "Add", style: .default) { (UIAlertAction) -> Void in
                
                let textFieldReminder = (alertVC.textFields?.first)! as UITextField
                self.addTitle = textFieldReminder.text ?? "No name"
                
                let collection = Firestore.firestore().collection("###")

                collection.document(self.idWorkout).updateData(
                    ["title": self.addTitle,
                     "status": "completed"
                    ]) { err in
                     if let err = err {
                         print("Error updating document: \(err)")
                     } else {
                         print("Document successfully updated")
                     }
                }
                
                self.navigationController?.popViewController(animated: true)// close VC
            }
            
            alertVC.addAction(addAction)
            present(alertVC, animated: true, completion: nil)

        } else {
            let alert = UIAlertController(title: "Error", message: "Please complete all training days.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
}
