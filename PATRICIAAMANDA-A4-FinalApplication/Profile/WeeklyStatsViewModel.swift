//
//  WeeklyStatsViewModel.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 5/7/21.
//

import Foundation
import UIKit

class WeeklyStatsViewModel {
    var dataPoints = [Double]()
    var barColor = UIColor.systemBlue
    
    var maxY : Double {
        return dataPoints.sorted(by: >).first ?? 0
    }
    
    var barGapPctOfTotal : CGFloat {
        return CGFloat(0.2) / CGFloat(dataPoints.count - 1)
    }
    
    var barWidthPctOfTotal : CGFloat {
        return CGFloat(0.8) / CGFloat(dataPoints.count)
    }
    
    var barCornerRadius : CGFloat {
        return CGFloat(50 / dataPoints.count)
    }
}
