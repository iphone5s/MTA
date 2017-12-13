Pod::Spec.new do |s|

  s.name         = "MTA"
  s.version      = "1.0.0"
  s.summary      = "MTA for macOS"
  s.homepage     = "https://github.com/iphone5s/mta"
  s.license      = "MIT"
  s.author       = {"ezreal" => "453742103@qq.com"}
  s.source        = { :git => "https://github.com/iphone5s/mta.git", :tag => s.version}
  s.source_files  = "MTA/sdk/*.{h,m}"
  s.requires_arc  = true

  s.osx.deployment_target = "10.10"

  s.dependency "CocoaAsyncSocket"
  s.dependency "GZIP"
  s.dependency "GBDeviceInfo"
end
