//
//  ChartViewController.swift
//  BCount
//
//  Created by Vikas Varma on 1/14/16.
//  Copyright © 2016 Vikas Varma. All rights reserved.
//

import UIKit
import SwiftCharts
import CoreData

class BCountChartViewController: UIViewController,NSFetchedResultsControllerDelegate {
    
    private var chart: Chart? // arc
    var userInfo:UserInfo!
    
    //@IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var chartTypeTextField: UITextField!
    
    var countTypeData: [String] = [String]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        userInfo = BCClient.sharedInstance.userInfo
        
        
        countTypeData = ["ANC", "HGB", "RBC","WBC","PLATELET"]
        
        chartTypeTextField.text = countTypeData[0]
        
        chartTypeTextField.inputAccessoryView = chartTypeToolBar
    }
    
    override func viewDidAppear(animated: Bool) {
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        populateChart(chartTypeTextField.text!)
    }
    
    func populateChart(type:String){
        
        let labelSettings = ChartLabelSettings(font: ChartDefaults.labelFont)
        
        let (xAxisValues, yAxisValues, chartPoints, displayType) = generateChartValues(type,labelSettings: labelSettings)
        
        //In case of typing an error text default to Platelet
        chartTypeTextField.text = displayType
        
        let xModel = ChartAxisModel(axisValues: xAxisValues, axisTitleLabel: ChartAxisLabel(text: "Date", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yAxisValues, axisTitleLabel: ChartAxisLabel(text: displayType, settings: labelSettings.defaultVertical()))
        let scrollViewFrame = ChartDefaults.chartFrame(self.chartView.bounds)
        
        let chartFrame = CGRectMake(0, 0, 1500, scrollViewFrame.size.height + 10)
        let chartSettings = ChartDefaults.chartSettings
        chartSettings.trailing = 40
        chartSettings.top = 40
        chartSettings.bottom = 20
        chartSettings.leading=20
        chartSettings.labelsToAxisSpacingX = 20
        chartSettings.labelsToAxisSpacingY = 20
        
        let lineModel = ChartLineModel(chartPoints: chartPoints, lineColor: UIColor.redColor(), animDuration: 1, animDelay: 0)
        
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        
        let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)
        
        let trendLineLayer = ChartPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [lineModel])
        
        let chartPointsLineLayer = ChartPointsLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints)
        
        let settings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.blackColor(), linesWidth: ChartDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: settings)
        
        let dividersSettings =  ChartDividersLayerSettings(linesColor: UIColor.blackColor(), linesWidth: ChartDefaults.guidelinesWidth, start: Env.iPad ? 7 : 3, end: 0, onlyVisibleValues: true)
        let dividersLayer = ChartDividersLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: dividersSettings)
        let chart = Chart(
            frame: chartFrame,
            layers: [
                xAxis,
                yAxis,
                guidelinesLayer,
                chartPointsLineLayer,
                trendLineLayer,
                dividersLayer
            ]
        )
        
        // calculate coords space in the background to keep UI smooth
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            
            dispatch_async(dispatch_get_main_queue()) {
                self.chartView.removeAllSubviews()
                let scrollView = UIScrollView(frame: scrollViewFrame)
                scrollView.contentSize = CGSizeMake(chartFrame.size.width, scrollViewFrame.size.height)
                //self.automaticallyAdjustsScrollViewInsets = false // nested view controller - this is in parent
                scrollView.addSubview(chart.view)
                
                self.chartView.addSubview(scrollView)
                self.chart = chart
                
            }
        }
    }
    
    func generateChartValues(type: String,labelSettings: ChartLabelSettings) ->([ChartAxisValue],[ChartAxisValue],[ChartPoint],String){
        
        let displayFormatter = NSDateFormatter()
        displayFormatter.dateFormat = "MMM dd"
        
        switch(type){
        case "ANC":
            let xAxisValues = generateXAxisValues(displayFormatter, labelSettings: labelSettings)
            
            let yAxisValues = 0.stride(through: 12, by: 0.5).map {ChartAxisValueDouble(Double($0), labelSettings: labelSettings)}
            
            var chartPoints = [ChartPoint]()
            
            for bcount in (fetchedResultsController.fetchedObjects as? [BCount])!{
                chartPoints.append(createChartPoint(bcount.createdDate!, y: bcount.anc!.doubleValue,formatter: displayFormatter, labelSettings: labelSettings))
            }
            return (xAxisValues,yAxisValues,chartPoints,type)
        case "HGB":
            
            let xAxisValues = generateXAxisValues(displayFormatter, labelSettings: labelSettings)
            
            let yAxisValues = 0.stride(through: 20, by: 0.5).map {ChartAxisValueDouble(Double($0), labelSettings: labelSettings)}
            
            var chartPoints = [ChartPoint]()
            
            for bcount in (fetchedResultsController.fetchedObjects as? [BCount])!{
                chartPoints.append(createChartPoint(bcount.createdDate!, y: bcount.hgb!.doubleValue,formatter: displayFormatter, labelSettings: labelSettings))
            }
            return (xAxisValues,yAxisValues,chartPoints,type)
        case "RBC":
            
            let xAxisValues = generateXAxisValues(displayFormatter, labelSettings: labelSettings)
            
            let yAxisValues = 0.stride(through: 8, by: 0.2).map {ChartAxisValueDouble(Double($0), labelSettings: labelSettings)}
            
            var chartPoints = [ChartPoint]()
            
            for bcount in (fetchedResultsController.fetchedObjects as? [BCount])!{
                chartPoints.append(createChartPoint(bcount.createdDate!, y: bcount.rbc!.doubleValue,formatter: displayFormatter, labelSettings: labelSettings))
            }
            return (xAxisValues,yAxisValues,chartPoints,type)
        case "WBC":
            
            let xAxisValues = generateXAxisValues(displayFormatter, labelSettings: labelSettings)
            
            let yAxisValues = 0.stride(through: 20, by: 0.5).map {ChartAxisValueDouble(Double($0), labelSettings: labelSettings)}
            
            var chartPoints = [ChartPoint]()
            
            for bcount in (fetchedResultsController.fetchedObjects as? [BCount])!{
                chartPoints.append(createChartPoint(bcount.createdDate!, y: bcount.wbc!.doubleValue,formatter: displayFormatter, labelSettings: labelSettings))
            }
            return (xAxisValues,yAxisValues,chartPoints,type)

        default:
            
            let xAxisValues = generateXAxisValues(displayFormatter, labelSettings: labelSettings)
            
            let yAxisValues = 0.stride(through: 550, by: 10).map {ChartAxisValueDouble(Double($0), labelSettings: labelSettings)}
            
            var chartPoints = [ChartPoint]()
            
            for bcount in (fetchedResultsController.fetchedObjects as? [BCount])!{
                chartPoints.append(createChartPoint(bcount.createdDate!, y: bcount.platelet!.doubleValue,formatter: displayFormatter, labelSettings: labelSettings))
            }
            return (xAxisValues,yAxisValues,chartPoints,"PLATELET")
        }
        
    }
    func generateXAxisValues(formatter:NSDateFormatter,  labelSettings: ChartLabelSettings) -> [ChartAxisValueDate] {
        
        var xaxisList = [ChartAxisValueDate]()
        let countList = fetchedResultsController.fetchedObjects as? [BCount]
        let startBc = countList![0]
        let endBc = countList![(countList?.count)!-1]
        let startDate = startBc.createdDate
        let endDate = addDaystoGivenDate(endBc.createdDate!, numOfDays: 1)
        var day = -1
        var stop = true
        while stop {
            let date = addDaystoGivenDate(startDate!, numOfDays: day)
            
            xaxisList.append(ChartAxisValueDate(date: date,formatter:formatter, labelSettings: labelSettings))
            day = day + 1
            if date.compare(endDate) == NSComparisonResult.OrderedDescending {
                stop = false
            }
            
        }
        return xaxisList
    }
    
    
    func addDaystoGivenDate(baseDate:NSDate,numOfDays:Int)->NSDate
    {
        let dateComponents = NSDateComponents()
        let CurrentCalendar = NSCalendar.currentCalendar()
        let CalendarOption = NSCalendarOptions()
        
        dateComponents.day = numOfDays
        
        let newDate = CurrentCalendar.dateByAddingComponents(dateComponents, toDate: baseDate, options: CalendarOption)
        return newDate!
    }
    
    private func createChartPoint(x: NSDate, y: Double,formatter:NSDateFormatter,  labelSettings: ChartLabelSettings) -> ChartPoint {
        return ChartPoint(x: ChartAxisValueDate(date:x, formatter: formatter, labelSettings: labelSettings), y: ChartAxisValueDouble(y))
        
    }
    
    // MARK: - Core Data Convenience
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    // Mark: - Fetched Results Controller
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "BCount")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "userInfo == %@", self.userInfo);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
        
    }()
    
}
extension BCountChartViewController:UIPickerViewDataSource, UIPickerViewDelegate{
    
    //Picker Delegate Method
    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countTypeData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countTypeData[row]
    }
    
    // Catpure the picker view selection
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        
        chartTypeTextField.text = countTypeData[row]
    }
}

extension BCountChartViewController{
    
    var chartTypeToolBar: UIToolbar{
        
        let pickerView = UIPickerView()
        
        pickerView.delegate = self
        
        chartTypeTextField.inputView = pickerView
        
        let toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.size.width, 40.0))
        
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        
        toolBar.barStyle = UIBarStyle.BlackTranslucent
        
        toolBar.tintColor = UIColor.whiteColor()
        
        toolBar.backgroundColor = UIColor.blackColor()
        
        
        let defaultButton = UIBarButtonItem(title: "Default", style: UIBarButtonItemStyle.Plain, target: self, action: "tappedToolBarBtn:")
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "doneReasonPressed:")
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        
        label.font = UIFont(name: "Helvetica", size: 12)
        
        label.backgroundColor = UIColor.clearColor()
        
        label.textColor = UIColor.whiteColor()
        
        label.text = "Pick a Chart Type"
        
        label.textAlignment = NSTextAlignment.Center
        
        let textBtn = UIBarButtonItem(customView: label)
        
        toolBar.setItems([defaultButton,flexSpace,textBtn,flexSpace,doneButton], animated: true)
        return toolBar
    }
    
    func tappedToolBarBtn(sender: UIBarButtonItem) {
        
        chartTypeTextField.text = countTypeData[0]
        chartTypeTextField.resignFirstResponder()
    }
    
    func doneReasonPressed(sender: UIBarButtonItem) {
        
        chartTypeTextField.resignFirstResponder()
        
        populateChart(chartTypeTextField.text!)
    }
}
