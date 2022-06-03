//
//  PrimaryButton.swift
//  Bitsfi
//
//  Created by Oliver Le on 09/06/2022.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
  enum Size {
    case fit, expanded
  }
  
  private let size: Size
  
  init(size: Size = .fit) {
    self.size = size
  }
  
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.system(size: 16, weight: .medium, design: .default))
      .padding()
      .frame(maxWidth: size == .expanded ? .infinity : nil)
      .background(Color.appPrimary)
      .foregroundColor(Color.white.opacity(configuration.isPressed ? 0.5 : 1))
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .scaleEffect(configuration.isPressed ? 0.95 : 1)
  }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
  static var primary: Self { Self() }
  static var primaryFit: Self { Self(size: .fit) }
  static var primaryExpanded: Self { Self(size: .expanded) }

}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
      Button("Press this", action: {})
        .buttonStyle(.primary)
        .previewLayout(PreviewLayout.sizeThatFits)
        .padding()
        .previewDisplayName("Default primary button")
      
      Button("Press this", action: {})
        .buttonStyle(.primaryFit)
        .previewLayout(PreviewLayout.sizeThatFits)
        .padding()
        .previewDisplayName("Fit primary button")
      
      Button("Press this", action: {})
        .buttonStyle(.primaryExpanded)
        .previewLayout(PreviewLayout.sizeThatFits)
        .padding()
        .previewDisplayName("Expanded primary button")
    }
}
