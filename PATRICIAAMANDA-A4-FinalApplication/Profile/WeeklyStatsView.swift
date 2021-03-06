//
//  WeeklyStatsView.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 5/7/21.
//

import UIKit
//Bar chart tutorial: https://www.robkerr.com/creating-ios-bar-chart-code-swift/
class WeeklyStatsView: UIView {

    var barClickDelegate : BarClickDelegate?
      var viewModel = WeeklyStatsViewModel()
      var tapRecognizer:UITapGestureRecognizer!
      
      required init?(coder: NSCoder) {
          super.init(coder: coder)
          tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleBarTap))
          addGestureRecognizer(tapRecognizer)
      }
      
      deinit {
          removeGestureRecognizer(tapRecognizer)
      }
      
      func setData(_ dataPoints: [Double]) {
          backgroundColor = UIColor.clear
          
          viewModel.dataPoints = dataPoints
          clearViews()
          
          // Do not continue if no bar has height > 0
          guard viewModel.maxY > 0.0 else { return } // max bar must be > 0
          createChart()
      }
      
      func clearViews() {
          for view in subviews {
              view.removeFromSuperview()
          }
      }
      
      func createChart() {
          var lastBar:UIView?
          
          for (i, dataPoint) in viewModel.dataPoints.enumerated() {
              let barView = createBarView(barNumber: i, barValue: dataPoint)
              
              if let lastBar = lastBar {
                  let gapView = createGapView(lastBar: lastBar)
                  barView.leftAnchor.constraint(equalTo: gapView.rightAnchor).isActive = true
              } else {
                  barView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
              }
              
              if i == viewModel.dataPoints.count - 1 {
                  barView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
              }
              
              // All bars pinned to bottom of containing view
              barView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
              
              // calculate height of bar relative to maxY
              barView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: CGFloat(dataPoint / viewModel.maxY)).isActive = true
              
              lastBar = barView
          }
      }
      
      func createBarView(barNumber: Int, barValue: Double) -> UIView {
          let barView = UIView()
          addSubview(barView)
          barView.translatesAutoresizingMaskIntoConstraints = false
          barView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: viewModel.barWidthPctOfTotal).isActive = true
          
          barView.tag = barNumber + 1000  // give each bar a known tag to use in finding the view later
          
       
        barView.backgroundColor = viewModel.barColor
            
        
          barView.layer.cornerRadius = viewModel.barCornerRadius

          return barView
      }
      
      func createGapView(lastBar: UIView) -> UIView {
          let gapView = UIView()
          addSubview(gapView)
          gapView.translatesAutoresizingMaskIntoConstraints = false
          gapView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
          gapView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
          gapView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: viewModel.barGapPctOfTotal).isActive = true
          gapView.leftAnchor.constraint(equalTo: lastBar.rightAnchor).isActive = true
          return gapView
      }
    
      @objc func handleBarTap() {
          if let hitView = tapRecognizer.view {
              let loc = tapRecognizer.location(in: self)
              if let barViewTapped = hitView.hitTest(loc, with: nil) {
                  for barView in subviews where barView.tag >= 1000 {
                   if(barView.tag == barViewTapped.tag) {
                    barView.backgroundColor = barView.backgroundColor?.withAlphaComponent(0.4)
                    if let barClickDelegate = barClickDelegate {
                        barClickDelegate.barClicked(tag: tag)
                        }
                   }
              }
          }
      }

    }
    
}
