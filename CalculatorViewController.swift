// Calorie Calculator

import UIKit
import Firebase

class CalculatorViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    var plistHelepr = PlistManagment()
    var resultCalc: Double = 0.0
    var resultCalcUS: Double = 0.0
    var selectedActivity: String?
    var activityList = ["Basal Metabolic Rate (BMR)", "Sedentary: little or no exercise", "Light: exercise 1-3 times/week", "Moderate: exercise 4-5 times/week", "Active: daily exercise or intense exercise 3-4 times/week", "Very Active: intense exercise 6-7 times/week", "Extra Active: very intense exercise daily, or physical job"]
    var calcActivity: Double = 0.0
    var calcActivityUS: Double = 0.0
    var idUser: String = ""
    var idDoc: String = ""
    var gender: String = ""
    
    var countWeight = 0
    var countHeight = 0
    
    private var documents: [DocumentSnapshot] = []
    public var persData: [personalData] = []
    private var listener : ListenerRegistration!
    
    @IBOutlet weak var weightUS: UITextField!
    @IBOutlet weak var heightUS: UITextField!
    @IBOutlet weak var ageUS: UITextField!
    @IBOutlet weak var activityUS: UITextField!
    @IBOutlet weak var resultUS: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var viewMetric: UIView!
    @IBOutlet weak var viewUS: UIView!
    
    @IBOutlet weak var weight: UITextField!
    @IBOutlet weak var height: UITextField!
    @IBOutlet weak var age: UITextField!
    @IBOutlet weak var activity: UITextField!
    @IBOutlet weak var result: UITextField!
    
    var heightDbUS = String()
    var heightDb = String()
    
    var weightDbUS = String()
    var weightDb = String()
    
    fileprivate func baseQuery() -> Query {
        return Firestore.firestore().collection("###").whereField("userID", isEqualTo: idUser)
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

        self.hideKeyboardWhenTappedAround()
    
        createPickerView()
        dismissPickerView()
        
        self.query = baseQuery()
        
        self.viewMetric.isHidden = true
        
        self.weightUS.keyboardType = UIKeyboardType.decimalPad
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener.remove()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.listener =  query?.addSnapshotListener { (documents, error) in
            guard let snapshot = documents else {
                print("Error fetching documents results: \(error!)")
                return
            }
             
            let results = snapshot.documents.map { (document) -> personalData in
                if let plans = personalData(dictionary: document.data(), id: document.documentID) {
                    return plans
                } else {
                    fatalError("Unable to initialize type \(personalData.self) with dictionary \(document.data())")
                }
            }
            
            self.persData = results
            self.documents = snapshot.documents
            
            for i in self.persData {
                let w = Double(i.weight)
                self.weight.text = String((w!).truncate(places: 2))
                let h = Double(i.height)
                self.height.text = String((h!).truncate(places: 2 ))
                self.age.text = i.age
                self.activity.text = i.activity
                self.result.text = i.calorie
                self.idDoc = i.id
                
                let we = Double(i.weight)
                self.weightUS.text = String((we! / 0.453592).truncate(places: 2))
                let he = Double(i.height)
                self.heightUS.text = String((he! / 30.48).truncate(places: 2))
                
                self.activityUS.text = i.activity
                self.ageUS.text = i.age
                self.resultUS.text = i.calorie
            }
            
            let dataVersion = self.plistHelepr.readPlist(namePlist: "Options", key: "dataVersion")
            self.gender = (dataVersion as? String)!
            
            print(self.gender)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        activityList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return activityList[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedActivity = activityList[row]
        
        activity.text = selectedActivity
        activityUS.text = selectedActivity
    }
    
    func createPickerView() {
           let pickerView = UIPickerView()
           pickerView.delegate = self
           activity.inputView = pickerView
           activityUS.inputView = pickerView
    }
    
    func dismissPickerView() {
       let toolBar = UIToolbar()
       toolBar.sizeToFit()
        
       let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
       toolBar.setItems([button], animated: true)
       toolBar.isUserInteractionEnabled = true
       activity.inputAccessoryView = toolBar
       activityUS.inputAccessoryView = toolBar
    }
    
    @objc func action() {
        view.endEditing(true)
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        let segIndex = segmentedControl.selectedSegmentIndex
        view.endEditing(true)
        switch segIndex {
        case 0:
            self.viewUS.isHidden = false
            self.viewMetric.isHidden = true
        case 1:
            self.viewUS.isHidden = true
            self.viewMetric.isHidden = false
        default:
            self.viewMetric.isHidden = true
            self.viewUS.isHidden = false
        }
    }
    
    @IBAction func calcUS(_ sender: Any) {
        
        let weightCheck = self.weightUS.text!.replacingOccurrences(of: ",", with: ".")
        let heightCheck = self.heightUS.text!.replacingOccurrences(of: ",", with: ".")
        countWeight = 0
        countHeight = 0
        
        for i in weightCheck {
            if i == "." {
                countWeight = countWeight + 1
            }
        }
        
        for i in heightCheck {
            if i == "." {
                countHeight = countHeight + 1
            }
        }
        
        if countWeight > 1 || countHeight > 1 || weightCheck == "." || heightCheck == "." {
            let alert = UIAlertController(title: "Error", message: "Please, enter the correct values.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            self.present(alert, animated: true)
        } else {
        
            let w = Double(weightCheck)
            let h = Double(heightCheck)
            let a = Double(self.ageUS.text!)
            
            self.heightDbUS = String(h! * 30.48)
            self.weightDbUS = String(w! * 0.453592)
            
            if (w != nil) && (h != nil) && (a != nil) && (activityUS.text != "") {
                if activityUS.text == "Basal Metabolic Rate (BMR)" {
                    self.calcActivityUS = 1
                } else if activityUS.text == "Sedentary: little or no exercise" {
                    self.calcActivityUS = 1.2
                } else if activityUS.text == "Light: exercise 1-3 times/week" {
                    self.calcActivityUS = 1.37
                } else if activityUS.text == "Moderate: exercise 4-5 times/week" {
                    self.calcActivityUS = 1.46
                } else if activityUS.text == "Active: daily exercise or intense exercise 3-4 times/week" {
                    self.calcActivityUS = 1.55
                } else if activityUS.text == "Very Active: intense exercise 6-7 times/week" {
                    self.calcActivityUS = 1.725
                } else if activityUS.text == "Extra Active: very intense exercise daily, or physical job" {
                    self.calcActivityUS = 1.9
                }
                
                if gender == "men" {
                    
                    let resultWeight = 10 * w! * 0.453592 // паунд
                    let resultAge = 5 * a!
                    let resultHeight = 6.25 * h! * 30.48 // фут
                    
                    resultCalcUS = resultWeight + resultHeight - resultAge + 5
                }
                else {
                    
                    let resultWeight = 10 * w! * 0.453592 // паунд
                    let resultAge = 5 * a!
                    let resultHeight = 6.25 * h! * 30.48 // фут
                    
                    resultCalcUS = resultWeight + resultHeight - resultAge - 161
                }
                
                let resultInt = Int(resultCalcUS * calcActivityUS)
                self.resultUS.text = String(resultInt)
                
                let db = Firestore.firestore()
                
                if self.idDoc == "" {
                    var ref: DocumentReference? = nil
                    ref = db.collection("personal_data").addDocument(data: [
                        "activity": self.activityUS.text!,
                        "age": self.ageUS.text!,
                        "calorie": self.resultUS.text!,
                        "gender": self.gender,
                        "height": self.heightDbUS,
                        "userID": self.idUser,
                        "weight": self.weightDbUS
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added with ID: \(ref!.documentID)")
                        }
                    }
                } else {
                    db.collection("personal_data").document(self.idDoc).setData([
                        "activity": self.activityUS.text!,
                        "age": self.ageUS.text!,
                        "calorie": self.resultUS.text!,
                        "gender": self.gender,
                        "height": self.heightDbUS,
                        "userID": self.idUser,
                        "weight": self.weightDbUS
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                }
                
            } else {
                let alert = UIAlertController(title: "Error", message: "All fields must be filled!", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

                self.present(alert, animated: true)
            }
        }
    }
    
    @IBAction func calc(_ sender: Any) {
        
        let weightCheck = self.weight.text!.replacingOccurrences(of: ",", with: ".")
        let heightCheck = self.height.text!.replacingOccurrences(of: ",", with: ".")
        countWeight = 0
        countHeight = 0
        
        for i in weightCheck {
            if i == "." {
                countWeight = countWeight + 1
            }
        }
        
        for i in heightCheck {
            if i == "." {
                countHeight = countHeight + 1
            }
        }
        
        if countWeight > 1 || countHeight > 1 || weightCheck == "." || heightCheck == "." {
            let alert = UIAlertController(title: "Error", message: "Please, enter the correct values.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            self.present(alert, animated: true)
        } else {
        
            let w = Double(weightCheck)
            let h = Double(heightCheck)
            let a = Double(self.age.text!)
            
            if (w != nil) && (h != nil) && (a != nil) && (activity.text != "") {
                if activity.text == "Basal Metabolic Rate (BMR)" {
                    self.calcActivity = 1
                } else if activity.text == "Sedentary: little or no exercise" {
                    self.calcActivity = 1.2
                } else if activity.text == "Light: exercise 1-3 times/week" {
                    self.calcActivity = 1.37
                } else if activity.text == "Moderate: exercise 4-5 times/week" {
                    self.calcActivity = 1.46
                } else if activity.text == "Active: daily exercise or intense exercise 3-4 times/week" {
                    self.calcActivity = 1.55
                } else if activity.text == "Very Active: intense exercise 6-7 times/week" {
                    self.calcActivity = 1.725
                } else if activity.text == "Extra Active: very intense exercise daily, or physical job" {
                    self.calcActivity = 1.9
                }
                
                if gender == "men" {
                    let resultWeight = 10 * w!
                    let resultAge = 5 * a!
                    let resultHeight = 6.25 * h!
                    
                    resultCalc = resultWeight + resultHeight - resultAge + 5
                }
                else {
                    let resultWeight = 10 * w!
                    let resultAge = 5 * a!
                    let resultHeight = 6.25 * h!

                    resultCalc = resultWeight + resultHeight - resultAge - 161
                    
                }
                
                let resultInt = Int(resultCalc * calcActivity)
                self.result.text = String(resultInt)
                
                let db = Firestore.firestore()
                
                if self.idDoc == "" {
                    var ref: DocumentReference? = nil
                    ref = db.collection("personal_data").addDocument(data: [
                        "activity": self.activity.text!,
                        "age": self.age.text!,
                        "calorie": self.result.text!,
                        "gender": self.gender,
                        "height": self.height.text!,
                        "userID": self.idUser,
                        "weight": self.weight.text!
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added with ID: \(ref!.documentID)")
                        }
                    }
                } else {
                    db.collection("personal_data").document(self.idDoc).setData([
                        "activity": self.activity.text!,
                        "age": self.age.text!,
                        "calorie": self.result.text!,
                        "gender": self.gender,
                        "height": self.height.text!,
                        "userID": self.idUser,
                        "weight": self.weight.text!
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                }
                
            } else {
                let alert = UIAlertController(title: "Error", message: "All fields must be filled!", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

                self.present(alert, animated: true)
            }
        }
    }
    
    

}
