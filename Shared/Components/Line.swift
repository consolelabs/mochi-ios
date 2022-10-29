//
//  Line.swift
//  Mochi Wallet
//
//  Created by Oliver Le on 28/10/2022.
//

import SwiftUI

struct Line: View {
  var data: [(Double)]
  var color: Color
  @Binding var frame: CGRect
  
  let padding:CGFloat = 30
  
  var stepWidth: CGFloat {
    if data.count < 2 {
      return 0
    }
    return frame.size.width / CGFloat(data.count-1)
  }
  var stepHeight: CGFloat {
    var min: Double?
    var max: Double?
    let points = self.data
    if let minPoint = points.min(), let maxPoint = points.max(), minPoint != maxPoint {
      min = minPoint
      max = maxPoint
    }else {
      return 0
    }
    if let min = min, let max = max, min != max {
      if (min <= 0){
        return (frame.size.height-padding) / CGFloat(max - min)
      }else{
        return (frame.size.height-padding) / CGFloat(max + min)
      }
    }
    
    return 0
  }
  var path: Path {
    let points = self.data
    return Path.lineChart(points: points, step: CGPoint(x: stepWidth, y: stepHeight))
  }
  
  public var body: some View {
    
    ZStack {
      
      self.path
        .stroke(color, style: StrokeStyle(lineWidth: 1, lineJoin: .bevel))
        .rotationEffect(.degrees(180), anchor: .center)
        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        .drawingGroup()
    }
  }
}

extension Path {
  
  static func lineChart(points:[Double], step:CGPoint) -> Path {
    var path = Path()
    if (points.count < 2){
      return path
    }
    guard let offset = points.min() else { return path }
    let p1 = CGPoint(x: 0, y: CGFloat(points[0]-offset)*step.y)
    path.move(to: p1)
    for pointIndex in 1..<points.count {
      let p2 = CGPoint(x: step.x * CGFloat(pointIndex), y: step.y*CGFloat(points[pointIndex]-offset))
      path.addLine(to: p2)
    }
    return path
  }
}

struct SparklineView: View {
  private let data: [Double]
  private let maxY: Double
  private let minY: Double
  private let color: Color
  
  init(prices: [Double], color: Color) {
    self.data = prices
    self.maxY = prices.max() ?? 0
    self.minY = prices.min() ?? 0
    self.color = color
  }
  
  var body: some View {
    GeometryReader { reader in
      Path { path in
        for index in data.indices {
          let xPosition = reader.size.width / CGFloat(data.count) * CGFloat(index + 1)
          let yAxis = maxY - minY
          let yPosition = (1 - CGFloat((data[index] - minY) / yAxis)) * reader.size.height
          if index == 0 {
            path.move(to: CGPoint(x: xPosition, y: yPosition))
          }
          path.addLine(to: CGPoint(x: xPosition, y: yPosition))
        }
      }
      .stroke(color, style: StrokeStyle(lineWidth: 1, lineCap: .butt, lineJoin: .round))
      .shadow(color: color, radius: 8, x: 0, y: 8)
    }
  }
}
