import AppIntents

@available(iOS 17.0, *)
struct SendPresetMessageIntent: AppIntent {
    static var title: LocalizedStringResource = "Send Location Text"

    // Define any parameters your shortcut needs
    @Parameter(title: "Recipient")
    var recipient: String
    
    @Parameter(title: "Message")
    var message: String = "This is a preset message!"

    // The method that will be executed when the shortcut runs
    func perform() async throws -> some IntentResult {
        // Code to send a message
        if let url = URL(string: "sms:\(recipient)&body=\(message)") {
            UIApplication.shared.open(url)
        }
        return .result()
    }
}
