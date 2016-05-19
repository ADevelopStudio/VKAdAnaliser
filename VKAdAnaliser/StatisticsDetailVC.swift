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

    @IBOutlet weak var unknownAgeSwitcher: UISwitch!
    @IBOutlet weak var unknownRelationshipSwitcher: UISwitch!
    @IBOutlet weak var interestsChart: HorizontalBarChartView!
    @IBOutlet weak var genresChart: HorizontalBarChartView!
    @IBOutlet weak var noiceData: HorizontalBarChartView!
    @IBOutlet weak var agesChart: PieChartView!
    @IBOutlet weak var relatioshipChart: PieChartView!
    @IBOutlet weak var platformChart: PieChartView!
    @IBOutlet weak var segmenter: UISegmentedControl!
    @IBOutlet weak var mainStatBubleChart: BubbleChartView!
    @IBOutlet weak var scroller: UIScrollView!
    @IBOutlet weak var resultKeys: UILabel!
    @IBOutlet weak var resultAge: UILabel!
    @IBOutlet weak var resultGender: UILabel!
    
    var collectedDataSet = Array<User>()
    var reasonsToRemove = Dictionary<String,Int>()
    
    var isAnalised = false
    var maximumInterest = 0
    var occupation = Dictionary<String,Int>()
    var age = Dictionary<String,Int>()
    var sex = Dictionary<String,Int>()
    var relation = Dictionary<String,Int>()
    var activities = Dictionary<String,Int>()
    var interests = Dictionary<String,Int>()
    var platforms = Dictionary<String,Int>()
    
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
            if user.age > 18 && user.age <= 24 {
                ageInterval = "19-24"
            }
            if user.age > 24 && user.age <= 30 {
                ageInterval = "25-30"
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
        self.drawPieChart(self.agesChart, data: age, isAge: true)
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
            if value > (collectedDataSet.count / 100) && containsOnlyLetters(key) && key != "музыка" {
                newDict[key] = value
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
    
 
    @IBAction func unknownAgePressed(sender: AnyObject) {
        self.drawPieChart(self.agesChart, data: age, needToShowUnknown: unknownAgeSwitcher.on, isAge: true)
    }
    
    @IBAction func unknownRelationshipPressed(sender: AnyObject) {
        self.drawPieChart(self.relatioshipChart, data: relation, needToShowUnknown: unknownRelationshipSwitcher.on)
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

        //For conclusion:
        var numOfFemale:Double = 0
        var numOfMale:Double = 0
        for (key,value) in ar where key == User.Sex.Female.name{
            numOfFemale = Double(value)
        }
        for (key,value) in ar where key == User.Sex.Male.name{
            numOfMale = Double(value)
        }
        
        resultGender.text = numOfFemale > numOfMale ? ("Genger: \((numOfFemale > numOfMale * 1.5) ? User.Sex.Female.name : "Both")" ) : ("Genger: \((numOfMale > numOfFemale * 1.3) ? User.Sex.Male.name : "Both")")

    }
    


    func drawPieChart(chart:PieChartView , data:Dictionary<String,Int>, needToShowUnknown: Bool = true, isAge: Bool = false) {
        var arrayOfAges = Array<BarChartDataEntry>()
        var arrayOfAgesLabels = Array<String>()
        
        var total = 0
        for (key , value) in data {
            if needToShowUnknown || key.lowercaseString != "unknown"{
            total += value
            }
        }
        var index = 0

        let sortedKeysinterests = data.keys.sort({ (firstKey, secondKey) -> Bool in
            return data[firstKey] > data[secondKey]
        })
        for key in sortedKeysinterests {
            if !needToShowUnknown && key.lowercaseString == "unknown" {continue}
            arrayOfAges.append(BarChartDataEntry(value: Double(data[key]!)/Double(total), xIndex: index))
            arrayOfAgesLabels.append(key + (isAge ? " y.o." : "") + "(\(data[key]!))")
            index += 1

        }
        
        setupPieChart(chart, yValues: arrayOfAges, xValues: arrayOfAgesLabels, centerTextText: "Data set", colors: ChartColorTemplates.liberty(), enableLegend: true)
       
        //Conclusion
        if isAge {
            var index =  0
            var firstValue = 0
            var firstKey = ""
            var secondValue = 0
            var secondKey = ""
            var unknownValue = 0
            for key in sortedKeysinterests {
                if  key.lowercaseString != "unknown" {
                    if index == 0 {
                        firstValue = data[key]!
                        firstKey = key
                    } else {
                        secondValue = data[key]!
                        secondKey = key
                    }
                    index += 1
                    if index == 2 {break}
                } else {
                    unknownValue =  data[key]!
                }
            }
            resultAge.text = "Age: \((firstValue > Int(Double(secondValue) * 1.3)) ? firstKey: " \(firstKey), \(secondKey)")" + "\((unknownValue > (firstValue + secondValue)) ? " or without age" : "")"
        }
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
        
        
        mainStatBubleChart.noDataText = "Analysis in progress, please wait"
        mainStatBubleChart.legend.wordWrapEnabled = true
        mainStatBubleChart.legend.textColor = UIColor.whiteColor()
        mainStatBubleChart.legend.font = UIFont.systemFontOfSize(14)
        mainStatBubleChart.descriptionText = ""
        mainStatBubleChart.userInteractionEnabled = true
        mainStatBubleChart.leftAxis.axisMinValue = 0.0;
        mainStatBubleChart.xAxis.axisMaxValue = 100.0;
        mainStatBubleChart.leftAxis.drawGridLinesEnabled = true
        mainStatBubleChart.rightAxis.drawGridLinesEnabled = true
        mainStatBubleChart.xAxis.drawGridLinesEnabled = true
        mainStatBubleChart.xAxis.drawAxisLineEnabled = true
        mainStatBubleChart.drawGridBackgroundEnabled = false
        mainStatBubleChart.dragEnabled = true
        mainStatBubleChart.pinchZoomEnabled = true
        mainStatBubleChart.rightAxis.enabled = false
        mainStatBubleChart.leftAxis.enabled = true
        mainStatBubleChart.xAxis.enabled = true
        mainStatBubleChart.leftAxis.labelPosition = .OutsideChart
        mainStatBubleChart.leftAxis.labelTextColor = UIColor.whiteColor()
        mainStatBubleChart.xAxis.labelPosition = .Bottom
        mainStatBubleChart.xAxis.labelTextColor = UIColor.whiteColor()
        mainStatBubleChart.legend.horizontalAlignment = .Left
        mainStatBubleChart.legend.verticalAlignment = .Bottom
        mainStatBubleChart.leftAxis.valueFormatter = pFormatter
        
        

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
            
            //Conclusion
            var indexKey =  0
            var firstValue = 0
            var firstKey = ""
            var secondValue = 0
            var secondKey = ""
            
            for key in top5Keys{
                if indexKey == 0 {
                    firstValue = data[key]!
                    firstKey = self.translateWorld(key)
                } else {
                    secondValue = data[key]!
                    secondKey = self.translateWorld(key)
                }
                indexKey += 1
                if indexKey == 2 {break}
            }

            self.resultKeys.text = "Keyworlds: \((firstValue >= Int(Double(secondValue) * 1.2)) ? firstKey : " \(firstKey), \(secondKey)")"
            //End Of conclusion
            
            
            
            //Second graph
            let arrayOfKeys = ["0-12", "13-18", "19-24", "25-30", "31-40", "41-60" , "61+", "unknown","ignore this"]
             var wholeGraph2Data = Array<Dictionary<String,Int>>()
            
            //Getting max num Of Inetersts = 
            var ageMax = Dictionary<String,Int>()
            for key in top5Keys.reverse() {
                var ageTest = Dictionary<String,Int>()
                for user in self.collectedDataSet {
                    for interest in user.interests where interest == key
                    {
                        var ageInterval = "unknown"
                        if user.age > 0 && user.age <= 12 {
                            ageInterval = "0-12"
                        }
                        if user.age > 12 && user.age <= 18 {
                            ageInterval = "13-18"
                        }
                        if user.age > 18 && user.age <= 24 {
                            ageInterval = "19-24"
                        }
                        if user.age > 24 && user.age <= 30 {
                            ageInterval = "25-30"
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
//                        if ageInterval != "unknown" {
                            ageTest[ageInterval] = (ageTest[ageInterval] ?? 0) + 1
//                        }
                    }
                }
                var max = 0
                for (_, value) in ageTest {
                    if max < value { max = value }
                }
                ageMax[key] = max
            }
            
            for (_, value) in ageMax { if self.maximumInterest < value { self.maximumInterest = value } }
            //END OF Getting max num Of Inetersts =
            
                for key in top5Keys.reverse() {
                    var maleCount:Double = 0
                    var femaleCount:Double = 0
                    var unknownCount:Double = 0
                    var age2 = Dictionary<String,Int>()
                    
                    for user in self.collectedDataSet {
                        for interest in user.interests where interest == key
                        {
                            //Second graph
                            var ageInterval = "unknown"
                            if user.age > 0 && user.age <= 12 {
                                ageInterval = "0-12"
                            }
                            if user.age > 12 && user.age <= 18 {
                                ageInterval = "13-18"
                            }
                            if user.age > 18 && user.age <= 24 {
                                ageInterval = "19-24"
                            }
                            if user.age > 24 && user.age <= 30 {
                                ageInterval = "25-30"
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
                            age2["ignore this"] = self.maximumInterest
                            age2[ageInterval] = (age2[ageInterval] ?? 0) + 1
                            //EndOfSecond
                            
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
                    
                    print("key  \(key)  value  = \(data[key]!)   calculated = \(maleCount + femaleCount + unknownCount)")
//                    if maleCount + femaleCount + unknownCount == 0 { continue }

                    for index in 0..<arrayOfKeys.count {
                        print("\(arrayOfKeys[index]) \(age2[arrayOfKeys[index]] ?? 0)")
                    }
                    wholeGraph2Data.append(age2)
                    entyties.insert((BarChartDataEntry(values: [femaleCount,maleCount, unknownCount], xIndex: index)), atIndex: 0)
                    arrayOfAgesLabels.append(self.translateWorld(key) + " (\(data[key]!))")
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
            
                //Second graph drawing
             var secondDataSet = Array<BubbleChartDataSet>()

            for mainIndex2 in 0..<top5Keys.reverse().count {
                print(top5Keys.reverse()[mainIndex2])
                print(wholeGraph2Data[mainIndex2].keys)
                index = 0
                var yVals = Array<BubbleChartDataEntry>()
                for keyDict in arrayOfKeys {
                    print("key = \(keyDict)")
                    for dataKey in wholeGraph2Data[mainIndex2].keys where dataKey == keyDict {
                        print("value : \(wholeGraph2Data[mainIndex2][dataKey]!) index \(index)")
                        yVals.append(BubbleChartDataEntry(xIndex: index, value: Double((mainIndex2 ) + 1), size: CGFloat(wholeGraph2Data[mainIndex2][dataKey]!)))
                    }
                    index += 1
                }
                let dataset22 = BubbleChartDataSet(yVals: yVals, label: ("\(mainIndex2+1)." + self.translateWorld(top5Keys.reverse()[mainIndex2])))
                let colors22 = ChartColorTemplates.colorful() + ChartColorTemplates.joyful() + ChartColorTemplates.colorful()
                dataset22.setColor(colors22[mainIndex2], alpha: 0.7)
                dataset22.drawValuesEnabled = true
                secondDataSet.append(dataset22)
            }
            
            var labeledKeys = Array<String>()
            for key in arrayOfKeys {
                labeledKeys.append(key  + (key != "ignore this" ? " y.o.":""))
            }
            let data2 = BubbleChartData(xVals: labeledKeys, dataSets: secondDataSet)
            data2.setValueTextColor(UIColor.whiteColor())
            data2.setValueFormatter(pFormatter)
            self.mainStatBubleChart.data = data2
            self.mainStatBubleChart.animate(xAxisDuration: 2)
                });
        });
    }
    
    @IBAction func segmenterPressed(sender: AnyObject) {
        
    }
}
