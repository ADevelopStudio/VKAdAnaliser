//
//  StatisticsDetailVC.swift
//  VKAdAnaliser
//
//  Created by Dmitrii Zverev on 6/05/2016.
//  Copyright © 2016 Dmitrii Zverev. All rights reserved.
//

import UIKit

class StatisticsDetailVC: UIViewController {
    var collectedDataSet = Array<User>()

    @IBOutlet weak var scroller: UIScrollView!
    
    override func viewDidLoad() {
        title = "Dataset: \(collectedDataSet.count) users"
        self.view.backgroundColor = originalDarkGrey
        caltulateStat()
    }

    func caltulateStat(){
        /*
         var id: String = ""
            + var occupation: String = ""
            + var sex = Sex.Unknown
            + var age: Int?
         var city: DZCityOrCountry?
         var country: DZCityOrCountry?
         var relation = Relation.Unknown
         var activities = Array<String>()
         var interests = Array<String>()

         */
        var occupation = Dictionary<String,Int>()
        var age = Dictionary<String,Int>()
        var sex = Dictionary<String,Int>()
        var relation = Dictionary<String,Int>()
        var activities = Dictionary<String,Int>()
        var interests = Dictionary<String,Int>()

        for user in collectedDataSet {
            if occupation[user.occupation] != nil {
              occupation[user.occupation]!  += 1
            } else {
                occupation[user.occupation] = 1
            }
            
            if age[user.age] != nil {
                age[user.age]!  += 1
            } else {
                age[user.age] = 1
            }
            
            if sex[user.sex.name] != nil {
                sex[user.sex.name]!  += 1
            } else {
                sex[user.sex.name] = 1
            }
            
            if relation[user.relation.name] != nil {
                relation[user.relation.name]!  += 1
            } else {
                relation[user.relation.name] = 1
            }
            
            for name in user.activities {
                if activities[name] != nil {
                    activities[name]!  += 1
                } else {
                    activities[name] = 1
                }
            }
            for name in user.interests {
                if interests[name] != nil {
                    interests[name]!  += 1
                } else {
                    interests[name] = 1
                }
            }
        }
        print("\n\nData stat:\n")

        print("_occupation_")
        displaySortedDict(occupation)
        print("_age_")
        displaySortedDict(age)
        print("_sex_")
        displaySortedDict(sex)
        print("_relation_")
        displaySortedDict(relation)
        print("_activities_")
        activities = removeNoiceData(activities)
        displaySortedDict(activities)
        print("_interests_")
        interests = removeNoiceData(interests)
        displaySortedDict(interests)
    }
    
    func displaySortedDict(dict:Dictionary<String,Int>)  {
        let sortedKeysinterests = dict.keys.sort({ (firstKey, secondKey) -> Bool in
            return dict[firstKey] > dict[secondKey]
        })
        for key in sortedKeysinterests {
            print("\(key.lenght() > 0 ? key : "unknown"): \(dict[key]!) = \((Double(dict[key]!)/Double(collectedDataSet.count)*100).roundToPlaces(4))%")
        }
        print("\n")
    }
    
    
    func removeNoiceData(dict: Dictionary<String,Int>) ->  Dictionary<String,Int>{
        //Remove all data less than 1 percent of all dataset
        var newDict = Dictionary<String,Int>()
        for (key, value) in dict {
            if value > (collectedDataSet.count / 100) && containsOnlyLetters(key) {
               newDict[key] = value
            }
        }

        return newDict
    }
    
    func containsOnlyLetters(input: String) -> Bool {
        for chr in input.characters {
            if (!(chr >= "a" && chr <= "z") && !(chr >= "а" && chr <= "я")  && !(chr == " ")) {
                return false
            }
        }
        return true
    }
    
}
