//
//  SwitchViewDelegate.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 5/24/21.
//

import Foundation

//Protocol that handles the timer and the switching of the container views.
protocol SwitchViewDelegate : NSObject {
    func switchView(sender: Any?)->Bool
    func startTimer(sender: Any?)->Bool
    func stopTimer(sender: Any?)->Bool
    func pauseTimer(sender: Any?)
}
