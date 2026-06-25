//
//  AboutView.swift
//  DariSholat
//
//  About screen with app info, credits, developer profile, and GitHub link.
//  Two-column layout matching the main view structure.
//

import SwiftUI

struct AboutView: View {
    let language: String
    var onBack: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // ── Left Column: App Info ──────────────────────────────
            leftColumn
                .frame(width: 260)

            // Vertical separator
            Divider()

            // ── Right Column: Developer & Links ───────────────────
            rightColumn
                .frame(width: 240)
        }
        .frame(minHeight: 460)
        .clipShape(RoundedRectangle(cornerRadius: 13))
    }

    // MARK: - Left Column (App Info)

    private var leftColumn: some View {
        VStack(spacing: 0) {
            // Navigation header
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

                        Text("DariSholat")
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
        .background(
            GeometryReader { proxy in
                ZStack {
                    Image("AboutWallpaper")
                        .resizable()
                        .scaledToFill()
                    Color.black.opacity(0.6)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
            }
        )
    }

    // MARK: - Right Column (Developer & Links)

    private var rightColumn: some View {
        VStack(spacing: 0) {
            // Section header
            HStack {
                HStack(spacing: 3) {
                    Image(systemName: "person.fill")
                        .font(.system(size: CGFloat.fontSmall - 1, weight: .medium))
                        .foregroundColor(.accentColor)
                    Text("Developer")
                        .font(.system(size: CGFloat.fontSmall, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, CGFloat.paddingH)
            .padding(.top, CGFloat.rowV)
            .padding(.bottom, 3)

            // Developer profile card
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

            Divider().opacity(0.35)
                .padding(.horizontal, CGFloat.paddingH)

            // Links section
            VStack(spacing: 0) {
                // GitHub Repository
                linkRow(
                    icon: "link",
                    title: "GitHub Repository",
                    subtitle: "dimaswijil/DariSholat",
                    url: "https://github.com/dimaswijil/DariSholat"
                )

                // GitHub Profile
                linkRow(
                    icon: "person.circle",
                    title: "GitHub Profile",
                    subtitle: "github.com/dimaswijil",
                    url: "https://github.com/dimaswijil"
                )

                Divider().opacity(0.35)
                    .padding(.horizontal, CGFloat.paddingH)

                // Share button
                shareRow
            }

            Spacer(minLength: 0)

            // Footer
            VStack(spacing: 4) {
                Text("Made with ☪︎ in Indonesia")
                    .font(.system(size: CGFloat.fontSmall - 1, weight: .regular))
                    .foregroundColor(.secondary.opacity(0.6))
                Text("© 2026 Dimas Wijil")
                    .font(.system(size: CGFloat.fontSmall - 1, weight: .regular))
                    .foregroundColor(.secondary.opacity(0.6))
            }
            .padding(.bottom, 13)
        }
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
                .padding(.horizontal, CGFloat.paddingH)
                .padding(.vertical, CGFloat.rowV)
                .contentShape(Rectangle())
            }
            .buttonStyle(HoverMenuButtonStyle())
        }
    }

    // MARK: - Share Row

    private var shareRow: some View {
        Button(action: shareApp) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.12))
                        .frame(width: 28, height: 28)
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.accentColor)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text(shareLabel)
                        .font(.system(size: CGFloat.fontBody, weight: .regular))
                        .foregroundColor(.primary)
                    Text("github.com/dimaswijil/DariSholat")
                        .font(.system(size: CGFloat.fontSmall - 1, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }

                Spacer()
            }
            .padding(.horizontal, CGFloat.paddingH)
            .padding(.vertical, CGFloat.rowV)
            .contentShape(Rectangle())
        }
        .buttonStyle(HoverMenuButtonStyle())
    }

    private var shareLabel: String {
        switch language {
        case "ar": return "مشاركة التطبيق"
        case "id": return "Bagikan Aplikasi"
        default:   return "Share App"
        }
    }

    private func shareApp() {
        let shareText = "DariSholat — Prayer Times for macOS 🕌\nhttps://github.com/dimaswijil/DariSholat"
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(shareText, forType: .string)

        // Also show native share picker if available
        let picker = NSSharingServicePicker(items: [shareText])
        if let window = NSApp.keyWindow, let contentView = window.contentView {
            picker.show(relativeTo: contentView.bounds, of: contentView, preferredEdge: .minY)
        }
    }
}
