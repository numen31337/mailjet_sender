import Foundation

struct MailjetSenderError: Error {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    public var localizedDescription: String {
        return message
    }
}
