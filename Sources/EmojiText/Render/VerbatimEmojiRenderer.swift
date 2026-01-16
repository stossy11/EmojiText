//
//  VerbatimEmojiRenderer.swift
//  EmojiText
//
//  Created by David Walter on 26.01.24.
//

import SwiftUI
import OSLog

struct VerbatimEmojiRenderer: EmojiRenderer {
    let string: String
    let shouldOmitSpacesBetweenEmojis: Bool
    
    // MARK: - SwiftUI
    func render(emojis: [String: LoadedEmoji], size: CGFloat?) -> Text {
        renderAnimated(emojis: emojis, size: size, at: 0)
    }
    
    func renderAnimated(emojis: [String: LoadedEmoji], size: CGFloat?, at time: CFTimeInterval) -> Text {
        let string = renderString(from: string, with: emojis)
        
        var result = Text(verbatim: "")
        let splits = string.splitOnEmoji(omittingSpacesBetweenEmojis: shouldOmitSpacesBetweenEmojis)
        
        for substring in splits {
            if let emoji = emojis[substring] {
                // If the part is an emoji we render it as an inline image
                let text = Text(emoji, size: size, at: time)
                result = result + text
            } else {
                // Parse markdown and render the part as formatted text
                result = result + parseMarkdown(substring)
            }
        }
        
        return result
    }
    
    // MARK: - UIKit & AppKit
    func render(emojis: [String: LoadedEmoji], size: CGFloat?) -> NSAttributedString {
        let string = renderString(from: string, with: emojis)
        
        let result = NSMutableAttributedString()
        result.beginEditing()
        
        let splits = string.splitOnEmoji(omittingSpacesBetweenEmojis: shouldOmitSpacesBetweenEmojis)
        for substring in splits {
            if let emoji = emojis[substring] {
                // If the part is an emoji we render it as an inline image
                result.append(NSAttributedString(emoji, size: size))
            } else {
                // Parse markdown and render the part as formatted text
                result.append(parseMarkdownToAttributedString(substring))
            }
        }
        
        result.endEditing()
        return result
    }
    
    // MARK: - Markdown Parsing
    private func parseMarkdown(_ text: String) -> Text {
        if let attributedString = try? AttributedString(markdown: text) {
            return Text(attributedString)
        }
        
        return Text(text)
    }
    
    private func parseMarkdownToAttributedString(_ text: String) -> NSAttributedString {
        if let attributedString = try? AttributedString(markdown: text) {
            return NSAttributedString(attributedString)
        }
        
        return NSAttributedString(string: text)
    }
    
    // MARK: - Helper
    private func renderString(from string: String, with emojis: [String: LoadedEmoji]) -> String {
        var text = string
        
        for shortcode in emojis.keys {
            text = text.replacingOccurrences(
                of: "\(shortcode)",
                with: "\(String.emojiSeparator)\(shortcode)\(String.emojiSeparator)"
            )
        }
        
        return text
    }
}

#if DEBUG
#Preview {
    List {
        EmojiText(
            verbatim: "Hello :a:",
            emojis: .emojis
        )
        EmojiText(
            verbatim: "World :wide:",
            emojis: .emojis
        )
        EmojiText(
            verbatim: "Hello World :test:",
            emojis: .emojis
        )
    }
}
#endif
