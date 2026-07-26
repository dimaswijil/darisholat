//
//  AboutView.swift
//  DariSholat
//
//  About screen: one column over the wallpaper — app info, Palestine
//  solidarity, credits, then the developer profile and links below.
//  Golden Ratio (φ = 1.618) and Fibonacci spacing tokens.
//

import SwiftUI

struct AboutView: View {
    let language: String

    var body: some View {
        GeometryReader { geometry in
            // Golden-ratio split: app info takes the major section (61.8%),
            // developer & links the minor (38.2%).
            let rightWidth = max(200, geometry.size.width * 0.382)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 13) {
                    // App name spans both columns
                    VStack(spacing: 8) {
                        Text("DariSholat")
                            .font(.system(size: 21, weight: .bold, design: .serif))
                            .foregroundColor(.primary)

                        Text("\(L10n.version(language)) 2.0.0")
                            .font(.system(size: CGFloat.fontSmall, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)

                    // Columns start together — cards level on both sides
                    HStack(alignment: .top, spacing: 21) {
                        // ── Major column: App Info ─────────────────────
                        VStack(spacing: 13) {
                            // Palestine Solidarity
                            aboutCard {
                                VStack(spacing: 5) {
                                    Text("🍉")
                                        .font(.system(size: 21))
                                    Text("From One Ummah")
                                        .font(.system(size: CGFloat.fontBody, weight: .semibold))
                                    Text("From River To The Sea,")
                                        .font(.system(size: CGFloat.fontSmall, weight: .medium))
                                        .foregroundColor(.secondary)
                                    Text("Palestine Will Be Free")
                                        .font(.system(size: CGFloat.fontSmall, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 13)
                                .frame(maxWidth: .infinity)
                            }

                            // Credits
                            aboutCard {
                                VStack(spacing: 8) {
                                    Text("Powered by Adhan (Batoul Apps)")
                                        .font(.system(size: CGFloat.fontSmall, weight: .regular))
                                        .foregroundColor(.secondary)

                                    Link("github.com/batoulapps/adhan-swift", destination: URL(string: "https://github.com/batoulapps/adhan-swift")!)
                                        .font(.system(size: CGFloat.fontSmall, weight: .medium))
                                        .foregroundColor(.accentColor)
                                }
                                .padding(.vertical, 13)
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(maxWidth: .infinity)

                        // ── Minor column: Developer & Links ────────────
                        // No headers above the first card — its top edge
                        // lines up exactly with the Palestine card's.
                        VStack(alignment: .leading, spacing: 13) {
                            aboutCard {
                                VStack(spacing: 10) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.accentColor.opacity(0.15))
                                            .frame(width: 48, height: 48)
                                        Text("DW")
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundColor(.accentColor)
                                    }
                                    .padding(.top, 13)

                                    VStack(spacing: 3) {
                                        Text("Dimas Wijil")
                                            .font(.system(size: CGFloat.fontBody, weight: .semibold))
                                            .foregroundColor(.primary)

                                        Text("@dimaswijil")
                                            .font(.system(size: CGFloat.fontSmall, weight: .regular))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.bottom, 13)
                                .frame(maxWidth: .infinity)
                            }

                            aboutCard {
                                linkRow(
                                    icon: "link",
                                    title: "GitHub Repository",
                                    subtitle: "dimaswijil/DariSholat",
                                    url: "https://github.com/dimaswijil/DariSholat"
                                )
                            }

                            // Footer
                            VStack(spacing: 4) {
                                Text("Made with ☪︎ in Indonesia")
                                    .font(.system(size: CGFloat.fontSmall - 1, weight: .regular))
                                    .foregroundColor(.secondary.opacity(0.8))
                                Text("© 2026 Dimas Wijil")
                                    .font(.system(size: CGFloat.fontSmall - 1, weight: .regular))
                                    .foregroundColor(.secondary.opacity(0.8))
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .frame(width: rightWidth)
                    }
                }
                .padding(.horizontal, 21)
                .padding(.top, 24) // clears the titlebar (fullSizeContentView)
                .padding(.bottom, 21)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            GeometryReader { proxy in
                ZStack {
                    Image("AboutWallpaper")
                        .resizable()
                        .scaledToFill()
                    Color.black.opacity(0.6)
                }
                .frame(width: proxy.size.width, height: proxy.size.height + 10)
                .clipped()
                .offset(y: -5)
            }
        )
    }

    // MARK: - Card Container

    @ViewBuilder
    private func aboutCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.35))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
        .padding(.horizontal, 13)
    }

    // MARK: - Link Row

    @ViewBuilder
    private func linkRow(icon: String, title: String, subtitle: String, url: String) -> some View {
        if let linkURL = URL(string: url) {
            Link(destination: linkURL) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.12))
                            .frame(width: 28, height: 28)
                        Image(systemName: icon)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.accentColor)
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        Text(title)
                            .font(.system(size: CGFloat.fontBody, weight: .regular))
                            .foregroundColor(.primary)
                        Text(subtitle)
                            .font(.system(size: CGFloat.fontSmall - 1, weight: .regular))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }

                    Spacer(minLength: 4)

                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary.opacity(0.5))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(HoverMenuButtonStyle())
        }
    }
}
