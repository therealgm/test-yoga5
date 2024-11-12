import Foundation

struct LifeExpectancyModel {
    let completedPoses: Int
    
    // Computed property to get the life expectancy increase message
    var lifeExpectancyMessage: String {
        let daysAdded = completedPoses / 4          // Each 4 poses add 1 day
        let halfDaysAdded = (completedPoses % 4) / 2 // Each 2 poses add 0.5 day

        // Determine message based on days and half-days added
        if daysAdded > 0 || halfDaysAdded > 0 {
            var message = "You've added "
            if daysAdded > 0 {
                message += "\(daysAdded) day" + (daysAdded > 1 ? "s" : "")
            }
            if halfDaysAdded > 0 {
                if daysAdded > 0 { message += " + " }
                message += "half a day"
            }
            return message + "!"
        } else {
            return "Keep going to add to your life expectancy!"
        }
    }

    // Computed property to show extended life expectancy
    var extendedLifeMessage: String {
        let yearsAdded = daysAdded / 365
        let remainingDays = Double(daysAdded % 365) + (halfDaysAdded == 1 ? 0.5 : 0.0)
        return "You are now \(yearsAdded) years + \(remainingDays) days!"
    }
    
    // Private computed properties for calculations
    private var daysAdded: Int {
        completedPoses / 4
    }
    private var halfDaysAdded: Int {
        (completedPoses % 4) / 2
    }
}
