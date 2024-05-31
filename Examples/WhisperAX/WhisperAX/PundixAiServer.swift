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
import Alamofire


struct TextModel {
    let text:String
    let model:String
    let language:String
    let start:String
    let end:String
}

class PundixAiServer: NSObject {
    private func dataToDicionary(jsonData:Data) ->Dictionary<String, AnyObject>? {
        if let result = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: AnyObject] {
            return result
        }
        return nil
    }
    
    func post(url:String, items:[TextModel]) ->Observable<Dictionary<String,Any>> {
        return Observable.create { [weak self] (observer) -> Disposable in
            var texts:[Dictionary<String,String>] = []
            items.forEach { it in
                let pms = ["text": it.text, "model": it.model, "language":it.language, "start":it.start, "end":it.end]
                texts.append(pms)
            }
            let parameters = ["items":texts]
            let connect = AF.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default)
                .responseData(completionHandler: { response in
                    switch response.result {
                    case .success(let value):
                        if let data = self?.dataToDicionary(jsonData: value) {
                            observer.onNext(data)
                            observer.onCompleted()
                        }else {
                            observer.onError(NSError(domain: "返回参数JSON序列化错误", code: 0))
                        }
                    case.failure(let error):
                        observer.onError(error)
                    }
                })
            return Disposables.create {connect.cancel() }
        }
    }

    func execute(_ url:String, _ tr:TranscriptionResult) ->Observable<Dictionary<String,Any>> {
        var items:[TextModel] = []
        for segment in tr.segments {
            if let tModel = extractTextToDic(languages: Array(Constants.languageCodes), input: segment.text) {
                let item = TextModel(text: tModel.text, model: tModel.model,
                                     language: tModel.language, 
                                     start: formatTimestamp(segment.start),
                                     end: formatTimestamp(segment.end))
                
                items.append(item)
            }
        }
        if items.count > 0 {
            return post(url: url, items: items)
        }
        
        return .error(NSError(domain: "音频输入为空", code: 0))
    }
}

// 提取文本数据
extension PundixAiServer {
    private func formatTimestamp(_ timestamp: Float) -> String {
        return String(format: "%.2f", timestamp)
    }

    func extractTagContent(input:String) -> [String] {
        let pattern = "<\\|(.+?)\\|>"
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

    func isNospeech(tags:[String]) ->Bool {
        return tags.contains { it in
            return it == "nospeech"
        }
    }
    
    func extractLangage(languages:[String], tags:[String]) ->String? {
        if tags.count >= 2 && tags.first == "startoftranscript" {
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

    func extractTextToDic(languages:[String], input:String) ->TextModel? {
        var text = input
        let tags = extractTagContent(input: input)
        if !isNospeech(tags: tags) {
            var _language:String? = "en"
            if let language = extractLangage(languages: languages, tags: tags) {
                _language = language
            }
            
            var _model:String? = "transcribe"
            if let model = extractModel(tags: tags) {
                _model = model
            }
            
            for item in tags {
                text = text.replacingOccurrences(of: "<|\(item)|>", with: "")
            }
            text = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty , let _md = _model , let _lan = _language {
                return TextModel(text: text, model: _md, language: _lan, start: "", end: "")
            }
        }
        return nil
    }
}
