#
# Be sure to run `pod lib lint RJBadgeKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RJBadgeKit'
  s.version          = '0.2.5'
  s.summary          = 'Red dot (version/message reminder) display and its management.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A complete and lightweight solution for red dot (version/message reminder) display and its management.
                       DESC

  s.homepage         = 'https://github.com/RylanJIN/RJBadgeKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ryan Jin' => 'xiaojun.jin@outlook.com' }
  s.source           = { :git => 'https://github.com/RylanJIN/RJBadgeKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'RJBadgeKit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'RJBadgeKit' => ['RJBadgeKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
