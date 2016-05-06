//
//  ViewController.swift
//  VKAdAnaliser
//
//  Created by Dmitrii Zverev on 6/05/2016.
//  Copyright © 2016 Dmitrii Zverev. All rights reserved.
//

import UIKit
import VK_ios_sdk
import KVNProgress
import Alamofire

extension UIViewController : CNPPopupControllerDelegate {
    
    func popupController(controller: CNPPopupController, dismissWithButtonTitle title: NSString) {
        print("Dismissed with button title \(title)")
    }
    
    public func popupControllerDidPresent(controller: CNPPopupController) {
        print("Popup controller presented")
    }
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
         return NSAttributedString(string: categories[row].name, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(15), NSForegroundColorAttributeName: UIColor.whiteColor()])
    }
}

extension ViewController: VKSdkDelegate, VKSdkUIDelegate {
    
    func vkSdkAccessAuthorizationFinishedWithResult(result: VKAuthorizationResult!) {
        if result == nil || result.token == nil || result.token.accessToken == nil {return }
        if VKSdk.accessToken() != nil && VKSdk.accessToken().userId != nil {
            self.getSuggestions()
        } else { print("Hm... vk error vkSdkAccessAuthorizationFinishedWithResult") }
    }
    
    func vkSdkAcceptedUserToken(token: VKAccessToken!) {    }
    func vkSdkUserAuthorizationFailed(){ }
    func vkSdkNeedCaptchaEnter(captchaError: VKError) { }
    func vkSdkTokenHasExpired(expiredToken: VKAccessToken) { }
    func vkSdkUserDeniedAccess(authorizationError: VKError) {  }
    override func vks_presentViewControllerThroughDelegate() { }
    
    func vkSdkShouldPresentViewController(controller: UIViewController) {
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func vkSdkReceivedNewToken(newToken: VKAccessToken) {
        if VKSdk.accessToken() != nil && VKSdk.accessToken().userId != nil {
            self.getSuggestions()
        } else { print("Hm... vk error vkSdkReceivedNewToken") }
    }
    
}



class ViewController: UIViewController {
    var popupController:CNPPopupController = CNPPopupController()
    var categories = Array<DZCategory>()
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var startBtn: UIButton!

    var numOfDownloadedUserSets = 0
    var users = Array<String>()
    var collectedDataSet = Array<User>()

    override func viewDidLoad() {
        super.viewDidLoad()
        VKSdk.initializeWithAppId("5450149").registerDelegate(self)
        VKSdk.instance().uiDelegate = self
        picker.delegate = self
        picker.dataSource = self
        self.view.backgroundColor = originalDarkGrey
        startBtn.layer.borderColor = UIColor.whiteColor().CGColor
        startBtn.layer.borderWidth = 2
        startBtn.clipsToBounds = true
        startBtn.layer.cornerRadius =  startBtn.layer.bounds.height/2
        
        setActive(false)
        if defaults.boolForKey("alreadyLaunched") == true {
            vkConnect()
        } else {
            self.showPopupWithStyle(CNPPopupStyle.Centered)
        }
    }

    func setActive(isActive:Bool){
        title = isActive ? "VKAdAnaliser \(NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]!)" : "Connecting to VK..."
        if isActive{
            trackVisitor()
            KVNProgress.dismiss()
        }
        startBtn.hidden = !isActive
        picker.hidden = !isActive
    }

    func showPopupWithStyle(popupStyle: CNPPopupStyle) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraphStyle.alignment = NSTextAlignment.Center
        paragraphStyle.lineSpacing = 1
        
        let paragraphStyle2 = NSMutableParagraphStyle()
        paragraphStyle2.lineBreakMode = .ByWordWrapping
        paragraphStyle2.alignment = .Left
        paragraphStyle2.lineSpacing = 1
        
        let title = NSAttributedString(string: "VKAdAnaliser \(NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]!)", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(15), NSForegroundColorAttributeName: originalBlue, NSParagraphStyleAttributeName: paragraphStyle])
        
        let lineOne = NSAttributedString(string: "You need to connect to VKontakte", attributes: [NSFontAttributeName:UIFont.systemFontOfSize(17), NSParagraphStyleAttributeName: paragraphStyle])
        let lineTwo = NSAttributedString(string: "or register", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14), NSForegroundColorAttributeName: originalDarkGrey, NSParagraphStyleAttributeName: paragraphStyle2])
        
        let button = CNPPopupButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = 3
        button.backgroundColor =  originalBlue
        button.layer.borderColor = UIColor.whiteColor().CGColor
        button.layer.borderWidth = 2
        button.frame =  CGRectMake(0, 0, 200, 50)
        button.titleLabel?.font = UIFont.systemFontOfSize(17)
        button.setTitle("Поехали!", forState: UIControlState.Normal)
        button.selectionHandler = { (button) -> Void in
            self.popupController.dismissPopupControllerAnimated(true)
            defaults.setBool(true, forKey: "alreadyLaunched")
            self.vkConnect()
        }
        
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0;
        titleLabel.attributedText = title
        
        let lineOneLabel = UILabel()
        lineOneLabel.numberOfLines = 0;
        lineOneLabel.attributedText = lineOne;
        
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        
        imageView.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        imageView.backgroundColor = originalBlue
        
        let imageViewLogo = UIImageView.init(image: UIImage.init(named: "logo"))
        imageViewLogo.frame = CGRect(x: 10, y: 10, width: 50, height: 50)
        imageView.addSubview(imageViewLogo)
        
        let lineTwoLabel = UILabel()
        lineTwoLabel.numberOfLines = 0;
        lineTwoLabel.attributedText = lineTwo;
        
        self.popupController = CNPPopupController(contents:[titleLabel,imageView, lineOneLabel, lineTwoLabel, button])
        let themeP = CNPPopupTheme.defaultTheme()
        themeP.shouldDismissOnBackgroundTouch = false
        self.popupController.theme = themeP
        self.popupController.theme.popupStyle = popupStyle
        self.popupController.delegate = self
        self.popupController.presentPopupControllerAnimated(true)
    }
    
    
    func vkConnect(){
        KVNProgress.showWithStatus("Connection")
        if !VKSdk.isLoggedIn() {
            VKSdk.wakeUpSession(VKSCOPE, completeBlock: ({
                (state, error) in
                switch state {
                case .Authorized:
                    print("Authorized:" + VKSdk.accessToken().userId)
                    self.getSuggestions()
                    break
                default:
                    if VKSdk.vkAppMayExists() {
                        VKSdk.authorize(VKSCOPE)
                    } else {
                        VKSdk.authorize(VKSCOPE, withOptions: .DisableSafariController)
                    }
                    break
                }
            }))
            
        } else {
            self.getSuggestions()
            print("Already logined \(VKSdk.accessToken().userId)")
        }
    }
    
    func trackVisitor(){
        let request =  VKRequest(method: "stats.trackVisitor", parameters: nil)
        request.executeWithResultBlock({ response in
            print("Success stats.trackVisitor")
            }, errorBlock: {error in
                print("error stats.trackVisitor \(error)")
        })
    }
    
    func getSuggestions()  {
            let request =  VKRequest(method: "ads.getSuggestions", parameters: ["lang": "ru", "section":"interest_categories"])
            request.executeWithResultBlock({ response in
                print("Success getSuggestions")
                self.categories = []
                
                let metadata = JSON(response.json)
                for element in metadata.arrayValue {
                    self.categories.append(DZCategory(json: element))
                }
                print(metadata)
                print("self.categories.count = \(self.categories.count)")
                self.picker.reloadAllComponents()
                self.setActive(true)
                }, errorBlock: {error in
                    self.showVKError(error.vkError)
                    print("error \(error)")
            })
            
    }
    
    @IBAction func startPressed(sender: AnyObject) {
        KVNProgress.showWithStatus("Collecting data")
        translateEnToRu(categories[picker.selectedRowInComponent(0)].name)
    }

    
    func translateEnToRu(str:String) {
        let preparedStr = prepareToWeb(str)
        Alamofire.request(.POST, "https://translate.yandex.net/api/v1.5/tr.json/translate?key=trnsl.1.1.20160506T134111Z.4dd20cfcbd113ddf.a694898a4b4162d5c87616fb823ba675f6328278&text=\(preparedStr)&lang=en-ru", parameters: nil, encoding: .JSON)
            .responseJSON{
                (response) in
                if response.result.isFailure  || response.result.value == nil {
                    self.prepareToSearch(str)
                    return
                }
                print("JSON /translateEnToRu:\(response.result.value)")
                let responseJson = JSON(response.result.value!)
                if  responseJson["text"].arrayValue.count > 0 {
                    print(responseJson["text"].arrayValue.first!.stringValue)
                    self.prepareToSearch(responseJson["text"].arrayValue.first!.stringValue)
                } else {
                    self.prepareToSearch(str)
                }
        }
    }
    
    func prepareToSearch(text: String) {
        //Searching top 10 (by number of user's visitings per day) social groups
        /*
         sortType:
         0 — defaults;
         1 — by speed of growing;
         2 — by number of users per day;
         3 — ratio: num of likes per one user;
         4 — ratio: num of comments per one user
         5 — ratio: num of post per one user .
         */
        prepareToWeb("searchTExt  = \(text)")
        searchGroups(5,sortType: 2, text: text)
    }
    
    func prepareToWeb(input: String) -> String {
        var tempStr = input
            for chr in tempStr.characters {
                if (!(chr >= "a" && chr <= "z") && !(chr >= "а" && chr <= "я")) {
                    tempStr = tempStr.stringByReplacingOccurrencesOfString("\(chr)", withString: "%20", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
                }
            }
            return tempStr
    }
    
    func searchGroups(numOfGroups:Int, sortType:Int, text: String) {
        users = []
        collectedDataSet = []
        
        let request =  VKRequest(method: "groups.search", parameters: ["q": text, "type":"group", "sort":"\(sortType)" , "count": "\(numOfGroups)"])
        request.executeWithResultBlock({ response in
            print("Success groups.search")
            let metadata = JSON(response.json)
            print(metadata)
            self.numOfDownloadedUserSets = metadata["items"].arrayValue.count
            for element in metadata["items"].arrayValue {
                self.getNumberUsersInGroup(DZCategory(json: element).id)
            }
            }, errorBlock: {error in
                self.showVKError(error.vkError)
                KVNProgress.showErrorWithStatus("VK Error")
                print("error \(error)")
        })
    }
    
    func getNumberUsersInGroup(id:String)  {
        let request =  VKRequest(method: "groups.getById", parameters: ["group_id":id, "fields":"members_count,screen_name"])
        request.executeWithResultBlock({ response in
            print("Success getNumberUsersInGroup \(id)")
            let metadata = JSON(response.json)
            let ar = metadata.arrayValue
            if ar.count > 0 && ar.first!["members_count"].intValue > 2000 {
                self.getUsersInGroup(id, offset: ar.first!["members_count"].intValue/2)
            } else {
                self.getUsersInGroup(id)
            }
            }, errorBlock: {error in
                self.showVKError(error.vkError)
                print("error \(error)")
        })
    }
    
    func getUsersInGroup(id:String, offset: Int = 0) {
        let request =  VKRequest(method: "groups.getMembers", parameters: ["group_id":id, "offset": "\(offset)", "count":"1000", "sort" :"id_desc"])
        request.executeWithResultBlock({ response in
            print("Success groups.getMembers \(id)")
            let metadata = JSON(response.json)
            var usersOfThatGroup = Array<String>()
            for user in metadata["items"].arrayValue {
                if  !self.users.contains(user.stringValue) {
                    self.users.append(user.stringValue)
                    usersOfThatGroup.append(user.stringValue)
                }
            }
            self.getUsersDetail(usersOfThatGroup)
            }, errorBlock: {error in
                self.showVKError(error.vkError)
                print("error \(error)")
        })
    }
    
    func isAllUsersDownload() {
        numOfDownloadedUserSets -= 1
        if numOfDownloadedUserSets == 0 {
            print("AllDone numOfDownloadedUserSets total \(collectedDataSet.count)")
            KVNProgress.showSuccessWithStatus("Collected: \(collectedDataSet.count)",completion:  { _ in
                self.performSegueWithIdentifier("statistics", sender: nil)
            })
        }
    }
    
    func getUsersDetail(ids:Array<String>)  {
        let request =  VKRequest(method: "users.get", parameters: ["user_ids":ids.joinWithSeparator(","),
            "fields":"sex, bdate, city, country, occupation, relation, personal, activities, interests" ])
        request.executeWithResultBlock({ response in
            let metadata = JSON(response.json)
            print("Success getUsersDetail \(ids.count) -> \( metadata.arrayValue.count)")
            for user in metadata.arrayValue {
                self.collectedDataSet.append(User(json: user))
            }
            self.isAllUsersDownload()
            }, errorBlock: {error in
                self.showVKError(error.vkError)
                print("error \(error)")
                self.isAllUsersDownload()
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if  let destinationVC = segue.destinationViewController as? StatisticsDetailVC {
            destinationVC.collectedDataSet = collectedDataSet
        }
    }
    
}

