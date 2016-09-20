//
//  ErrorHandling.swift
//  dcdsnotify
//
//  Created by Clara Hwang on 8/25/16.
//  Copyright © 2016 orctech. All rights reserved.
//

import UIKit

struct ErrorHandling {
	
	static let ErrorTitle           = "Error"
	static let ErrorOKButtonTitle   = "Ok"
	static let ErrorDefaultMessage  = "Something unexpected happened, sorry for that!"
	
	static let DelayedFeatureTitle		= "Delayed Feature"
	static let DelayedFeatureMessage	= "Sorry, this feature is not yet available"
	
	/**
	This default error handler presents an Alert View on the topmost View Controller
	*/
	static func delayedFeatureAlert()
	{
		ErrorHandling.defaultErrorHandler(DelayedFeatureTitle, desc: DelayedFeatureMessage)
	}
	static func defaultErrorHandler(error: NSError) {
		ErrorHandling.defaultErrorHandler(ErrorTitle, desc: error.localizedDescription)
	}
	static func defaultErrorHandler(title: String, desc: String) {
		let alert = UIAlertController(title: title, message: desc, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: ErrorOKButtonTitle, style: UIAlertActionStyle.Default, handler: nil))
		
		let window = UIApplication.sharedApplication().windows[0]
		NSOperationQueue.mainQueue().addOperationWithBlock {
			window.rootViewController?.presentViewController(alert, animated: true, completion: nil)
		}
	}
}

	
