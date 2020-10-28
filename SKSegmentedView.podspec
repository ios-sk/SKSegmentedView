#
#  Be sure to run `pod spec lint SKSegmentedView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|


  spec.name         = "SKSegmentedView"
  spec.version      = "1.0.0"
  spec.summary      = "分段视图"

  spec.homepage     = "https://github.com/ios-sk/SKSegmentedView.git"
  spec.license      = "MIT"
  spec.author       = { "ios-sk" => "luckysk@yeah.net" }
  spec.source       = { :git => "https://github.com/ios-sk/SKSegmentedView.git", :tag => "#{spec.version}" }
  spec.source_files  = "SKSegmentedView/*"
 
end
