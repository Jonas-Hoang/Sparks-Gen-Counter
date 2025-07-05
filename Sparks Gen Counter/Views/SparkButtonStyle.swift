//
//  SparkButtonStyle.swift
//  Sparks Gen Counter
//
//  Created by Jonas Hoang on 4/7/25.
//

import SwiftUI

struct CircularSparkButton: ViewModifier {
    var color: Color = .blue
    var size: CGFloat = 60

    func body(content: Content) -> some View {
        content
            .frame(width: size, height: size)
            .background(Circle().fill(color))
            .foregroundColor(.white)
            .buttonStyle(.plain)
    }
}

struct RectangularSparkButton: ViewModifier {
    var color: Color = .blue
    var width: CGFloat = 120
    var height: CGFloat = 44

    func body(content: Content) -> some View {
        content
            .frame(width: width, height: height)
            .background(RoundedRectangle(cornerRadius: 12).fill(color))
            .foregroundColor(.white)
            .buttonStyle(.plain)
    }
}

extension View {
    func circularSparkButton(color: Color = .blue, size: CGFloat = 60) -> some View {
        self.modifier(CircularSparkButton(color: color, size: size))
    }

    func rectangularSparkButton(color: Color = .blue, width: CGFloat = 120, height: CGFloat = 44) -> some View {
        self.modifier(RectangularSparkButton(color: color, width: width, height: height))
    }
}
