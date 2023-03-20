//
//  QRView.swift
//  Mochi
//
//  Created by Oliver Le on 29/01/2023.
//

import SwiftUI

struct QRView: View {
    var body: some View {
        ZStack {
            Theme.gray
                .ignoresSafeArea()
            VStack {
                Spacer()
                Text("Share QR Code")
                    .font(.inter(size: 22, weight: .bold))
                    .foregroundColor(Theme.text1)
                Spacer(minLength: 61)
                qrCode
                Spacer()
                actions
            }
        }
    }
   
    // MARK: - QR Code
    private var qrCode: some View {
        VStack(spacing: 8) {
            Asset.qrcode
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 300)
            Text("mochi.eth")
                .font(.boldSora(size: 16))
                .foregroundColor(Theme.text1)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .foregroundColor(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.15), radius: 16, y: 4)
        )
    }
   
    // MARK: - Actions
    private var actions: some View {
        VStack(alignment: .leading, spacing: 0) {
            actionButton(icon: Asset.share, title: "Share to") {
                // share
            }
            actionButton(icon: Asset.copy, title: "Copy link to clipboard") {
                // copy
            }
        }
    }
   
    // MARK: - Action button builder
    private func actionButton(
        icon: Image,
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 20) {
                icon
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
               Text(title)
                    .font(.interSemiBold(size: 18))
                    .foregroundColor(Theme.text1)
                Spacer()
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 20)
        }
    }
}

struct QRView_Previews: PreviewProvider {
    static var previews: some View {
        QRView()
            .previewDisplayName("iPhone 14 Pro")
        
        QRView()
            .previewDevice("iPhone SE (3rd generation)")
            .previewDisplayName("iPhone SE")
    }
}
