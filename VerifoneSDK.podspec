Pod::Spec.new do |s|

  s.name             = "VerifoneSDK"
  s.version          = "0.1.0"
  s.summary          = "Accept payments through VerifoneSDK."
  s.description      = <<-DESC
                       The VerifoneSDK library will allow you to accept payments in your iOS app.
  DESC
  s.homepage         = "https://www.verifone.com/"
  # s.documentation_url = ""
  # s.screenshots      = ""
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = "Verifone"
  s.source           = { :git => "https://gitlab.avangate.local/connectors/ios-verifone-sdk.git", :tag => s.version.to_s }

  s.platform         = :ios, "12.0"
  s.swift_version    = "5.0"

  s.source_files   = "VerifoneSDK/**/*.{h,swift}"
  s.resource_bundles = { 'VerifoneSDK' => ["VerifoneSDK/**/*.{xcassets}"] }
  s.public_header_files = "VerifoneSDK/*.{h}"
  s.vendored_frameworks = ['Frameworks/Cardinal/2.2.5-2/CardinalMobile.xcframework', 'Frameworks/Gopenpgp/1.0/Gopenpgp.xcframework']
  s.header_dir = "VerifoneSDK"
  s.requires_arc = true
end