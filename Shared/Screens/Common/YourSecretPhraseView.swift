//
//  YourSecretPhraseView.swift
//  Bitsfi
//
//  Created by Oliver Le on 22/06/2022.
//

import SwiftUI

struct YourSecretPhraseView: View {
//  @EnvironmentObject var appState: AppState

  private let phrases: String = "infant letter scatter tonight chef perfect always push feel swallow sudden trophy"
  
  var body: some View {
    VStack {
      VStack(spacing: 8) {
        Text("Your Secret Phrase")
          .font(.title)
          .foregroundColor(.title)
        
        Text("Write down or copy these words in the right order and save them somewhere safe.")
          .foregroundColor(.subtitle)
      }
        
      Spacer()
      
      SecretPhraseView(words: phrases.components(separatedBy: .whitespaces))
        .padding(.bottom)
      
      Button("Copy") {
      }
      
      Spacer()
      
      VStack(spacing: 8) {
        Text("Do not share your secret phrase!")
          .font(.body.weight(.medium))
        
        Text("If someone has your secret phrase, they will have full control of your wallet.")
          .multilineTextAlignment(.center)
      }
      .padding()
      .background(Color.neutral1)
      .cornerRadius(4)
      .padding(.vertical)
      
      Button {
//        appState.setWallet(with: "0x5417A03667AbB6A059b3F174c1F67b1E83753046")
      } label: {
        Text("Continue")
          .font(.body.weight(.semibold))
      }
      .buttonStyle(.primaryExpanded)
    }
    .padding()
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct YourSecretPhraseView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      YourSecretPhraseView()
    }
    
    NavigationView {
      YourSecretPhraseView()
    }
    .previewDevice("iPhone 13 Pro")
  }
}

struct SecretPhraseView: View {
  let words: [String]
  
  var body: some View {
    VStack {
      FlexibleView(data: words, spacing: 8, alignment: .center) { word in
        Text(verbatim: word)
          .padding(.vertical, 4)
          .padding(.horizontal, 8)
          .overlay(
            RoundedRectangle(cornerRadius: 4)
              .stroke(Color.subtitle, lineWidth: 1)
          )
      }
    }
  }
}

extension View {
  func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Color.clear
          .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
      }
    )
    .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
  }
}

private struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

/// This view is responsible to lay down the given elements and wrap them into
/// multiple rows if needed.
struct _FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
  let availableWidth: CGFloat
  let data: Data
  let spacing: CGFloat
  let alignment: HorizontalAlignment
  let content: (Data.Element) -> Content
  @State var elementsSize: [Data.Element: CGSize] = [:]
  
  var body : some View {
    VStack(alignment: alignment, spacing: spacing) {
      ForEach(computeRows(), id: \.self) { rowElements in
        HStack(spacing: spacing) {
          ForEach(rowElements, id: \.self) { element in
            content(element)
              .fixedSize()
              .readSize { size in
                elementsSize[element] = size
              }
          }
        }
      }
    }
  }
  
  func computeRows() -> [[Data.Element]] {
    var rows: [[Data.Element]] = [[]]
    var currentRow = 0
    var remainingWidth = availableWidth
    
    for element in data {
      let elementSize = elementsSize[element, default: CGSize(width: availableWidth, height: 1)]
      
      if remainingWidth - (elementSize.width + spacing) >= 0 {
        rows[currentRow].append(element)
      } else {
        currentRow = currentRow + 1
        rows.append([element])
        remainingWidth = availableWidth
      }
      
      remainingWidth = remainingWidth - (elementSize.width + spacing)
    }
    
    return rows
  }
}


/// Facade of our view, its main responsibility is to get the available width
/// and pass it down to the real implementation, `_FlexibleView`.
struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
  let data: Data
  let spacing: CGFloat
  let alignment: HorizontalAlignment
  let content: (Data.Element) -> Content
  @State private var availableWidth: CGFloat = 0
  
  var body: some View {
    ZStack(alignment: Alignment(horizontal: alignment, vertical: .center)) {
      Color.clear
        .frame(height: 1)
        .readSize { size in
          availableWidth = size.width
        }
      
      _FlexibleView(
        availableWidth: availableWidth,
        data: data,
        spacing: spacing,
        alignment: alignment,
        content: content
      )
    }
  }
}
