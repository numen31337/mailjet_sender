Pod::Spec.new do |s|
  s.name             = 'MailjetSender'
  s.version          = '1.0.0'
  s.summary          = 'Swift wrapper for the mailjet send API.'
  s.description      = <<-DESC
  Swift wrapper for the mailjet send API. With additional feature to archive attachments.
                       DESC

  s.homepage         = 'https://github.com/numen31337/mailjet_sender'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Alexander Kirsch' => 'spam-reporter-3000@alexander-kirsch.com' }
  s.source           = { :git => 'https://github.com/numen31337/mailjet_sender.git', :tag => s.version.to_s }
  s.source_files     = 'Sources/MailjetSender/**/*'

  s.swift_version    = '5.0'
  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.11'
  s.tvos.deployment_target = '12.0'
  s.watchos.deployment_target = '2.0'
  
  s.dependency 'ZIPFoundation', '~> 0.9'
end
