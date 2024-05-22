//
//  PundixAXUnit.swift
//  WhisperAX
//
//  Created by Andy.Chan on 2024/5/22.
//

import Foundation
import WhisperKit
import RxSwift
import RxRelay

class PundixAiServer: NSObject {  
    func execute(_ tr:TranscriptionResult) -> Bool {
        var results:[[String:Any]] = []
        for segment in tr.segments {
            var items:[String:Any] = [:]
            if let textDic = extractTextToDic(languages: Array(Constants.languageCodes), input: segment.text) {
                items["start"] = formatTimestamp(segment.start)
                items["end"] = formatTimestamp(segment.end)
                items["text"] = textDic
                results.append(items)
                print("[\(formatTimestamp(segment.start)) - \(formatTimestamp(segment.end))]>>>>>", items)
            }
        }
        return results.count > 0
    }
}

// 提取文本数据
extension PundixAiServer {
    private func formatTimestamp(_ timestamp: Float) -> String {
        return String(format: "%.2f", timestamp)
    }

    func extractTagContent(input:String) -> [String] {
        let pattern = "<\\|(\\w+)\\|>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }
     
        var result:[String] = []
        let matches = regex.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
        for match in matches {
            let tagRange = match.range(at: 1)
            if let range = Range(tagRange, in: input) {
                let tagName = input[range]
                result.append(String(tagName))
            }
        }
        return result
    }

    func extractLangage(languages:[String], tags:[String]) ->String? {
        if tags.count >= 3 {
            let langage = tags[1]
            return languages.contains(where: { $0 == langage }) ? langage : nil
        }
        return nil
    }

    func extractModel(tags:[String]) ->String? {
        if tags.contains(where: { $0 == "translate" }) { return  "translate" }
        if tags.contains(where: { $0 == "transcribe"}) { return  "transcribe" }
        return nil
    }

    func extractTextToDic(languages:[String], input:String) ->Dictionary<String,String>? {
        var text = input
        let tags = extractTagContent(input: input)
        var result:[String:String] = [:]
        if tags.first == "startoftranscript" && tags.last == "endoftext" {
            if let langage = extractLangage(languages: languages, tags: tags) {
                result["langage"] = langage
            }
            
            if let model = extractModel(tags: tags) {
                result["model"] = model
            }
            
            for item in tags {
                text = text.replacingOccurrences(of: "<|\(item)|>", with: "")
            }
            text = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                result["text"] = text
                return result
            }
        }
        return nil
    }
}
