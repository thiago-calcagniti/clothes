//
//  MyEvents.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 06/02/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
//

import UIKit
import EventKit

class MyEvents: UIViewController {


    var savedEventId : String = ""
    
    override func viewDidLoad() {
        let screenHeigth = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        let background = UIImageView()
        background.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeigth)
        background.image = UIImage(named: "looksBackground.png")
        background.contentMode = .scaleAspectFill
        self.view.addSubview(background)
        
        self.edgesForExtendedLayout = UIRectEdge()
        
        createMenuButton()
        
        
        
        
        let eventStore2 = EKEventStore()
        let newCalendar = EKCalendar(for: .event, eventStore: eventStore2)
        newCalendar.title = "Clothes"
        
    
        // Save the calendar using the Event Store instance
        var error: NSError? = nil
        do {
            var calendarWasSaved = try eventStore2.saveCalendar(newCalendar, commit: true)
        } catch {
            let alert = UIAlertController(title: "Calendar could not save", message: "error", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
        }

        
        
        
        
        
        
        
        
        
        
        let calendars = eventStore2.calendars(for: EKEntityType.event)
        
        for calendar in calendars as [EKCalendar] {
            print("Calendar = \(calendar.title)")
        }
        
        
        let addEventButton = UIButton()
        addEventButton.frame = CGRect(x: 30, y: 50, width: 100, height: 50)
        addEventButton.setTitle("Add Event", for: UIControlState())
        addEventButton.addTarget(self, action: #selector(MyEvents.addEvent), for: UIControlEvents.touchUpInside)
        self.view.addSubview(addEventButton)
        
        let addRemoveButton = UIButton()
        addRemoveButton.frame = CGRect(x: 30, y: 200, width: 100, height: 50)
        addRemoveButton.setTitle("Remove Event", for: UIControlState())
        addRemoveButton.addTarget(self, action: #selector(MyEvents.removeEvent), for: UIControlEvents.touchUpInside)
        self.view.addSubview(addRemoveButton)
      
//        UIApplication.sharedApplication().openURL(NSURL(string: "calshow://")!)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Meus Eventos"
    }

    
    
    // MARK: Event Functions
    func addEvent() {
        print("Event Added")
        let eventStore = EKEventStore()
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(60*60)
        
        if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
            eventStore.requestAccess(to: .event, completion: { (granted, error) -> Void in
                self.createEvent(eventStore, title: "Thiago Test", startDate: startDate, endDate: endDate)
            })
        } else {
            createEvent(eventStore, title: "Thiago Test", startDate: startDate, endDate: endDate)
        }
    }
    func removeEvent() {
        print("Event Removed")
        let eventStore = EKEventStore()
        
        if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
            eventStore.requestAccess(to: .event, completion: { (granted, error) -> Void in
                self.deleteEvent(eventStore, eventIdentifier: self.savedEventId)
            })
        } else {
            deleteEvent(eventStore, eventIdentifier: savedEventId)
        }
        
        
    }
    
    
    func createEvent(_ eventStore: EKEventStore, title: String, startDate: Date, endDate: Date) {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents
        do {
            try eventStore.save(event, span: EKSpan.thisEvent)
            savedEventId = event.eventIdentifier
        } catch {
            print("Error")
        }
    }
    func deleteEvent(_ eventStore: EKEventStore, eventIdentifier: String) {
        let eventToRemove = eventStore.event(withIdentifier: eventIdentifier)
        if (eventToRemove != nil){
            do {
                try eventStore.remove(eventToRemove!, span: .thisEvent)
            } catch {
                print("Event couldnt be removed")
            }
        }
    }
    
    
    
    
    
    // MARK: Setup Navigation Items
    func createMenuButton() {
        if let myNavigationItem:UINavigationItem = self.navigationItem {
            let menuButton = UIBarButtonItem(image: UIImage(named: "menuShow.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(MyEvents.menuShow))
            myNavigationItem.leftBarButtonItem = menuButton
        }
    }
    func menuShow() {
        Window().showMenu()
    }

}
