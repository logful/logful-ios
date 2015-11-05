Pod::Spec.new do |s|
  s.name         = "Logful"
  s.version      = "0.2.0"
  s.homepage     = "https://github.com/logful/logful-ios"
  s.summary      = "Logful iOS sdk"
  s.author       = { "Getui" => "support@getui.com" }
  s.license      = { :type => "MIT" }

  s.ios.platform = :ios, "9.1"
  s.ios.deployment_target = "7.0"
  s.source       =  {
    :git => "https://github.com/logful/logful-ios.git",
    :tag => s.version
  }
  s.source_files = "Source/*.{h,m}", "Source/**/*.{h,m}"
  s.libraries = "z", "sqlite3.0"
  s.pod_target_xcconfig = {
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited) $(PODS_ROOT)/Framework'
  }
  s.vendored_frameworks = "Framework/openssl.framework"
  s.frameworks = "MobileCoreServices", "SystemConfiguration", "UIKit"
  s.requires_arc = true
end
