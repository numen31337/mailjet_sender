Unofficial Swift wrapper for the [mailjet send API v3.1](https://dev.mailjet.com/email/guides/send-api-v31/). With additional feature to archive attachments.

### Info

This library only supports text messages (no HTML). All attachments will be archived in a single `attachments.zip' archive file. All JPEG files will be excluded from the archive and directly attached to the message.

### Usage

##### Init the sender object with your credentials
```swift
let sender = MailjetSender(publicKey: "myPublicKey", privateKey: "myPrivateKey")
```

##### Send the email
```swift
sender.send(
	from: "contact-us@your_domain.com",
	fromName: "Sender",
	to: "contact-us-inbox@your_domain.com",
	toName: "Support",
	replyTo: "reply_to@email.address",
	attachments: attachments,
	subject: "My subject",
	message: "My message"
)
```

### Fields

`from`: Sender email address.

`fromName`: Optional, sender name.

`to`: Receiver email address.

`toName`: Optional, sender name.

`replyTo`: Optional, `Reply-To` address.

`attachments`: Optional, set of attachments wrapped in `NamedFile` objects.

`subject`: Subject of the email

`message`: Message body

`completion`: Optional, completion block that returns an error if occurred. Returns `nil` instead of error in case of success.

### Installation

##### SPM
Repository: `https://github.com/numen31337/mailjet_sender.git`, Branch: `main`

##### CocoaPods
`pod 'MailjetSender', :git => 'https://github.com/numen31337/mailjet_sender.git'`