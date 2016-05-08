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

    @IBOutlet weak var interestsChart: HorizontalBarChartView!
    @IBOutlet weak var genresChart: HorizontalBarChartView!
    @IBOutlet weak var noiceData: HorizontalBarChartView!
    @IBOutlet weak var agesChart: PieChartView!
    @IBOutlet weak var relatioshipChart: PieChartView!
    @IBOutlet weak var platformChart: PieChartView!
    
    var isAnalised = false
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
        
        self.drawBarChart(self.interestsChart, data: interests)
        self.drawPieChart(self.agesChart, data: age, labelStr: " y.o. ")
        self.drawPieChart(self.relatioshipChart, data: relation)
    
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
                newDict[key] = value
//                newDict[translateWorld(key)] = value
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
        noiceData.legend.horizontalAlignment = .Center
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
        dataSet.colors = [ChartColorTemplates.colorFromString("#DDBC95"),ChartColorTemplates.colorFromString("#B38867"),ChartColorTemplates.colorFromString("#CDCDC0")]
        
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
//        [_chartView setExtraOffsetsWithLeft:0.f top:50.f right:0.f bottom:50.f];
        genresChart.drawGridBackgroundEnabled = false
        genresChart.dragEnabled = false
        genresChart.pinchZoomEnabled = false
        genresChart.rightAxis.enabled = false
        genresChart.leftAxis.enabled = false
        genresChart.xAxis.enabled = false
        genresChart.drawValueAboveBarEnabled = false
        genresChart.legend.horizontalAlignment = .Center
        genresChart.legend.wordWrapEnabled = true
        genresChart.legend.textColor = UIColor.whiteColor()
        genresChart.legend.font = UIFont.systemFontOfSize(14)
        genresChart.descriptionText = ""
        genresChart.userInteractionEnabled = false
        genresChart.animate(yAxisDuration: 2)
    }
    

    func drawPieChart(chart:PieChartView , data:Dictionary<String,Int>, labelStr: String = " ") {
        var arrayOfAges = Array<BarChartDataEntry>()
        var arrayOfAgesLabels = Array<String>()
        var total = 0
        for (_, value) in data {
            total += value
        }
        var index = 0
        
        
        
        let sortedKeysinterests = data.keys.sort({ (firstKey, secondKey) -> Bool in
            return data[firstKey] > data[secondKey]
        })
        for key in sortedKeysinterests {
            arrayOfAges.append(BarChartDataEntry(value: Double(data[key]!)/Double(total), xIndex: index))
            arrayOfAgesLabels.append(key + labelStr + "(\(data[key]!))")
            index += 1

        }
        
//        
//        
//        
//        for (key,value) in data{
//            arrayOfAges.append(BarChartDataEntry(value: Double(value)/Double(total), xIndex: index))
//            arrayOfAgesLabels.append(key + labelStr + "(\(value))")
//            index += 1
//        }
            setupPieChart(chart, yValues: arrayOfAges, xValues: arrayOfAgesLabels, centerTextText: "Data set", colors: ChartColorTemplates.liberty(), enableLegend: true)
    }
    
    
    func setupPieChart(pieChart: PieChartView, yValues: Array<BarChartDataEntry>, xValues:  Array<String>,centerTextText:String, colors:[NSUIColor], enableLegend: Bool = false){
        let dataSet = PieChartDataSet(yVals: yValues, label: "")
        dataSet.sliceSpace = 1.0;
        dataSet.colors = colors + colors + colors
        dataSet.xValuePosition = .OutsideSlice
        let pieData =  PieChartData(xVals: xValues, dataSet: dataSet)
        
        let pFormatter = NSNumberFormatter()
        pFormatter.numberStyle = .PercentStyle
        pFormatter.maximumFractionDigits = 1
        pFormatter.percentSymbol = " %"
        pieData.setValueFormatter(pFormatter)

        let charFont = UIFont.systemFontOfSize(13)
        pieData.setValueFont(charFont)
        pieData.setValueTextColor(UIColor.whiteColor())
        
        var allowToRotate = true
        for element in yValues where element.value == 1{ //remove UI bag of rotation chart with 100% value
            allowToRotate = false
            break
        }
        
        pieChart.drawHoleEnabled = true
        pieChart.holeColor = UIColor.clearColor()
        pieChart.rotationAngle = xValues.count > 1 ? 0.0 : 270.0;
        pieChart.rotationEnabled = allowToRotate
        pieChart.rotationWithTwoFingers = allowToRotate
        pieChart.highlightPerTapEnabled = true
        pieChart.data = pieData
        pieChart.descriptionText = ""
        pieChart.legend.horizontalAlignment = .Left
        pieChart.legend.drawInside = false
        pieChart.legend.textColor = UIColor.whiteColor()
        pieChart.legend.enabled = enableLegend
        pieChart.legend.wordWrapEnabled = true
        pieChart.legend.font = UIFont.systemFontOfSize(14)
        pieChart.animate(xAxisDuration: 2)
    }
    
    func drawBarChart(chart:HorizontalBarChartView , data:Dictionary<String,Int>)  {
        let pFormatter = NSNumberFormatter()
        pFormatter.numberStyle = .DecimalStyle
        
        chart.noDataText = "Analysis in progress, please wait"
        chart.legend.wordWrapEnabled = true
        chart.legend.textColor = UIColor.whiteColor()
        chart.legend.font = UIFont.systemFontOfSize(14)
        chart.descriptionText = ""
        chart.userInteractionEnabled = true
        chart.leftAxis.axisMinValue = 0.0;
        chart.leftAxis.drawGridLinesEnabled = true
        chart.rightAxis.drawGridLinesEnabled = true
        chart.xAxis.drawGridLinesEnabled = false
        chart.xAxis.drawAxisLineEnabled = true
        chart.drawGridBackgroundEnabled = false
        chart.dragEnabled = true
        chart.pinchZoomEnabled = true
        chart.rightAxis.enabled = false
        chart.leftAxis.enabled = true
        chart.xAxis.enabled = true
        chart.leftAxis.labelPosition = .OutsideChart
        chart.leftAxis.labelTextColor = UIColor.whiteColor()
        chart.xAxis.labelPosition = .Bottom
        chart.xAxis.labelTextColor = UIColor.whiteColor()
        chart.legend.horizontalAlignment = .Center
        chart.leftAxis.valueFormatter = pFormatter

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var arrayOfAgesLabels = Array<String>()
                var entyties = Array<BarChartDataEntry>()
                var totalDeleted = 0
                for (_, value) in data {
                    totalDeleted += value
                }
            
                var index = 0
                let sortedKeysinterests = data.keys.sort({ (firstKey, secondKey) -> Bool in
                    return data[firstKey] > data[secondKey]
                })
                    
                var top5Keys = Array<String>()
                for key in sortedKeysinterests {
                    top5Keys.append(key)
                    index += 1
                    if index >= 10 {break}
                }
                index = 0
                for key in top5Keys.reverse() {
                    var maleCount:Double = 0
                    var femaleCount:Double = 0
                    var unknownCount:Double = 0
                    for user in self.collectedDataSet {
                        for interest in user.interests where interest == key{
                            switch user.sex {
                            case .Female:
                                femaleCount += 1
                                break
                            case .Male:
                                maleCount += 1
                                break
                            case .Unknown:
                                unknownCount += 1
                                break
                            }
                        }
                    }
//                    print("key  \(key)  value  = \(data[key]!)   calculated = \(maleCount + femaleCount + unknownCount)")
                    if maleCount + femaleCount + unknownCount == 0 { continue }
                    entyties.insert((BarChartDataEntry(values: [femaleCount,maleCount, unknownCount], xIndex: index)), atIndex: 0)
                    arrayOfAgesLabels.append(key + " (\(data[key]!))")
                    index += 1
                    if index >= 10 {break}
                }
            
        dispatch_async(dispatch_get_main_queue(), {

                let dataSet = BarChartDataSet(yVals: entyties, label: "")
                dataSet.colors = [ChartColorTemplates.colorFromString("#DDBC95"),ChartColorTemplates.colorFromString("#B38867"),ChartColorTemplates.colorFromString("#CDCDC0")]
                dataSet.stackLabels = ["Female", "Male", "Unknown"]
                dataSet.drawValuesEnabled = false
            
                let pieData =  BarChartData(xVals: arrayOfAgesLabels, dataSet: dataSet)
                pieData.setValueTextColor(UIColor.whiteColor())
                pieData.setValueFormatter(pFormatter)

                chart.data = pieData
                chart.animate(xAxisDuration: 2, yAxisDuration: 2)
                });
        });
    }
    
}
