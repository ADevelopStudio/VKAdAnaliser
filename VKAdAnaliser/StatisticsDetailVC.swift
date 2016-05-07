//
//  StatisticsDetailVC.swift
//  VKAdAnaliser
//
//  Created by Dmitrii Zverev on 6/05/2016.
//  Copyright © 2016 Dmitrii Zverev. All rights reserved.
//

import UIKit
import Alamofire
import Charts

class StatisticsDetailVC: UIViewController {
    var collectedDataSet = Array<User>()
    var reasonsToRemove = Dictionary<String,Int>()

    @IBOutlet weak var genresChart: HorizontalBarChartView!
    @IBOutlet weak var noiceData: HorizontalBarChartView!
    @IBOutlet weak var agesChart: PieChartView!
    @IBOutlet weak var relatioshipChart: PieChartView!
    @IBOutlet weak var platformChart: PieChartView!
    
    @IBOutlet weak var scroller: UIScrollView!
    
    override func viewDidLoad() {
        
        var totalDeleted = 0
        for (_, value) in reasonsToRemove {
            totalDeleted += value
        }
        title = "Dataset: \(collectedDataSet.count) users"
        print("Dataset: \(collectedDataSet.count) users = \((Double(collectedDataSet.count)/Double(collectedDataSet.count + totalDeleted)*100).roundToPlaces(2))% from all users")
        self.view.backgroundColor = originalDarkGrey
        
        print("\nReasons to remove:")
        displaySortedDict(reasonsToRemove,needToShowPercentage: false)
        agesChart.noDataText = ""

        caltulateStat()
    }

    func caltulateStat(){
        var occupation = Dictionary<String,Int>()
        var age = Dictionary<String,Int>()
        var sex = Dictionary<String,Int>()
        var relation = Dictionary<String,Int>()
        var activities = Dictionary<String,Int>()
        var interests = Dictionary<String,Int>()
        var platforms = Dictionary<String,Int>()

        for user in collectedDataSet {
            if occupation[user.occupation] != nil {
              occupation[user.occupation]!  += 1
            } else {
                occupation[user.occupation] = 1
            }
            
            var ageInterval = "unknown"
            if user.age > 0 && user.age <= 12 {
                ageInterval = "0-12"
            }
            if user.age > 12 && user.age <= 18 {
                ageInterval = "13-18"
            }
            if user.age > 18 && user.age <= 30 {
                ageInterval = "19-30"
            }
            if user.age > 30 && user.age <= 40 {
                ageInterval = "31-40"
            }
            if user.age > 40 && user.age <= 60 {
                ageInterval = "41-60"
            }
            if user.age > 60 {
                ageInterval = "61+"
            }
            
            if age[ageInterval] != nil {
                age[ageInterval]!  += 1
            } else {
                age[ageInterval] = 1
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
            
            if platforms[user.platform.name] != nil {
                platforms[user.platform.name]!  += 1
            } else {
                platforms[user.platform.name] = 1
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
        print("\nData stat:\n")
        print("_occupation_")
        displaySortedDict(occupation)
        print("_age_")
        displaySortedDict(age)
        print("_sex_")
        displaySortedDict(sex)
        print("_relation_")
        displaySortedDict(relation)
        print("_platforms_")
        displaySortedDict(platforms)
        print("_activities_")
        activities = removeNoiceData(activities)
        displaySortedDict(activities)
        print("_interests_")
        interests = removeNoiceData(interests)
        displaySortedDict(interests)
        
        drawNoiceDataChart()
        drawGenresDataChart(sex)
        
        drawPieChart(agesChart, data: age)
    }
    
    func displaySortedDict(dict:Dictionary<String,Int>, needToShowPercentage:Bool = true)  {
        let sortedKeysinterests = dict.keys.sort({ (firstKey, secondKey) -> Bool in
            return dict[firstKey] > dict[secondKey]
        })
        for key in sortedKeysinterests {
            let percentage = needToShowPercentage ? " = \((Double(dict[key]!)/Double(collectedDataSet.count)*100).roundToPlaces(2))%" : ""
            print("\(key.lenght() > 0 ? key : "unknown"): \(dict[key]!) \(percentage)")
        }
        print("\n")
    }
    
    
    func removeNoiceData(dict: Dictionary<String,Int>) ->  Dictionary<String,Int>{
        // remove all data less than 1 percent of all dataset
        var newDict = Dictionary<String,Int>()
        for (key, value) in dict {
            if value > (collectedDataSet.count / 100) && containsOnlyLetters(key) {
               newDict[translateWorld(key)] = value
            }
        }
        return newDict
    }
    
    func translateWorld(str:String, toEng: Bool = true) -> String {
        for element in englishDict {
            if toEng {
            if element.rus == str {
                return element.eng
                }
            } else {
                if element.eng == str {
                    return element.rus
                }
            }
        }
        return str
    }
    
    func containsOnlyLetters(input: String) -> Bool {
        for chr in input.characters {
            if (!(chr >= "a" && chr <= "z") && !(chr >= "а" && chr <= "я")  && !(chr == " ")) {
                return false
            }
        }
        return true
    }
    
    func translateEnToRu(str:String) {
        let preparedStr = prepareToWeb(str)
        Alamofire.request(.POST, "https://translate.yandex.net/api/v1.5/tr.json/translate?key=trnsl.1.1.20160506T134111Z.4dd20cfcbd113ddf.a694898a4b4162d5c87616fb823ba675f6328278&text=\(preparedStr)&lang=ru-en", parameters: nil, encoding: .JSON)
            .responseJSON{
                (response) in
                if response.result.isFailure  || response.result.value == nil {
//                    self.prepareToSearch(str)
                    return
                }
                print("JSON /translateRuToEn:\(response.result.value)")
                let responseJson = JSON(response.result.value!)
                if  responseJson["text"].arrayValue.count > 0 {
                    print(responseJson["text"].arrayValue.first!.stringValue)
//                    self.prepareToSearch(responseJson["text"].arrayValue.first!.stringValue)
                } else {
//                    self.prepareToSearch(str)
                }
        }
    }
    
    func isNeedToTranslate(input: String) -> Bool {
        for chr in input.characters {
            if (chr >= "а" && chr <= "я") {
                return true
            }
        }
        return false
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
    
 
    //Charts
    
    func drawNoiceDataChart()  {
        var arrayOfAges = Array<Double>()
        var arrayOfAgesLabels = Array<String>()
        
        var totalDeleted = 0
        for (_, value) in reasonsToRemove {
            totalDeleted += value
        }
        for (key,value) in reasonsToRemove{
            arrayOfAges.append(Double(value))
            arrayOfAgesLabels.append(key + " (\(value))")
        }
        arrayOfAges.append(Double(collectedDataSet.count))
        arrayOfAgesLabels.append("\(collectedDataSet.count) users with proper details =\((Double(collectedDataSet.count)/Double(collectedDataSet.count + totalDeleted)*100).roundToPlaces(2))% of all data")
        
        let dataSet = BarChartDataSet(yVals: [BarChartDataEntry(values: arrayOfAges, xIndex: 0)], label: "")
        dataSet.colors = [ChartColorTemplates.colorFromString("#626D71"),ChartColorTemplates.colorFromString("#CDCDCO"),ChartColorTemplates.colorFromString("#DDBC95"),ChartColorTemplates.colorFromString("#B38867")]
      
        dataSet.colors = [ChartColorTemplates.colorFromString("#BCBABE"),ChartColorTemplates.colorFromString("#F1F1F2"),
                          ChartColorTemplates.colorFromString("#A1D6E2"),ChartColorTemplates.colorFromString("#1995AD")]
        dataSet.stackLabels = arrayOfAgesLabels

        let pieData =  BarChartData(xVals: [""], dataSet: dataSet)
        pieData.setValueTextColor(UIColor.clearColor())
        noiceData.data = pieData
        
        noiceData.drawGridBackgroundEnabled = false
        noiceData.dragEnabled = false
        noiceData.pinchZoomEnabled = false
        noiceData.rightAxis.enabled = false
        noiceData.leftAxis.enabled = false
        noiceData.xAxis.enabled = false
        noiceData.drawValueAboveBarEnabled = false
        noiceData.legend.position = .BelowChartLeft
        noiceData.legend.wordWrapEnabled = true
        noiceData.legend.textColor = UIColor.whiteColor()
        noiceData.legend.font = UIFont.systemFontOfSize(14)
        noiceData.descriptionText = ""
        noiceData.userInteractionEnabled = false
        noiceData.animate(yAxisDuration: 2)
    }
    
    func drawGenresDataChart(ar:Dictionary<String,Int>)  {
        var arrayOfAges = Array<Double>()
        var arrayOfAgesLabels = Array<String>()
       
        var total = 0
        for (_,value) in ar{
            total += value
        }
        
        for (key,value) in ar{
            arrayOfAges.append(Double(value)/Double(total))
            arrayOfAgesLabels.append(key + " (\(value))")
        }
        
        let dataSet = BarChartDataSet(yVals: [BarChartDataEntry(values: arrayOfAges, xIndex: 0)], label: "")
        dataSet.colors = [ChartColorTemplates.colorFromString("#DDBC95"),ChartColorTemplates.colorFromString("#B38867"),ChartColorTemplates.colorFromString("#626D71")]
        
        dataSet.stackLabels = arrayOfAgesLabels
        
        let pieData =  BarChartData(xVals: [""], dataSet: dataSet)
        pieData.setValueTextColor(UIColor.whiteColor())
        pieData.setValueFont(UIFont.systemFontOfSize(12))
        
        let pFormatter = NSNumberFormatter()
        pFormatter.numberStyle = .PercentStyle
        pFormatter.maximumFractionDigits = 1
        pFormatter.percentSymbol = " %"
        pieData.setValueFormatter(pFormatter)
        
        genresChart.data = pieData
        
        genresChart.drawGridBackgroundEnabled = false
        genresChart.dragEnabled = false
        genresChart.pinchZoomEnabled = false
        genresChart.rightAxis.enabled = false
        genresChart.leftAxis.enabled = false
        genresChart.xAxis.enabled = false
        genresChart.drawValueAboveBarEnabled = false
        genresChart.legend.position = .BelowChartLeft
        genresChart.legend.wordWrapEnabled = true
        genresChart.legend.textColor = UIColor.whiteColor()
        genresChart.legend.font = UIFont.systemFontOfSize(14)
        genresChart.descriptionText = ""
        genresChart.userInteractionEnabled = false
        genresChart.animate(yAxisDuration: 2)
    }
    

    func drawPieChart(chart:PieChartView , data:Dictionary<String,Int>) {
        var arrayOfAges = Array<BarChartDataEntry>()
        var arrayOfAgesLabels = Array<String>()
        
        
        var total = 0
        for (_, value) in data {
            total += value
        }
        var index = 0
        for (key,value) in data{
            arrayOfAges.append(BarChartDataEntry(value: Double(value), xIndex: index))
            arrayOfAgesLabels.append(key + " (\(value))")
            index += 1
        }
            setupPieChart(chart, yValues: arrayOfAges, xValues: arrayOfAgesLabels, centerTextText: "Data set", colors: ChartColorTemplates.liberty(), enableLegend: true)
    }
    
    
    func setupPieChart(pieChart: PieChartView, yValues: Array<BarChartDataEntry>, xValues:  Array<String>,centerTextText:String, colors:[NSUIColor], enableLegend: Bool = false){
        let dataSet = PieChartDataSet(yVals: yValues, label: "")
        dataSet.sliceSpace = 1.0;
        dataSet.colors = colors

        let pieData =  PieChartData(xVals: xValues, dataSet: dataSet)
        
        let pFormatter = NSNumberFormatter()
        pFormatter.numberStyle = .DecimalStyle
        pFormatter.maximumFractionDigits = 0

        let charFont = UIFont.systemFontOfSize(12)
        pieData.setValueFormatter(pFormatter)
        pieData.setValueFont(charFont)
        pieData.setValueTextColor(UIColor.darkGrayColor())
        
        let centerText = NSMutableAttributedString(
            string: centerTextText,
            attributes:nil
        )
        centerText.addAttribute(
            NSForegroundColorAttributeName,
            value: UIColor.whiteColor(),
            range: NSRange(location: 0,length: centerTextText.lenght())
        )
        centerText.addAttribute(
            NSFontAttributeName,
            value: UIFont.systemFontOfSize(15),
            range: NSRange(location: 0,length: centerTextText.lenght())
        )
        var allowToRotate = true
        for element in yValues where element.value == 1{ //remove UI bag of rotation chart with 100% value
            allowToRotate = false
            break
        }
        
//        pieChart.centerAttributedText = centerText
        
        pieChart.drawHoleEnabled = true
        pieChart.holeColor = UIColor.clearColor()
        pieChart.rotationAngle = xValues.count > 1 ? 0.0 : 270.0;
        pieChart.rotationEnabled = allowToRotate
        pieChart.rotationWithTwoFingers = allowToRotate
        pieChart.highlightPerTapEnabled = true
        pieChart.data = pieData
        pieChart.descriptionText = ""
        pieChart.legend.position = .PiechartCenter
        pieChart.legend.textColor = UIColor.whiteColor()
        pieChart.legend.enabled = enableLegend
        pieChart.legend.wordWrapEnabled = true
        pieChart.legend.font = UIFont.systemFontOfSize(14)
        pieChart.animate(xAxisDuration: 2)
    }
}
