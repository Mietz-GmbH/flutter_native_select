#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_native_select.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_native_select'
  s.version          = '0.0.1'
  s.summary          = 'A flutter plugin which can open a native select box.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://mietz.app/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Maximilian Schelbach' => 'maximilian@mietz.app' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
