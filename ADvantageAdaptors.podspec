Pod::Spec.new do |s|
  s.name       = 'ADvantageAdaptors'
  s.version    = '1.0.0'
  s.license = {
      :type => 'BSD',
      :file => 'LICENSE'
  }
  s.platform   = :ios
  s.requires_arc = true
  s.summary    = 'ADvantage Adaptors - the innovative, rich media mobile advertising platform.'
  s.homepage   = "http://docs.advantage-adsolution.com/"
  s.license    = "All rights reserved."
  s.author     = {
      'Digitalsunray Media GmbH' => 'advantage@digitalsunray.com'
  }
  s.source     = {
      :git => 'https://github.com/DsrMedia/Advantage-sdk-adaptors-ios/raw/master/AdvantageAdaptors.zip'
  }
  s.source_files = 'AdvantageAdaptors.framework/Headers/*.h'
  s.exclude_files = 'AdvantageAdaptors.framework/*.plist'
  s.ios.deployment_target = '12.0'
  s.ios.vendored_framework = 'AdvantageAdaptors.framework'
end
