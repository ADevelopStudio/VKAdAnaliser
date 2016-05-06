//
//  MyExtensions.swift
//  port4lio
//
//  Created by Dmitry Zverev on 12/07/2015.
//  Copyright © 2015 AntiCancerMe. All rights reserved.
//

import Foundation
import UIKit
import CoreData

import VK_ios_sdk

/*

extension UIViewController: VKSdkDelegate {
    public func vkSdkNeedCaptchaEnter(captchaError: VKError) { }
    public func vkSdkTokenHasExpired(expiredToken: VKAccessToken) {
    print("vkSdkTokenHasExpired")
    }
    public func vkSdkUserDeniedAccess(authorizationError: VKError) {
        print("vkSdkUserDeniedAccess")
}
    public func vkSdkShouldPresentViewController(controller: UIViewController) {
        print("vkSdkShouldPresentViewController")
        self.navigationController?.topViewController?.presentViewController(controller, animated: true, completion: nil)
}
    public func vkSdkReceivedNewToken(newToken: VKAccessToken) {
        print("vkSdkReceivedNewToken")
    }
}
*/

extension Double {
    func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(self * divisor) / divisor
    }
}


extension NSNumber {
    func toMoney()  -> String {
        let formater = NSNumberFormatter()
        formater.numberStyle = .DecimalStyle
        formater.maximumFractionDigits = 2
        formater.groupingSeparator = " "
        return "\(formater.stringFromNumber(self)!)"
    }
}

extension NSDate {
    struct Date {
        static var formatter = NSDateFormatter()
    }
    var nextWeek:NSDate {
        return NSCalendar.currentCalendar().dateByAddingUnit(
            .Day,
            value: 7,
            toDate: self,
            options: NSCalendarOptions(rawValue: 0))!
    }
    var tomorrow:NSDate {
        return NSCalendar.currentCalendar().dateByAddingUnit(
            .Day,
            value: 1,
            toDate: self,
            options: NSCalendarOptions(rawValue: 0))!
    }
    var yesterday:NSDate {
        return NSCalendar.currentCalendar().dateByAddingUnit(
            .Day,
            value: -1,
            toDate: self,
            options: NSCalendarOptions(rawValue: 0))!
    }
    
    func greaterThan(date: NSDate) -> Bool {
        return self.compare(date) == NSComparisonResult.OrderedDescending
    }
    func lessThan(date: NSDate) -> Bool {
        return self.compare(date) == NSComparisonResult.OrderedAscending
    }
    var timeString: String {
        Date.formatter.dateFormat = "HH-mm-ss"
        return Date.formatter.stringFromDate(self)
    }
    var day: String {
        Date.formatter.dateFormat = "dd"
        return Date.formatter.stringFromDate(self)
    }
    var monthAndYear: String {
        Date.formatter.dateFormat = "MMMM, yy"
        return Date.formatter.stringFromDate(self)
    }
    var time: String {
        Date.formatter.dateFormat = "HH:mm"
        return Date.formatter.stringFromDate(self)
    }
    var weekday: String {
        Date.formatter.dateFormat = "EEEE"
        return Date.formatter.stringFromDate(self)
    }
    var forServerSettings: String {
        Date.formatter.dateFormat = "dd.MM.yyyy"
        return Date.formatter.stringFromDate(self)
    }
    func formatted(format:String) -> String {
        Date.formatter.dateFormat = format
        return Date.formatter.stringFromDate(self)
    }
    func numberOfDaysUntilDateTime(toDateTime: NSDate, inTimeZone timeZone: NSTimeZone? = nil) -> Int {
        let calendar = NSCalendar.currentCalendar()
        if let timeZone = timeZone {
            calendar.timeZone = timeZone
        }
        
        var fromDate: NSDate?, toDate: NSDate?
        
        calendar.rangeOfUnit(.Day, startDate: &fromDate, interval: nil, forDate: self)
        calendar.rangeOfUnit(.Day, startDate: &toDate, interval: nil, forDate: toDateTime)
        
        let difference = calendar.components(.Day, fromDate: fromDate!, toDate: toDate!, options: [])
        return difference.day
    }
}

extension UIColor {
    func colorWithHexString(hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
    
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }
    
        if (cString.characters.count != 6) {
            return UIColor.grayColor()
        }
    
        let rString = (cString as NSString).substringToIndex(2)
        let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
    
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
    
    return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
}


extension String {
    
    subscript(integerIndex: Int) -> Character {
        let index = startIndex.advancedBy(integerIndex)
        return self[index]
    }
    
    subscript(integerRange: Range<Int>) -> String {
        let start = startIndex.advancedBy(integerRange.startIndex)
        let end = startIndex.advancedBy(integerRange.endIndex)
        let range = start..<end
        return self[range]
    }
    
    func URLEncodedString() -> String? {
        var neededString = self
        if !(neededString.hasPrefix("https://") || neededString.hasPrefix("http://") || neededString.hasPrefix("https:\\") || neededString.hasPrefix("http:\\") ) {
            neededString = "http://\(neededString)"
        }
        let customAllowedSet =  NSCharacterSet.URLQueryAllowedCharacterSet()
        let escapedString = neededString.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)
        return escapedString
    }
    
    static func queryStringFromParameters(parameters: Dictionary<String,String>) -> String? {
        if (parameters.count == 0)
        {
            return nil
        }
        var queryString : String? = nil
        for (key, value) in parameters {
            if let encodedKey = key.URLEncodedString() {
                if let encodedValue = value.URLEncodedString() {
                    if queryString == nil
                    {
                        queryString = "?"
                    }
                    else
                    {
                        queryString! += "&"
                    }
                    queryString! += encodedKey + "=" + encodedValue
                }
            }
        }
        return queryString
    }

    
//    func localize() -> String{
//        switch (appLanguage) {
//        case .English:
//             return self
//        case .Russian:
//            for (key, value) in sharedData.languages {
//                if self == key {
//                    return value.nameRus.lenght() == 0 ? self : value.nameRus
//                }
//            }
//            return self
//        }
//    }
    
    
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(self)
    }
    
    
    func contains(find: String) -> Bool{
        return self.rangeOfString(find) != nil
    }
    
    var dashIfEmpty: String {
        if self.lenght() == 0 {
            return "-"
        }
        return self
    }
    
    
    func  removeSpaces() -> String {
        var tempStr = self
        while tempStr.hasPrefix(" ") {
            tempStr = tempStr.dropFirst()
        }
        while tempStr.hasSuffix(" ") {
            tempStr = tempStr.dropLast()
        }
        return tempStr.lowercaseString
    }
    
    func lenght() -> Int{
        let str:NSString = NSString(string: self)
        if str == "\n" {
            return 0
        }
        return str.length
    }
    
    func dropLast(n:Int = 1) ->String{
        if self.lenght() < n {
            return self
        }
        return String(self.characters.dropLast(n))
    }
    func dropFirst(n:Int = 1) ->String{
        if self.lenght() < n {
            return self
        }
        return String(self.characters.dropFirst(n))
    }
    
    func isEmail() -> Bool {
        if let _ = self.rangeOfString("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}", options: .RegularExpressionSearch) {
            return true
        }
        return false
    }
    
    mutating func removeHTTPSymbols() {
        let arrayOfRemovableSimbols: Array<String> = Array(arrayLiteral: "<br>", "</br>", "\n", "<null>")
        var str:String = self
        for element in arrayOfRemovableSimbols {
            str = str.stringByReplacingOccurrencesOfString(element, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        }
        //Some Changes
        str = str.stringByReplacingOccurrencesOfString("&quot;", withString: "\"", options: NSStringCompareOptions.LiteralSearch, range: nil)
        str = str.stringByReplacingOccurrencesOfString("&gt;", withString: ">", options: NSStringCompareOptions.LiteralSearch, range: nil)
        str = str.stringByReplacingOccurrencesOfString("&lt;", withString: "<", options: NSStringCompareOptions.LiteralSearch, range: nil)
        self = str
    }
    
     func withoutHTTPSymbols() -> String{
        let arrayOfRemovableSimbols: Array<String> = Array(arrayLiteral: "<br>", "</br>", "\n", "<null>")
        var str:String = self
        for element in arrayOfRemovableSimbols {
            str = str.stringByReplacingOccurrencesOfString(element, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        }
        //Some Changes
        str = str.stringByReplacingOccurrencesOfString("&quot;", withString: "\"", options: NSStringCompareOptions.LiteralSearch, range: nil)
        str = str.stringByReplacingOccurrencesOfString("&gt;", withString: ">", options: NSStringCompareOptions.LiteralSearch, range: nil)
        str = str.stringByReplacingOccurrencesOfString("&lt;", withString: "<", options: NSStringCompareOptions.LiteralSearch, range: nil)
        return str
    }

    var withoutHTML:String {
        let arrayOfRemovableSimbols: Array<String> = Array(arrayLiteral: "<br>", "</br>", "\n")
        var str:String = self
        for element in arrayOfRemovableSimbols {
            str = str.stringByReplacingOccurrencesOfString(element, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        }
        //Some Changes
        str = str.stringByReplacingOccurrencesOfString("&quot;", withString: "\"", options: NSStringCompareOptions.LiteralSearch, range: nil)
        return  str
    }
    
    var toPrice:String {
        let str:String = self
        if let price = Int(str) {
            return "\(price)"
        }
        if let price = Double(str) {
            return "\(price)"
        }
        return "0"
    }
    
    func leaveNoMoreThan(symbols:Int) -> String {
        let str:String = self
        if str.lenght() <= symbols {
            return str
        }
        
        let fullNameArr = str.characters.split{$0 == " "}.map(String.init)
        var newStr = Array<String>()
        for word in fullNameArr {
            newStr.append(word)
            let stingus = newStr.joinWithSeparator(" ")
            if stingus.lenght() >= symbols {
                return stingus + " ..."
            }
        }
        return newStr.joinWithSeparator(" ")
    }
    
}


extension NSTimer {
    func completeTerminate(){
        while self.valid{
            self.invalidate()
        }
    }
}
extension UIViewController {
    func showVKError(error: VKError){
        showNotification(text: "\(error.errorMessage)")
        if error.captchaImg != nil {
        }
    }
    
    func showNotification(style: JKType = .FAILED, text: String = "", timeOfShowing: NSTimeInterval = 4 ){
        let panel = JKNotificationPanel()
        panel.timeUntilDismiss = timeOfShowing
        panel.enableTabDismiss = true
        panel.delegate = nil
        
        if self.navigationController != nil {
            if text.lenght() == 0 {
                panel.showNotify(withStatus: style, belowNavigation: self.navigationController!)
            } else {
                panel.showNotify(withStatus: style, belowNavigation: self.navigationController!, message: text)
            }
        } else {
            if text.lenght() == 0 {
                panel.showNotify(withStatus: style, inView: self.view)
            } else {
                panel.showNotify(withStatus: style, inView: self.view, message:  text)
            }
        }

    }
}


extension UIImage {
    
    
    public func fixOrientationOfTheImage() -> UIImage{
        
        let size = self.size
        UIGraphicsBeginImageContext(size)
        self.drawInRect(CGRectMake(0,0,size.width ,size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return newImage
    }
}

//ASyn picDownload
extension UIImageView {
    
    public func addParallaxEffect(value:Int = 10) {
        let relativeMotionValue = value
        let verticalMotionEffect : UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y",
            type: .TiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -relativeMotionValue
        verticalMotionEffect.maximumRelativeValue = relativeMotionValue
        
        let horizontalMotionEffect : UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x",
            type: .TiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -relativeMotionValue
        horizontalMotionEffect.maximumRelativeValue = relativeMotionValue
        
        let group : UIMotionEffectGroup = UIMotionEffectGroup()
        group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        self.addMotionEffect(group)
    }
    

    
    
    
    public func imageFromUrlWithOUTCache(urlString: String) {
        if let url = NSURL(string: urlString) {
            let mutableURLRequest = NSMutableURLRequest(URL: url)
            mutableURLRequest.setValue("image/*", forHTTPHeaderField: "Accept")
            mutableURLRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            NSURLConnection.sendAsynchronousRequest(mutableURLRequest, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse?, data: NSData?, error: NSError?) in
                if let imageDowened = UIImage(data: data!) {
                    self.image = imageDowened
                }
            }
        }
    }
    

    
}

extension UIApplication {
    class func tryURL(urls: [String]) {
        let application = UIApplication.sharedApplication()
        for url in urls {
            if application.canOpenURL(NSURL(string: url)!) {
                application.openURL(NSURL(string: url)!)
                return
            }
        }
    }
}




extension NSDate {
    // -> Date System Formatted Medium
    func ToDateMediumString() -> NSString? {
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle;
        formatter.timeStyle = .ShortStyle;
        return formatter.stringFromDate(self)
    }
}


private let DeviceList = [
    /* iPod 5 */          "iPod5,1": "iPod Touch 5",
    /* iPhone 4 */        "iPhone3,1":  "iPhone 4", "iPhone3,2": "iPhone 4", "iPhone3,3": "iPhone 4",
    /* iPhone 4S */       "iPhone4,1": "iPhone 4S",
    /* iPhone 5 */        "iPhone5,1": "iPhone 5", "iPhone5,2": "iPhone 5",
    /* iPhone 5C */       "iPhone5,3": "iPhone 5C", "iPhone5,4": "iPhone 5C",
    /* iPhone 5S */       "iPhone6,1": "iPhone 5S", "iPhone6,2": "iPhone 5S",
    /* iPhone 6 */        "iPhone7,2": "iPhone 6",
    /* iPhone 6 Plus */   "iPhone7,1": "iPhone 6 Plus",
    /* iPad 2 */          "iPad2,1": "iPad 2", "iPad2,2": "iPad 2", "iPad2,3": "iPad 2", "iPad2,4": "iPad 2",
    /* iPad 3 */          "iPad3,1": "iPad 3", "iPad3,2": "iPad 3", "iPad3,3": "iPad 3",
    /* iPad 4 */          "iPad3,4": "iPad 4", "iPad3,5": "iPad 4", "iPad3,6": "iPad 4",
    /* iPad Air */        "iPad4,1": "iPad Air", "iPad4,2": "iPad Air", "iPad4,3": "iPad Air",
    /* iPad Air 2 */      "iPad5,1": "iPad Air 2", "iPad5,3": "iPad Air 2", "iPad5,4": "iPad Air 2",
    /* iPad Mini */       "iPad2,5": "iPad Mini", "iPad2,6": "iPad Mini", "iPad2,7": "iPad Mini",
    /* iPad Mini 2 */     "iPad4,4": "iPad Mini", "iPad4,5": "iPad Mini", "iPad4,6": "iPad Mini",
    /* iPad Mini 3 */     "iPad4,7": "iPad Mini", "iPad4,8": "iPad Mini", "iPad4,9": "iPad Mini",
    /* Simulator */       "x86_64": "Simulator", "i386": "Simulator"
]


extension UIDevice {
   /*
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machine = systemInfo.machine
        let mirror = reflect(machine)
        var identifier = ""
        
        for i in 0..<mirror.count {
            if let value = mirror[i].1.value as? Int8 where value != 0 {
                identifier.append(UnicodeScalar(UInt8(value)))
            }
        }
        return DeviceList[identifier] ?? identifier
    }
    */
}
