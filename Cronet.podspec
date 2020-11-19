Pod::Spec.new do |s|
  s.name             = 'Cronet'
  s.version          = '88.0.4324.9-beta'
  s.summary          = 'Cronet is the networking stack of Chromium put into a library for use on mobile'

  s.description      = <<-DESC
  Cronet is the networking stack of Chromium put into a library for use on mobile. 
  This is the same networking stack that is used in the Chrome browser by over a billion people. 
  It offers an easy-to-use, high performance, standards-compliant, and secure way to perform HTTP requests. 
  Cronet has support for both Android and iOS
DESC

  s.homepage         = 'https://chromium.googlesource.com/chromium/src/+/master/components/cronet'
  s.license          = { :type => 'BSD', :file => 'LICENSE' }
  s.authors          = { 'akshetpandey' => 'akshet@pocketgems.com', 'Chromium Developers' => 'net-dev@chromium.org' }
  s.source           = { :git => 'https://github.com/akshetpandey/Cronet.framework.git', :tag => "v#{s.version.to_s}" }
  s.platform         = :ios, '9.0'
  s.requires_arc     = true

  s.vendored_frameworks = 'Frameworks/Cronet.framework'
  s.frameworks = 'SystemConfiguration'
end
