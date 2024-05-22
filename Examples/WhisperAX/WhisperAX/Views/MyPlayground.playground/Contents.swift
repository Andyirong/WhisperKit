import Foundation

public let languages: [String: String] =
    [
        "english": "en",
        "chinese": "zh",
        "german": "de",
        "spanish": "es",
        "russian": "ru",
        "korean": "ko",
        "french": "fr",
        "japanese": "ja",
        "portuguese": "pt",
        "turkish": "tr",
        "polish": "pl",
        "catalan": "ca",
        "dutch": "nl",
        "arabic": "ar",
        "swedish": "sv",
        "italian": "it",
        "indonesian": "id",
        "hindi": "hi",
        "finnish": "fi",
        "vietnamese": "vi",
        "hebrew": "he",
        "ukrainian": "uk",
        "greek": "el",
        "malay": "ms",
        "czech": "cs",
        "romanian": "ro",
        "danish": "da",
        "hungarian": "hu",
        "tamil": "ta",
        "norwegian": "no",
        "thai": "th",
        "urdu": "ur",
        "croatian": "hr",
        "bulgarian": "bg",
        "lithuanian": "lt",
        "latin": "la",
        "maori": "mi",
        "malayalam": "ml",
        "welsh": "cy",
        "slovak": "sk",
        "telugu": "te",
        "persian": "fa",
        "latvian": "lv",
        "bengali": "bn",
        "serbian": "sr",
        "azerbaijani": "az",
        "slovenian": "sl",
        "kannada": "kn",
        "estonian": "et",
        "macedonian": "mk",
        "breton": "br",
        "basque": "eu",
        "icelandic": "is",
        "armenian": "hy",
        "nepali": "ne",
        "mongolian": "mn",
        "bosnian": "bs",
        "kazakh": "kk",
        "albanian": "sq",
        "swahili": "sw",
        "galician": "gl",
        "marathi": "mr",
        "punjabi": "pa",
        "sinhala": "si",
        "khmer": "km",
        "shona": "sn",
        "yoruba": "yo",
        "somali": "so",
        "afrikaans": "af",
        "occitan": "oc",
        "georgian": "ka",
        "belarusian": "be",
        "tajik": "tg",
        "sindhi": "sd",
        "gujarati": "gu",
        "amharic": "am",
        "yiddish": "yi",
        "lao": "lo",
        "uzbek": "uz",
        "faroese": "fo",
        "haitian creole": "ht",
        "pashto": "ps",
        "turkmen": "tk",
        "nynorsk": "nn",
        "maltese": "mt",
        "sanskrit": "sa",
        "luxembourgish": "lb",
        "myanmar": "my",
        "tibetan": "bo",
        "tagalog": "tl",
        "malagasy": "mg",
        "assamese": "as",
        "tatar": "tt",
        "hawaiian": "haw",
        "lingala": "ln",
        "hausa": "ha",
        "bashkir": "ba",
        "javanese": "jw",
        "sundanese": "su",
        "cantonese": "yue",
        "burmese": "my",
        "valencian": "ca",
        "flemish": "nl",
        "haitian": "ht",
        "letzeburgesch": "lb",
        "pushto": "ps",
        "panjabi": "pa",
        "moldavian": "ro",
        "moldovan": "ro",
        "sinhalese": "si",
        "castilian": "es",
        "mandarin": "zh",
    ]

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

func extractTextToDic(input:String) ->Dictionary<String,String>? {
    var text = input
    let tags = extractTagContent(input: input)
    var result:[String:String] = [:]
    if tags.first == "startoftranscript" && tags.last == "endoftext" {
        if let langage = extractLangage(languages: languages.map { $0.value }, tags: tags) {
            result["langage"] = langage
        }
        
        if let model = extractModel(tags: tags) {
            result["model"] = model
        }
        
        for item in tags {
            text = text.replacingOccurrences(of: "<|\(item)|>", with: "")
            
        }
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        result["text"] = text
        return result
    }
    return nil
}


// 定义要匹配的文本
var text = "<|startoftranscript|><|zh|><|translate|><|notimestamps|> Go home quickly Go home quickly Open the camera Open the voice manager Re-initialize Good morning.<|endoftext|>"
let result = extractTextToDic(input: text)

print(result)



