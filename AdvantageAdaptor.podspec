Pod::Spec.new do |s|
  s.name       = 'ADvantage Adaptors'
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
      :http => 'https://github.com/DsrMedia/Advantage-SDK-ios/raw/master/Advantage.zip'
  }
  s.source_files = 'AdvantageAdaptor.framework/Headers/*.h'
  s.exclude_files = 'AdvantageAdaptor.framework/*.plist'
  s.ios.deployment_target = '12.0'
  s.ios.vendored_framework = 'AdvantageAdaptor.framework'
end
