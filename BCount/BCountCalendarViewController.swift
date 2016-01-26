//
//  CalendarViewController.swift
//  BCount
//
//  Created by Vikas Varma on 1/20/16.
//  Copyright © 2016 Vikas Varma. All rights reserved.
//

import Foundation
import UIKit
import CVCalendar
import CoreData

class BCountCalendarViewController:UIViewController,NSFetchedResultsControllerDelegate{
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var userInfo:UserInfo!
    var selectedDate = NSDate()
    @IBOutlet weak var viewCountButton: UIButton!
    
    @IBOutlet weak var menuView: CVCalendarMenuView!
    
    @IBOutlet weak var calendarView: CVCalendarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set the current Month
        self.navigationItem.title = CVDate(date: NSDate()).globalDescription
        userInfo = BCClient.sharedInstance.userInfo
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
    }
    
    override func viewDidAppear(animated: Bool) {
       
        
        
        fetchBcountData()
        
        calendarView.contentController.refreshPresentedMonth()
        
    }
    func fetchBcountData(){
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        activityIndicator.startAnimating()
        
        
        if userInfo.counts.isEmpty {
            
            BCClient.sharedInstance.getBCountList(){ result, errorString in
                if let error = errorString  {
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        BCClient.alertDialog(self, errorTitle: "Error retrieving blood counts from server", action: "Ok",errorMsg: "\(error)")
                    })
                    self.enableDisableComponents(true)
                    
                }
                else {
                    self.populateBCounts(result as? [[String: AnyObject]])
                }
                
            }
            
        }else{
            
            enableDisableComponents(false)
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
        
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
    
    @IBAction func todayMonthView() {
        calendarView.toggleCurrentDayView()
    }
    
    @IBAction func loadPrevious(sender: AnyObject) {
        calendarView.loadPreviousView()
    }
    
    
    @IBAction func loadNext(sender: AnyObject) {
        calendarView.loadNextView()
    }
    
    private func populateBCounts(counts: [[String: AnyObject]]!)-> Void{
        
        if let countList = counts {
            
            if(countList.isEmpty){
                
                self.enableDisableComponents(true)
            }else{
                self.sharedContext.performBlockAndWait(
                    {
                        for bcountObj in countList{
                            
                            let bcount = BCount(dictionary: bcountObj, context: self.sharedContext)
                            bcount.userInfo = self.userInfo
                        }
                        CoreDataStackManager.sharedInstance().saveContext()
                        
                    }
                )
                
                self.enableDisableComponents(false)
            }
        }
    }
    
    
    //Enable disable the components based on the errorFlag
    func enableDisableComponents(errorFlag:Bool){
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.activityIndicator.stopAnimating()
        })
        
        
    }
    @IBAction func viewCountButtonPressed(sender: UIButton) {
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let controller =
            self.storyboard!.instantiateViewControllerWithIdentifier("BCountDisplayTableByDateController") as! BCountDisplayTableByDateController
            controller.selectedDate = self.selectedDate
            
            self.navigationController!.pushViewController(controller, animated: true)
        })
        
    }
}
extension BCountCalendarViewController :CVCalendarViewDelegate, CVCalendarMenuViewDelegate,CVCalendarViewAppearanceDelegate{
    func firstWeekday() -> Weekday {
        return .Sunday
    }
    
    func presentationMode() -> CalendarMode {
        return CalendarMode.MonthView
    }
    func shouldShowWeekdaysOut() -> Bool {
        return false
    }
    
    func shouldAnimateResizing() -> Bool {
        return true // Default value is true
    }
    
    func didSelectDayView(dayView: CVCalendarDayView, animationDidFinish: Bool) {
        
        viewCountButton.enabled = true
        
        selectedDate = dayView.date.convertedDate()!
    }
    
    func presentedDateUpdated(date: CVDate) {
        if self.navigationItem.title != date.globalDescription  {
            
            self.navigationItem.title = date.globalDescription
        }
    }
    
    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }
    
    func weekdaySymbolType() -> WeekdaySymbolType {
        return .Short
    }
    
    func selectionViewPath() -> ((CGRect) -> (UIBezierPath)) {
        return { UIBezierPath(rect: CGRectMake(0, 0, $0.width, $0.height)) }
    }
    
    func shouldShowCustomSingleSelection() -> Bool {
        return false
    }
    
    func preliminaryView(viewOnDayView dayView: DayView) -> UIView {
        
        let circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.Circle)
        circleView.fillColor = .colorFromCode(0xCCCCCC)
        return circleView
    }
    
    func preliminaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        if (dayView.isCurrentDay) {
            return true
        }
        return false
    }
    
    func supplementaryView(viewOnDayView dayView: DayView) -> UIView {
        
        return  customizeSelectedView(dayView)
    }
    
    func supplementaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        if let date = dayView.date{
            for bcount in  (fetchedResultsController.fetchedObjects as? [BCount])!{
                
                let cvitem = CVDate(date: bcount.createdDate!)
                
                if isSameDay(cvitem,date2: date){
                    return true;
                }
            }
        }
        return false
    }
    
    func isSameDay(date1: CVDate, date2:CVDate)->Bool{
        
        return date1.day == date2.day && date1.month==date2.month && date1.year == date2.year
    }
    
    func dayLabelPresentWeekdayInitallyBold() -> Bool {
        return false
    }
    
    //Customizing suplementaryView
    func customizeSelectedView( dayView :DayView)-> UIView{
        
        let π = M_PI
        
        let ringSpacing: CGFloat = 3.0
        let ringInsetWidth: CGFloat = 1.0
        let ringVerticalOffset: CGFloat = 1.0
        var ringLayer: CAShapeLayer!
        let ringLineWidth: CGFloat = 4.0
        let ringLineColour: UIColor = .blueColor()
        
        let newView = UIView(frame: dayView.bounds)
        
        let diameter: CGFloat = (newView.bounds.width) - ringSpacing
        let radius: CGFloat = diameter / 2.0
        
        let rect = CGRectMake(newView.frame.midX-radius, newView.frame.midY-radius-ringVerticalOffset, diameter, diameter)
        
        ringLayer = CAShapeLayer()
        newView.layer.addSublayer(ringLayer)
        
        ringLayer.fillColor = nil
        ringLayer.lineWidth = ringLineWidth
        ringLayer.strokeColor = ringLineColour.CGColor
        
        let ringLineWidthInset: CGFloat = CGFloat(ringLineWidth/2.0) + ringInsetWidth
        let ringRect: CGRect = CGRectInset(rect, ringLineWidthInset, ringLineWidthInset)
        let centrePoint: CGPoint = CGPointMake(ringRect.midX, ringRect.midY)
        let startAngle: CGFloat = CGFloat(-π/2.0)
        let endAngle: CGFloat = CGFloat(π * 2.0) + startAngle
        let ringPath: UIBezierPath = UIBezierPath(arcCenter: centrePoint, radius: ringRect.width/2.0, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        ringLayer.path = ringPath.CGPath
        ringLayer.frame = newView.layer.bounds
        
        return newView
    }
}
