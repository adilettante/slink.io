# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'SalesLinked' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
	pod 'Pageboy'
	pod 'IQKeyboardManagerSwift'
	pod 'KMPlaceholderTextView', '~> 1.3.0'
    pod 'NVActivityIndicatorView/Extended'
    pod 'SwiftHEXColors', :git => 'https://github.com/thii/SwiftHEXColors.git'
    pod 'NohanaImagePicker', '~> 0.9.0'
    pod 'Whisper'

    # Reactive Programming
    pod 'RxOptional'
    pod 'RxSwift',    '~> 4.0'
    pod 'RxCocoa',    '~> 4.0'
    pod 'RxDataSources', '~> 3.0'
    pod 'RxSwiftExt', '~> 3.0'
    pod 'RxAlamofire',  '~>  4.0'
    pod 'RxGesture', '~> 1.2'

    # Social Networks
    pod 'Fabric'
    pod 'Crashlytics'

    # Networking
    pod 'Alamofire', '~> 4.5'
    pod 'AlamofireImage', '~> 3.1'
    pod 'AlamofireNetworkActivityIndicator', '~> 2.0'
#    pod 'ObjectMapper', '~> 3.0'
    pod 'ObjectMapper', '~> 3.3.0'
    pod 'SDWebImage', '~> 4.0'

    # DB pods
#    pod 'RealmSwift',  '~> 3.1.1'
    pod 'RealmSwift', '~> 3.20.0'
    pod 'RxRealm', '~> 0.7.4'
end


target 'SalesLinkedShareExtension' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for SalesLinkedShareExtension
  pod 'Alamofire', '~> 4.5'
  pod 'RxOptional'
  pod 'RxSwift',    '~> 4.0'
  pod 'RxCocoa',    '~> 4.0'
  pod 'RxAlamofire',  '~>  4.0'
  pod 'SDWebImage', '~> 4.0'

  # DB pods
#  pod 'RealmSwift',  '~> 3.1.1'
  pod 'RealmSwift', '~> 3.20.0'
  pod 'RxRealm', '~> 0.7.4'


end


post_install do |installer|
    # Your list of targets here.
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF'] = false
        end
    end
end

