//
//  ProfileChangeDelegate.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 5/5/21.
//

//Delegate to pass back profile changes.
protocol ProfileChangeDelegate : AnyObject {
    func saveProfileChanges(_ newUser: User) -> Bool
    func saveDailyStepsChanges(_ dailySteps: Int) -> Bool
}
