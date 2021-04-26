import Foundation
import ZIPFoundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Sends an email using the mailjet.com service.
/// Only plain text emails are supported (HTML will not be parsed).
/// `attachments` list of files to send. `jpg/jpeg` files will be sent as separate attachments.
/// All other files will be compressed and sent in a single `zip` archive file.
public class MailjetSender {
    private let publicKey: String
    private let privateKey: String
    
    public init(publicKey: String, privateKey: String) {
        assert(!publicKey.isEmpty)
        assert(!privateKey.isEmpty)
        
        self.publicKey = publicKey
        self.privateKey = privateKey
    }
    
    /// Sends an e-mail using the `Mailjet` service. Returns an error in the `completion` block or `nil` if successful.
    public func send(
        sandbox: Bool = false,
        from: String,
        fromName: String? = nil,
        to: String,
        toName: String? = nil,
        replyTo: String? = nil,
        attachments: Set<NamedFile>? = nil,
        subject: String,
        message: String,
        completion: ((Error?) -> Void)? = nil
    ) {
        if message.isEmpty && attachments == nil && subject.isEmpty {
            completion?(MailjetSenderError("Can't send an empty message."))
            return
        }
        
        guard let request = buildRequest(
            sandbox: sandbox,
            from: from,
            fromName: fromName,
            to: to,
            toName: toName,
            replyTo: replyTo,
            attachments: attachments,
            subject: subject,
            message: message.isEmpty ? " " : message
        ) else { completion?(MailjetSenderError("Error creating request.")); return }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, let result = try? JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any> else {
                completion?(MailjetSenderError("Error parsing response."))
                return
            }
            
            guard let resultMessages = result["Messages"] as? [Dictionary<String, Any>],
                  !result.isEmpty,
                  let resultMessage = resultMessages.first else {
                completion?(MailjetSenderError("Error parsing Messages response. Error: \(result["ErrorMessage"] ?? "Unknown")"))
                return
            }
            
            if resultMessage["Status"] as? String == "success" {
                completion?(nil)
            } else {
                completion?(MailjetSenderError("Failed to send the message."))
            }
        }
        task.resume()
    }
    
    /// Builds the body of the request
    private func buildRequest(
        sandbox: Bool,
        from: String,
        fromName: String? = nil,
        to: String,
        toName: String? = nil,
        replyTo: String? = nil,
        attachments: Set<NamedFile>?,
        subject: String,
        message: String
    ) -> URLRequest? {
        assert(!message.isEmpty, "The message field can not be empty as it will be rejected by the service.")
        
        let loginString = "\(publicKey):\(privateKey)"
        guard let loginData = loginString.data(using: String.Encoding.utf8) else { return nil }
        let authString = loginData.base64EncodedString()
        guard let url = URL(string: "https://api.mailjet.com/v3.1/send") else { return nil }
        
        var fromField = ["Email": from]
        if let fromName = fromName { fromField["Name"] = fromName }
        
        var toField = ["Email": to]
        if let toName = toName { toField["Name"] = toName }
        
        let attachmentsDict = buildAttachmentsDict(attachments: attachments)
        var message: Dictionary<String, Any> = [
            "From": fromField,
            "To": [toField],
            "Subject": subject,
            "TextPart": message,
        ]
        if let replyTo = replyTo { message["ReplyTo"] = ["Email": replyTo] }
        if let attachmentsDict = attachmentsDict { message["Attachments"] = attachmentsDict }
        
        var requestBody: Dictionary<String, Any> = [
            "Messages": [message]
        ]
        if sandbox { requestBody["SandboxMode"] = true }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(authString)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    /// Builds `Attachments` part of the request
    private func buildAttachmentsDict(attachments: Set<NamedFile>?) -> [Dictionary<String, Any>]? {
        guard let attachments = attachments, !attachments.isEmpty else { return nil }
        
        let jpegAttachments = attachments.filter { $0.isJpeg() }
        let otherAttachments = attachments.subtracting(jpegAttachments)
        let jpegAttachmentsData: [Dictionary<String, String>]? = jpegAttachments.map {
            [
                "ContentType": "image/jpeg",
                "Filename": $0.name,
                "Base64Content": $0.data.base64EncodedString(),
            ]
        }
        let archivedDataInBase64 = archiveAttachments(otherAttachments)?.base64EncodedString()
        let otherAttachmentsData: Dictionary<String, String>? = archivedDataInBase64 != nil ?
            [
                "ContentType": "application/zip",
                "Filename": "attachments.zip",
                "Base64Content": archivedDataInBase64!,
            ]
            : nil
        
        if jpegAttachmentsData != nil || otherAttachmentsData != nil {
            var result: [[String: String]] = []
            if let jpegAttachmentsData = jpegAttachmentsData, !jpegAttachmentsData.isEmpty {
                result.append(contentsOf: jpegAttachmentsData)
            }
            if let otherAttachmentsData = otherAttachmentsData {
                result.append(otherAttachmentsData)
            }
            
            return result.isEmpty ? nil : result
        } else {
            return nil
        }
    }
    
    /// Archives set of attachments into a `zip` archive.
    private func archiveAttachments(_ attachments: Set<NamedFile>?) -> Data? {
        guard let attachments = attachments, !attachments.isEmpty else { return nil }
        guard let archive = Archive(accessMode: .create) else { return nil }
        
        attachments.forEach { (file) in
            try? archive.addEntry(with: file.name,
                                  type: .file,
                                  uncompressedSize: UInt32(file.data.count),
                                  provider: { (position, size) -> Data in
                                    return file.data.subdata(in: position..<position+size)
                                  })
        }
        
        return archive.data
    }
}
