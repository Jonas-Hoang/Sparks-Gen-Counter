//
//  GeneratorView.swift
//  Sparks Gen Counter
//
//  Created by Jonas Hoang on 5/7/25.
//

import SwiftUI

struct GeneratorView: View {
    @State private var generationMessage: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Card Data Generator")
                .font(.largeTitle)
                .bold()

            Button("Generate CardData.json") {
                generateCardData()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            if !generationMessage.isEmpty {
                Text(generationMessage)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(width: 400, height: 300)
    }

    func generateCardData() {
        guard let metadataFile = Bundle.main.url(forResource: "metadata", withExtension: "json") else {
            generationMessage = "❌ Không tìm thấy metadata.json trong bundle."
            return
        }

        let outputFolder = FileManager.default.temporaryDirectory
        let outputFile = outputFolder.appendingPathComponent("CardData.json")

        CardDataGenerator.generateCardData(metadataFile: metadataFile, output: outputFile)

        generationMessage = "✅ JSON đã được ghi vào \(outputFile.path)"
    }
}

#Preview {
    GeneratorView()
}
