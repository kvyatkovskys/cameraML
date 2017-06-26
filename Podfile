#Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

def pods
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxGesture'
  pod 'SnapKit'
  pod 'Gallery'
  pod 'Lightbox'
end

target 'CameraML' do
  use_frameworks!
  pods	

  target 'CameraMLTests' do
    inherit! :search_paths
    pods
  end

end
