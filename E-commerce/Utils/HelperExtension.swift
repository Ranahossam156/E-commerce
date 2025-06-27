//
//  helperExtension.swift
//  E-commerce
//
//  Created by MacBook on 08/06/2025.
//

import Foundation
import SwiftUI

extension String {
    var capitalizingFirstLetterOnly: String {
        guard let first = self.first else { return self }
        return first.uppercased() + self.dropFirst().lowercased()
    }
}

extension DateFormatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

func formattedDate(from date: Date?) -> String {
    guard let date = date else { return "N/A" }
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter.string(from: date)
}

func maskedEmail(_ email: String) -> String {
    let components = email.split(separator: "@")
    guard components.count == 2 else { return email }

    let name = String(components[0])
    let domain = components[1]

    let visibleCount = min(4, name.count)
    let visiblePrefix = name.prefix(visibleCount)
    let masked = String(repeating: "*", count: max(0, name.count - visibleCount))

    return "\(visiblePrefix)\(masked)@\(domain)"
}

extension View {
    func shimmer(active: Bool = true) -> some View {
        self
            .redacted(reason: active ? .placeholder : [])
            .overlay(
                GeometryReader { geometry in
                    if active {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.9),
                                Color.white.opacity(0.4)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .rotationEffect(.degrees(20))
                        .offset(x: -geometry.size.width)
                        .frame(width: geometry.size.width * 2)
                        .animation(
                            .linear(duration: 1.2).repeatForever(autoreverses: false),
                            value: UUID()
                        )
                        .mask(self)
                    }
                }
            )
    }
}
