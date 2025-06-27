import Foundation
import CoreData
import SwiftUI

extension UserSettings {
    
    static func fetchOrCreate(in context: NSManagedObjectContext) -> UserSettings {
        let request: NSFetchRequest<UserSettings> = UserSettings.fetchRequest()
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            if let existingSettings = results.first {
                print("DEBUG: Found existing UserSettings with background: \(existingSettings.selectedBackground ?? "nil")")
                return existingSettings
            } else {
                print("DEBUG: Creating new UserSettings")
                let newSettings = UserSettings(context: context)
                newSettings.enableHaptics = true
                newSettings.enableSounds = true
                newSettings.showExtendedScoreIndicator = true
                newSettings.autoSaveGames = true
                newSettings.keepScreenOn = false
                newSettings.selectedBackground = BackgroundStyle.classic.rawValue
                
                // Save immediately to ensure the object is properly persisted
                try context.save()
                print("DEBUG: Saved new UserSettings with background: \(newSettings.selectedBackground ?? "nil")")
                
                return newSettings
            }
        } catch {
            print("ERROR: Failed to fetch or create user settings: \(error)")
            // Return a new unsaved instance as fallback
            let newSettings = UserSettings(context: context)
            newSettings.enableHaptics = true
            newSettings.enableSounds = true
            newSettings.showExtendedScoreIndicator = true
            newSettings.autoSaveGames = true
            newSettings.keepScreenOn = false
            newSettings.selectedBackground = BackgroundStyle.classic.rawValue
            return newSettings
        }
    }
    
    func save() {
        guard let context = managedObjectContext else { return }
        
        do {
            try context.save()
        } catch {
            print("Failed to save user settings: \(error)")
        }
    }
}