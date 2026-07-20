//
//  AboutView.swift
//  DariSholat
//
//  About screen with app info, credits, developer profile, and GitHub link.
//  Optimized using the Golden Ratio (φ = 1.618) and Fibonacci spacing tokens.
//

import SwiftUI

struct AboutView: View {
    let language: String

    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            // Partition columns based on Golden Ratio
            let rightWidth = max(210, totalWidth * 0.382)
            let leftWidth = totalWidth - rightWidth

            HStack(alignment: .top, spacing: 0) {
                // ── Left Column: App Info ──────────────────────────────
                leftColumn
                    .frame(width: leftWidth)

                // Vertical separator
                Divider()

                // ── Right Column: Developer & Links ───────────────────
                rightColumn
                    .frame(width: rightWidth)
            }
        }
        .frame(minHeight: 460)
    }

    // MARK: - Left Column (App Info)

    private var leftColumn: some View {
        VStack(spacing: 0) {
            // Navigation header
            HStack {
                Spacer()

                Text(L10n.about(language))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Spacer()
            }
            .frame(height: 21) // Fibonacci f21
            .padding(.horizontal, 13) // Fibonacci f13
            .padding(.top, 5)         // Fibonacci f5
            .padding(.bottom, 5)      // Fibonacci f5

            Divider().opacity(0.35)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 13) { // Fibonacci f13

                    // App Name
                    VStack(spacing: 8) {
                        Text("DariSholat")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .tracking(-0.4)
                            .foregroundColor(.primary)
                            .padding(.top, 21) // Fibonacci f21

                        Text("\(L10n.version(language)) 1.1.0")
                            .font(.system(size: CGFloat.fontSmall, weight: .medium))
                            .foregroundColor(.secondary)
                    }

                    // Palestine Solidarity
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
                    .background(
                        RoundedRectangle(cornerRadius: 13)
                            .fill(Color.primary.opacity(0.04))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 13)
                            .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                    )
                    .padding(.horizontal, 13)

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
                .padding(.top, 8)
                .padding(.bottom, 21)
            }
        }
        .background(
            GeometryReader { proxy in
                ZStack {
                    Image("AboutWallpaper")
                        .resizable()
                        .scaledToFill()
                    Color.black.opacity(0.6)
                }
                .frame(width: proxy.size.width, height: proxy.size.height + 10)
                .offset(y: -5)
            }
        )
    }

    // MARK: - Right Column (Developer & Links)

    private var rightColumn: some View {
        VStack(spacing: 0) {
            // Matching top alignment space
            Color.clear
                .frame(height: 21)
                .padding(.top, 5)
                .padding(.bottom, 5)

            Divider().opacity(0.35)
                .padding(.horizontal, 13)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 8) {

                    // Developer Section Header
                    sectionHeader("Developer", icon: "person.fill")

                    // Developer profile card
                    aboutCard {
                        VStack(spacing: 10) {
                            // Avatar placeholder with initials
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

                    // Links Section Header
                    sectionHeader("Links", icon: "link")

                    // Links Card
                    aboutCard {
                        linkRow(
                            icon: "link",
                            title: "GitHub Repository",
                            subtitle: "dimaswijil/DariSholat",
                            url: "https://github.com/dimaswijil/DariSholat"
                        )
                    }

                    Spacer(minLength: 21)

                    // Footer
                    VStack(spacing: 4) {
                        Text("Made with ☪︎ in Indonesia")
                            .font(.system(size: CGFloat.fontSmall - 1, weight: .regular))
                            .foregroundColor(.secondary.opacity(0.6))
                        Text("© 2026 Dimas Wijil")
                            .font(.system(size: CGFloat.fontSmall - 1, weight: .regular))
                            .foregroundColor(.secondary.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 13)
                }
                .padding(.top, 8)
            }
        }
    }

    // MARK: - Section Header

    @ViewBuilder
    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: CGFloat.fontSmall - 1, weight: .medium))
                .foregroundColor(.accentColor)
            Text(title)
                .font(.system(size: CGFloat.fontSmall, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 13)
        .padding(.top, 13)
        .padding(.bottom, 5)
    }

    // MARK: - Card Container

    @ViewBuilder
    private func aboutCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.primary.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
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
