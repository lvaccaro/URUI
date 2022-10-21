#
# Be sure to run `pod lib lint URKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'URUI'
  s.version          = '0.1.0'
  s.summary          = 'An iOS framework for encoding and decoding URs (Uniform Resources)'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
An iOS framework for encoding and decoding URs (Uniform Resources)
by Wolf McNally and Christopher Allen
                       DESC

  s.homepage         = 'https://github.com/BlockchainCommons/URUI'
  s.license          = { :type => 'BSD-2', :file => 'LICENSE.md' }
  s.author           = { 'lvaccaro' => 'me@lvaccaro.com' }
  s.source           = { :git => 'https://github.com/lvaccaro/URUI.git', :branch => 'bs' }
  s.dependency 'URKit', :git => 'https://github.com/lvaccaro/URKit', :branch => 'bs'

  s.ios.deployment_target = '13.0'

  s.source_files = 'Sources/**/*'
end
