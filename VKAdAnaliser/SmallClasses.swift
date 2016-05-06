//
//  VKCategory.swift
//  VKAdAnaliser
//
//  Created by Dmitrii Zverev on 6/05/2016.
//  Copyright © 2016 Dmitrii Zverev. All rights reserved.
//

import Foundation

class DZCategory: NSObject {
    var id: String = ""
    var name: String = ""
  
    override init(){
        super.init()
    }
    
    init(json: JSON){
        name = json["name"].stringValue.lowercaseString
        id = json["id"].stringValue
    }
}

class DZCityOrCountry: NSObject {
    var id: String = ""
    var title: String = ""
    
    override init(){
        super.init()
    }
    
    init(json: JSON){
        title = json["title"].stringValue
        id = json["id"].stringValue
    }
}


class User: NSObject {
    enum Sex: Int {
        case Unknown = 0, Female, Male
        var name :String {
            switch self {
            case .Unknown:
                return "Unknown"
            case .Female:
                return "Female"
            case .Male:
                return "Male"
            }
        }
    }
    
    enum Relation: Int {
        case Unknown = 0, Single, HasPartner, Engaged, Married, EverythingIsHard, LookingFor, InLove
        var name :String {
            switch self {
            case .Unknown:
                return "Unknown"
            case .Single:
                return "Single"
            case .HasPartner:
                return "Has a partner"
            case .Engaged:
                return "Engaged"
            case .Married:
                return "Married"
            case .EverythingIsHard:
                return "Everything is complicated"
            case .LookingFor:
                return "Looking for"
            case .InLove:
                return "In love"
            }
        }
        
    }
    
    var id: String = ""
    var occupation: String = ""
    var sex = Sex.Unknown
    var age: String = ""
    var city = DZCityOrCountry()
    var country = DZCityOrCountry()
    var relation = Relation.Unknown
    var activities = Array<String>()
    var interests = Array<String>()

    override init(){
        super.init()
    }
    
    init(json: JSON){
        //  Maybe  TODO personal, interests" ])
        id = json["id"].stringValue
        if let tempSex = Sex(rawValue: json["sex"].intValue) {
            sex = tempSex
        }
        if let tempRelation = Relation(rawValue: json["relation"].intValue) {
            relation = tempRelation
        }
        
        let bDay = json["bdate"].stringValue
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        if let datus = dateFormatter.dateFromString(bDay) {
            let years = NSCalendar.currentCalendar().components(.Year, fromDate: datus, toDate: NSDate(), options: NSCalendarOptions()).year   // 55
            age = "\(years)"
        }
        city = DZCityOrCountry(json: json["city"])
        country = DZCityOrCountry(json: json["country"])
        occupation = json["occupation"]["type"].stringValue
        
        let activitiesArray =  json["activities"].stringValue.characters.split{$0 == ","}.map(String.init)
        for element in activitiesArray {
            let fixedActivity = element.removeSpaces()
            if fixedActivity.lenght() > 0 {
                activities.append(fixedActivity)
            }
        }
        
        let interestsArray =  json["interests"].stringValue.characters.split{$0 == ","}.map(String.init)
        for element in interestsArray {
            let fixedInterest = element.removeSpaces()
            if fixedInterest.lenght() > 0 {
                interests.append(fixedInterest)
            }
        }
    }
}