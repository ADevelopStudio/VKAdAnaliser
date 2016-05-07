//
//  VKCategory.swift
//  VKAdAnaliser
//
//  Created by Dmitrii Zverev on 6/05/2016.
//  Copyright © 2016 Dmitrii Zverev. All rights reserved.
//

import Foundation

class DictoraryElement: NSObject, NSCoding {
    var rus = ""
    var eng = ""
    var isInDict = false
    override init() {}
    
    required init(coder aDecoder: NSCoder) {
        self.rus = (aDecoder.decodeObjectForKey("rus")  ?? "") as! String
        self.eng = (aDecoder.decodeObjectForKey("eng")  ?? "") as! String
        self.isInDict = aDecoder.decodeBoolForKey("isInDict")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.eng,  forKey: "eng")
        aCoder.encodeObject(self.rus,  forKey: "rus")
        aCoder.encodeBool(self.isInDict,  forKey: "isInDict")
    }
    
    init(json: JSON){
        rus = json["Rus"].stringValue
        eng = json["Eng"].stringValue
    }
}

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
    
    enum Platform: Int {
        case Unknown = 0, Mobile, iPhone, iPad, Android, Wphone, Windows, Web
        var name :String {
            switch self {
            case .Unknown:
                return "Unknown"
            case .Mobile:
                return "Other mobile"
            case .iPhone:
                return "iPhone"
            case .iPad:
                return "iPad"
            case .Android:
                return "Android"
            case .Wphone:
                return "Windows phone"
            case .Windows:
                return "Windows 8"
            case .Web:
                return "Web"
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
    var platform = Platform.Unknown
    var age = 0
    var city = DZCityOrCountry()
    var country = DZCityOrCountry()
    var relation = Relation.Unknown
    var activities = Array<String>()
    var interests = Array<String>()

    var last_seen:Double = 0
    var followers_count = 0
    var isBdayFilled = true
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
        if let tempPlatform = Platform(rawValue: json["last_seen"]["platform"].intValue) {
            platform = tempPlatform
        }
        
        let bDay = json["bdate"].stringValue
        isBdayFilled = bDay.lenght() > 0
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        if let datus = dateFormatter.dateFromString(bDay) {
            let years = NSCalendar.currentCalendar().components(.Year, fromDate: datus, toDate: NSDate(), options: NSCalendarOptions()).year   // 55
            age = years
        }
        city = DZCityOrCountry(json: json["city"])
        country = DZCityOrCountry(json: json["country"])
        occupation = json["occupation"]["type"].stringValue
        followers_count = json["followers_count"].intValue
        id = json["id"].stringValue
        last_seen = json["last_seen"]["time"].doubleValue
        
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
    
    func isValid() -> (valid:Bool, reason:String){
        //Remove suspitios users
        if NSDate().timeIntervalSince1970 - last_seen > (60*60*24*180) { //last seen more than 180 days ago
            return (false, "were not online more than 180 days")
        }
        if followers_count < 20 {
            return (false, "have less than 20 friends")
        }
        if interests.count == 0 && activities.count == 0 && occupation.lenght() == 0  {
            return (false, "do not provide enough data")
        }
        return (true, "")
    }
}