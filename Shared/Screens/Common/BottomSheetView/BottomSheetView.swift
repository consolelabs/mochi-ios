//
//  BottomSheetView.swift
//  Bits Wallet (iOS)
//
//  Created by Oliver Le on 27/07/2022.
//

import SwiftUI

fileprivate enum Constants {
    static let radius: CGFloat = 16
    static let indicatorHeight: CGFloat = 6
    static let indicatorWidth: CGFloat = 60
    static let snapRatio: CGFloat = 0.25
    static let minHeightRatio: CGFloat = 0
}

public enum BottomSheetDisplayType {
  case fullScreen
  case halfScreen
  case none
}

struct BottomSheetView<Content: View>: View {
  @Binding var isOpen: Bool

  let maxHeight: CGFloat
  let minHeight: CGFloat
  let content: Content
 
  @GestureState private var translation: CGFloat = 0
  
  // MARK: - offset from top edge
  private var offset: CGFloat {
    isOpen ? 0 : maxHeight - minHeight
  }
  
  init(isOpen: Binding<Bool>, maxHeight: CGFloat, @ViewBuilder content: () -> Content) {
    self.minHeight = maxHeight * Constants.minHeightRatio
    self.maxHeight = maxHeight
    self.content = content()
    self._isOpen = isOpen
  }
  
  var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
        self.indicator.padding()
        self.content
      }
      .frame(width: geometry.size.width, height: self.maxHeight, alignment: .top)
      .background(Color(uiColor: .secondarySystemBackground))
      .cornerRadius(Constants.radius)
      .frame(height: geometry.size.height, alignment: .bottom)
      .offset(y: max(self.offset + self.translation, 0))
      .animation(.interactiveSpring(), value: isOpen)
      .animation(.interactiveSpring(), value: translation)
      .gesture(
        DragGesture().updating(self.$translation) { value, state, _ in
          state = value.translation.height
        }
        .onEnded { value in
          let snapDistance = self.maxHeight * Constants.snapRatio
          guard abs(value.translation.height) > snapDistance else {
            return
          }
          self.isOpen = value.translation.height < 0
        }
      )
    }
  }

  private var indicator: some View {
    RoundedRectangle(cornerRadius: Constants.radius)
      .fill(Color.secondary)
      .frame(
        width: Constants.indicatorWidth,
        height: Constants.indicatorHeight
      )
  }
}


struct BottomSheetView_Previews: PreviewProvider {
  
  static var previews: some View {
    BottomSheetView(isOpen: .constant(true), maxHeight: 500) {
      Color.blue
    }
    .edgesIgnoringSafeArea(.all)
  }
}

class CustomHostingController<Content: View>: UIHostingController<Content> {
  override func viewDidLoad() {
    if let presentationController = presentationController as? UISheetPresentationController {
      presentationController.detents = [ .medium(), .large()]
    }
  }
}

struct HalfSheetHelper<SheetView: View>: UIViewControllerRepresentable {
  var sheetView: SheetView
  @Binding var showSheet: Bool

  let controller = UIViewController()
  
  func makeUIViewController(context: Context) -> UIViewController {
    controller.view.backgroundColor = .clear
    return controller
  }
  
  func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    if showSheet {
      let sheetViewController = CustomHostingController(rootView: sheetView)
      uiViewController.present(sheetViewController, animated: true) {
        DispatchQueue.main.async {
          showSheet.toggle()
        }
      }
    }
  }
  
}


extension View {
  func halfSheet<SheetView: View>(
    showSheet: Binding<Bool>,
    @ViewBuilder sheetView: @escaping () -> SheetView
  ) -> some View {
      return self
      .background(
        HalfSheetHelper(sheetView: sheetView(), showSheet: showSheet)
      )
  }
}
