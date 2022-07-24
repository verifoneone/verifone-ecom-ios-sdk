Pod::Spec.new do |s|

  s.name             = "VerifoneSDK"
  s.version          = "1.0.1"
  s.summary          = "Accept payments through VerifoneSDK."
  s.description      = <<-DESC
                       The VerifoneSDK library will allow you to accept payments in your iOS app.
  DESC
  s.homepage         = "https://www.verifone.cloud/"
  # s.documentation_url = ""
  # s.screenshots      = ""
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = "Verifone"
  s.source           = { :git => "https://github.com/verifoneone/verifone-ecom-ios-sdk.git", :tag => s.version.to_s }

  s.platform         = :ios, "11.0"
  s.swift_version    = "5.0"
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  s.source_files   = "VerifoneSDK/**/*.{h,m,swift}"
  s.resources = ["VerifoneSDK/**/*.{lproj,xcassets,storyboard}"]
  s.public_header_files = "VerifoneSDK/*.{h}"
  s.vendored_frameworks = ['Frameworks/Cardinal/2.2.5-2/CardinalMobile.xcframework', 'Frameworks/Gopenpgp/1.0/Gopenpgp.xcframework']
  s.header_dir = "VerifoneSDK"
end
