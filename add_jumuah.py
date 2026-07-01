with open("DariSholat/Localization.swift", "r") as f:
    content = f.read()

jumuah_func = """
    static func jumuah(_ lang: String) -> String {
        switch lang {
        case "ar": return "الجمعة"
        case "id": return "Jumat"
        case "tr": return "Cuma"
        case "ja": return "ジュムア"
        case "kk": return "Жұма"
        case "fa": return "جمعه"
        case "ur": return "جمعہ"
        case "ms": return "Jumaat"
        default:   return "Jumu'ah"
        }
    }
"""

if "func jumuah" not in content:
    # Insert it right after the dhuhr function
    content = content.replace("static func dhuhr(_ lang: String) -> String {", jumuah_func + "\n    static func dhuhr(_ lang: String) -> String {")
    with open("DariSholat/Localization.swift", "w") as f:
        f.write(content)
    print("Added jumuah to Localization.swift")
else:
    print("jumuah already exists")
