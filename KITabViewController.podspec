Pod::Spec.new do |s|
  s.name         = "KITabViewController"
  s.version      = "0.1"
  s.summary      = "KITabViewController"
  s.description  = <<-DESC
                   DESC

  s.homepage     = "https://github.com/smartwalle/KITabViewController"
  s.license      = "MIT"
  s.author       = { "SmartWalle" => "smartwalle@gmail.com" }
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/smartwalle/KITabViewController.git", :branch => "master" }
  s.source_files  = "KITabViewController/KITabViewController/*.{h,m}"
  s.framework  = "UIKit"
  s.requires_arc = true
end
