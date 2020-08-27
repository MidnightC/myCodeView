//
//  Model.swift
//  Evitopia
//
//  Created by admin on 18/10/2019.
//  Copyright © 2019 evitopia. All rights reserved.
//

import Foundation

struct Exercise {
    var title: String
    var text: String
    var image: String
    var muscle: String
    var id: String

    var dictionary: [String: Any] {
        return [
            "title": title,
            "text": text,
            "image": image,
            "muscle": muscle
        ]
    }
}
 
extension Exercise{
    init?(dictionary: [String : Any], id: String) {
        guard   let title = dictionary["title"] as? String,
            let text = dictionary["text"] as? String,
            let image = dictionary["image"] as? String,
            let muscle = dictionary["muscle"] as? String
            else { return nil }
         
        self.init(title: title, text: text, image: image, muscle: muscle, id: id)
    }
}

struct detailExercise {
    var title:String
    var text: String
    var image: String
    var muscle: String
    var id: String
     
    var dictionary: [String: Any] {
        return [
            "title": title,
            "text": text,
            "image": image,
            "muscle": muscle
        ]
    }
}
 
extension detailExercise{
    init?(dictionary: [String : Any], id: String) {
        guard   let title = dictionary["title"] as? String,
            let text = dictionary["text"] as? String,
            let image = dictionary["image"] as? String,
            let muscle = dictionary["muscle"] as? String
            else { return nil }
         
        self.init(title: title, text: text, image: image, muscle: muscle, id: id)
    }
}

struct myWorkout{
    var title: String
    var status: String
    var id: String
    var number: Int
    
    var dictionary: [String: Any] {
        return [
            "title": title,
            "status": status,
            "number": number
        ]
    }
}
 
extension myWorkout {
    init?(dictionary: [String : Any], id: String) {
        guard   let title = dictionary["title"] as? String,
            let status = dictionary["status"] as? String,
            let number = dictionary["id"] as? Int
            else { return nil }
         
        self.init(title: title, status: status, id: id, number: number)
    }
}

struct mealPlan {
    var title: String
    var description: String
    var breakfast: [String]
    var snack: [String]
    var lunch: [String]
    var snack_2: [String]
    var dinner: [String]
    var dinner_2: [String]
    
    var id: String
    
    var dictionary: [String: Any] {
        return [
            "title": title,
            "description": description,
            "breakfast": breakfast,
            "snack": snack,
            "lunch": lunch,
            "snack_2": snack_2,
            "dinner": dinner,
            "dinner_2": dinner_2
        ]
    }
}
 
extension mealPlan {
    init?(dictionary: [String : Any], id: String) {
        guard
            let title = dictionary["title"] as? String,
            let description = dictionary["description"] as? String,
            let breakfast = dictionary["breakfast"] as? [String],
            let snack = dictionary["snack"] as? [String],
            let lunch = dictionary["lunch"] as? [String],
            let snack_2 = dictionary["snack_2"] as? [String],
            let dinner = dictionary["dinner"] as? [String],
            let dinner_2 = dictionary["dinner_2"] as? [String]
        else { return nil }
         
        self.init(title: title, description: description, breakfast: breakfast, snack: snack, lunch: lunch, snack_2: snack_2, dinner: dinner, dinner_2: dinner_2, id: id)
    }
}

struct mealPlans {
    var title: String
    
    var id: String
    
    var dictionary: [String: Any] {
        return [
            "title": title
        ]
    }
}
 
extension mealPlans {
    init?(dictionary: [String : Any], id: String) {
        guard
            let title = dictionary["title"] as? String
        else { return nil }
         
        self.init(title: title, id: id)
    }
}

struct myMealPlan {
    var userID = String()
    var planID = String()
    var id = String()
    
    var dictionary: [String: Any] {
        return [
            "userID": userID,
            "planID": planID
        ]
    }

}

extension myMealPlan {
    init?(dictionary: [String: Any], id: String) {
        guard
            let userID = dictionary["userID"] as? String,
            let planID = dictionary["planID"] as? String
        else { return nil }
        
        self.init(userID: userID, planID: planID, id: id)
    }
}

struct personalData {
    var userID = String()
    var weight = String()
    var height = String()
    var age = String()
    var gender = String()
    var activity = String()
    var calorie = String()
    var id = String()
    
    var dictionary: [String: Any] {
        return [
            "userID": userID,
            "weight": weight,
            "height": height,
            "age": age,
            "gender": gender,
            "activity": activity,
            "calorie": calorie
        ]
    }

}

extension personalData {
    init?(dictionary: [String: Any], id: String) {
        guard
            let userID = dictionary["userID"] as? String,
            let weight = dictionary["weight"] as? String,
            let height = dictionary["height"] as? String,
            let age = dictionary["age"] as? String,
            let gender = dictionary["gender"] as? String,
            let activity = dictionary["activity"] as? String,
            let calorie = dictionary["calorie"] as? String
        else { return nil }
        
        self.init(userID: userID, weight: weight, height: height, age: age, gender: gender, activity: activity, calorie: calorie, id: id)
    }
}

struct personalWorkout {
    var userID = String()
    var id = String()
    var exercises = [String]()
    var descriptions = [String]()
}

extension personalWorkout {
    init?(dictionary: [String: Any], id: String) {
        guard
            let userID = dictionary["userID"] as? String,
            let exercises = dictionary["exercises"] as? [String],
            let descriptions = dictionary["descriptions"] as? [String]
        else { return nil }
        
        self.init(userID: userID, id: id, exercises: exercises, descriptions: descriptions)
    }
}

struct workoutDays {

    var id = String()
    var title = String()
    var exercises = [String]()
    var description = String()
    var status = String()
    var userID = String()
    var workoutID = String()
    var number = Int()
}

extension workoutDays {
    init?(dictionary: [String: Any], id: String) {
        guard
            let title = dictionary["title"] as? String,
            let exercises = dictionary["exercises"] as? [String],
            let description = dictionary["description"] as? String,
            let status = dictionary["status"] as? String,
            let userID = dictionary["userID"] as? String,
            let workoutID = dictionary["workoutID"] as? String,
            let number = dictionary["id"] as? Int
        else { return nil }
        
        self.init(id: id, title: title, exercises: exercises, description: description, status: status, userID: userID, workoutID: workoutID, number: number)
    }
}

struct workoutList {
    var title: String
    var id: String
    
    var dictionary: [String: Any] {
        return [
            "title": title
        ]
    }
}
 
extension workoutList {
    init?(dictionary: [String : Any], id: String) {
        guard   let title = dictionary["title"] as? String
            else { return nil }
         
        self.init(title: title, id: id)
    }
}
