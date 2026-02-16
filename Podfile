# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

flutter_application_path = '../movies_module'
load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')

target 'Movies-IOS' do
  install_all_flutter_pods(flutter_application_path)
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Movies-IOS

  target 'Movies-IOSTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'Movies-IOSUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  flutter_post_install(installer) if defined?(flutter_post_install)
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
    end
  end
end