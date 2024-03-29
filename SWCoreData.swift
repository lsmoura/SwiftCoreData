// Swift CoreData Object Implementation
// ====================================
//
// Kindly borrowed and adapted from Cocoa Is My Girlfriend on 2014-07-24.
// URL: http://www.cimgf.com/2014/06/08/the-core-data-stack-in-swift/

import UIKit
import CoreData

let DEBUG = true

func ZAssert(test: Bool, message: String) {
    if (test) {
        return
    }
    
    println(message)
    
    if (!DEBUG) {
        return
    }
    
    var exception = NSException()
    exception.raise()
}

class SWCoreData: NSObject {
    var identifier: String = "SwiftTestOne"
    
    var _managedObjectContext: NSManagedObjectContext? = nil;
	var managedObjectContext: NSManagedObjectContext {
        if (_managedObjectContext != nil) {
            return(_managedObjectContext!);
        }
    
		let modelURL = NSBundle.mainBundle().URLForResource(identifier, withExtension: "momd")
		let mom = NSManagedObjectModel(contentsOfURL: modelURL)
		ZAssert(mom != nil, "Error initializing mom from: \(modelURL)")

		let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)

		let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let storeURL = (urls[urls.endIndex-1]).URLByAppendingPathComponent(NSString(format:"%@.sqlite", identifier))

		var error: NSError? = nil

		var store = psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: &error)
		if (store == nil) {
			println("Failed to load store")
		}
		ZAssert(store != nil, "Unresolved error \(error?.localizedDescription), \(error?.userInfo)\nAttempted to create store at \(storeURL)")

		_managedObjectContext = NSManagedObjectContext()
		_managedObjectContext!.persistentStoreCoordinator = psc

        return(_managedObjectContext!);
	}
    
    func saveContext () {
        var error: NSError? = nil
        let moc = self.managedObjectContext
        if moc == nil {
            return
        }
        if !managedObjectContext.hasChanges {
            return
        }
        if managedObjectContext.save(&error) {
            return
        }
        
        println("Error saving context: \(error?.localizedDescription)\n\(error?.userInfo)")
        abort()
    }
}
