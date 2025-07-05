//
//  NSSave.swift
//  Sparks Gen Counter
//
//  Created by Jonas Hoang on 5/7/25.
//
import UniformTypeIdentifiers
import AppKit

func saveCardDataJSON(_ jsonData: Data) {
    let panel = NSSavePanel()
    panel.title = "Save CardData.json"
    panel.nameFieldStringValue = "CardData.json"
    
    // ✅ Sử dụng UTType thay vì allowedFileTypes (deprecated)
    if #available(macOS 12.0, *) {
        panel.allowedContentTypes = [UTType.json]
    } else {
        panel.allowedFileTypes = ["json"]
    }

    if panel.runModal() == .OK, let url = panel.url {
        do {
            try jsonData.write(to: url)
            print("✅ Đã lưu JSON tại: \(url.path)")
        } catch {
            print("❌ Ghi JSON thất bại: \(error)")
        }
    }
}

