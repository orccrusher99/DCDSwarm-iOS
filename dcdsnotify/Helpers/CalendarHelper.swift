//
//  CalendarHelper.swift
//  dcdsnotify
//
//  Created by Peter J. Lee on 8/25/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import Foundation

class CalendarHelper {
	static func processCalendarString(htmlString: NSString) -> Day
		//TODO: add param for diff calendar lengths
	{
		//MARK: set date
		let emptyStart = "<li class=\"listempty\">"
		let emptyEnd = "</li>"
		
		let dayStart = "thisDate: {ts '"
		let dayEnd = "'} start:"
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let date = dateFormatter.dateFromString( htmlString.cropExclusive(dayStart, end: dayEnd) ?? "") ?? NSDate()

		//MARK: check for empty day
		guard (htmlString.crop(emptyStart, end: emptyEnd)) == nil else{
						//TODO: remove hotfix
			let emptyDay = Day.emptyDay(date)
			return emptyDay
		}
		
		/*
		NOTE: caldata divides months
		nothing divides weeks
		every day divided by class="listcap"
		every class divided by eventobj
		
		
		<ul class="eventobj calendar3160" id="event_521366_591468">
		^
		this number
		applies to end of this link:
		https://www.dcds.edu/page.cfm?p=
		to get group page
		*/
		
		
		//MARK: Day divider
		
		let dayStartString = "<span class=\"listcap"
		let dayEndString = "</div>"//TODO: will not work on week or greater periods
        var tempDayString: String? = htmlString.cropExclusive(dayStartString, end: dayEndString)?.cropExclusive(">")
        guard tempDayString != nil else {
            return Day.emptyDay(date)
        }
        var dayString: String? = tempDayString
		let tempDay = Day(date: date)
		tempDay.activities = []
		
		
		
		//MARK: Activity Divider
		let activityStartString = "<ul class=\"eventobj calendar"
		let activityEndString = "<!-- end eventobj -->"
		
		
		var currentActivity = dayString!.cropExclusive(activityStartString, end: activityEndString)//Gets single activity
		let classID = dayString!.cropEndExclusive("\\")//for calendar id of class
		let activityID = dayString!.cropExclusive("\"event_", end: "\\\"")//gets activity ID
		//TODO: use activity and class ID
		dayString = dayString!.cropExclusive(activityStartString)//removes currActivity by finding next one
		
		
		while let okActivity = currentActivity {
			
			
            var activityTitle: String! = "Title not found"
			var activityClass: String? = nil
			var activityDesc = ""
			
			//MARK: parsing Title
			
            if let activityString =  okActivity.crop("etitle") {
			if okActivity.hasPrefix("3659") {
				activityTitle =  activityString.cropExclusive("\">", end: "/span")
				
				var tempClassString = activityTitle
				
				activityTitle =  activityTitle.cropEndExclusive("(")
				if activityTitle.containsString("<br") {
					tempClassString =  tempClassString.cropExclusive("<br")!.cropExclusive("(")!
					activityTitle =  activityTitle.cropEndExclusive("<")
					
				}
				
				activityClass =  tempClassString.cropExclusive("(", end: ")<") ?? "Failed to find class"
				
			}
				
				//			else if okActivity.hasPrefix("4790") {
				//				activityTitle =  activityString.cropExclusive("</span>")
				//				activityClass =  activityTitle.cropEnd(":")
				//				activityTitle =  activityTitle.cropExclusive(": ")
				//			}
			else if (okActivity.hasPrefix("3500")) {
				activityTitle =  activityString.cropExclusive("title=")?.cropExclusive(">", end: "</span") ?? "No title: code 3500"
                activityClass =  activityTitle.cropEnd(":") ?? "No class: code 3500"
				activityTitle =  activityTitle.cropExclusive(": ") ?? "No title: code 3500"
			}
			else {
				//linked
				if okActivity.containsString("title=\"Click here for event details\">") {
					activityTitle =  activityString.cropExclusive("title=\"Click here for event details\">", end: "</span>")//removes beginning crap in activity
					
					//separates class name from activity title
                    if let tempClass =  activityTitle.cropEnd("):") {
                        activityClass = tempClass
                        activityClass!.removeAtIndex(tempClass.endIndex.predecessor())
                    }
                    else {
                        //Activity not found
                    }
                    
                    if let tempTitle = activityTitle.cropExclusive("): ", end: "</") {
                        activityTitle = tempTitle
                    }
                    if activityTitle.containsString("<br") {
                        activityTitle =  activityTitle.cropEndExclusive("<br")
                    }
//                    activityTitle =  activityTitle.cropExclusive("): ", end: "</")
//                    
//                    if activityTitle.containsString("<br") {
//                        activityTitle =  activityTitle.cropEndExclusive("<br")
//                    }
				}
					
					//not linked
				else if okActivity.containsString("<span class=\"eventcon\">")//find event content
				{
                    if let tempActivity =  okActivity.cropExclusive("id=\"e_") {
					let activityID =  tempActivity.cropEndExclusive("\">")
					//TODO: organize activities by class and use id
					activityClass =  (tempActivity.cropExclusive("\">", end: "): ")! + ")" ?? "Failed Activity")
					activityTitle =  (tempActivity.cropExclusive("): ", end: "</span>") ?? "Failed Title")
					
					
					if activityTitle.containsString("<br") {
						activityTitle =  activityTitle.cropEndExclusive("<br")
					}
                    }
                    else {
                        activityTitle = "Failed title: code eventcon"
                    }
					
				}
				else {
					activityClass = "Could not find activity"
				}
				
			}
			
			//MARK: parsing Desc
			var activityDescData =  activityString.cropExclusive("</span>")!
			while(activityDescData.containsString("<span")) {
				activityDescData =  activityDescData.cropExclusive("<span")!
				activityDescData =  activityDescData.cropExclusive(">", end: "</span")!
				
				if activityDescData.containsString("<") && activityDescData.containsString(">"){//if carats found
					//find carats and make range
					let startIndex = activityDescData.rangeOfString("<")!.startIndex
					let endIndex = activityDescData.rangeOfString(">")!.endIndex
					let asdf = startIndex..<endIndex
					//assert break in carats
					guard activityDescData.substringWithRange(asdf).containsString("br") || activityDescData.substringWithRange(asdf).containsString("BR") else {
						print("carats found, but no break")
						break
					}
					//bye carats
					activityDescData.removeRange(asdf)
					//replace with newline
					//					activityDescData.insertContentsOf("\n".characters, at: startIndex)
				}
				activityDesc += (activityDescData) + "\n"
			}
            
			tempDay.activities!.append(Activity(classString: activityClass ?? "No Title Found", title: activityTitle ?? "Title not found", subtitle: activityDesc))
			
			//while loop logic
			//gets the next activity
			currentActivity = (dayString!.cropExclusive(activityStartString, end: activityEndString))
			dayString = dayString!.cropExclusive(activityStartString)
            }
			
		}
		
		return tempDay
	}
}

