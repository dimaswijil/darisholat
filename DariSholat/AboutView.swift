//
//  AboutView.swift
//  DariSholat
//
//  About screen with app info, credits, and version.
//

import SwiftUI

struct AboutView: View {
    let language: String
    var onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            
            // ── Navigation header ─────────────────────────────────
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 3) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: CGFloat.fontBody, weight: .semibold))
                        Text(L10n.back(language))
                            .font(.system(size: CGFloat.fontBody, weight: .regular))
                    }
                    .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)

                Spacer()

                Text(L10n.about(language))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)

                Spacer()

                // Balance spacer
                HStack(spacing: 3) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: CGFloat.fontBody, weight: .semibold))
                    Text(L10n.back(language))
                        .font(.system(size: CGFloat.fontBody))
                }
                .opacity(0)
            }
            .padding(.horizontal, CGFloat.paddingH)
            .padding(.vertical, CGFloat.headerV)

            Divider().opacity(0.35)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 21) {
                    
                    // App Icon & Name
                    VStack(spacing: 8) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 34))
                            .foregroundColor(.accentColor)
                            .padding(.top, 21)
                        
                        Text("darisholat")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .tracking(-0.4)
                            .foregroundColor(.primary)
                        
                        Text("\(L10n.version(language)) 1.0.0")
                            .font(.system(size: CGFloat.fontSmall, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    // Palestine Solidarity
                    VStack(spacing: 5) {
                        Text("🍉")
                            .font(.system(size: 21))
                        Text("Free Palestine,")
                            .font(.system(size: CGFloat.fontBody, weight: .semibold))
                        Text("from river to the sea")
                            .font(.system(size: CGFloat.fontSmall, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 13)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 13)
                            .fill(Color.primary.opacity(0.04))
                    )
                    .padding(.horizontal, CGFloat.paddingH)

                    // Credits
                    VStack(spacing: 8) {
                        Text("Powered by Adhan (Batoul Apps)")
                            .font(.system(size: CGFloat.fontSmall, weight: .regular))
                            .foregroundColor(.secondary)
                        
                        Link("github.com/batoulapps/adhan-swift", destination: URL(string: "https://github.com/batoulapps/adhan-swift")!)
                            .font(.system(size: CGFloat.fontSmall))
                            .foregroundColor(.accentColor)
                    }
                    .padding(.top, 8)
                }
                .padding(.bottom, 21)
            }
        }
        .frame(minHeight: 460) // Matches SettingsView min height
    }
}
