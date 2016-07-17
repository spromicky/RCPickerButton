Pod::Spec.new do |s|
  s.name         = "RCPickerButton"
  s.version      = "0.1.0"
  s.summary      = "Simple button for marking some items as selected."
  s.homepage     = "https://github.com/spromicky/RCPickerButton"
  s.license      = 'MIT'
  s.author       = { "spromicky" => "spromicky@gmail.com" }
  s.source       = { :git => "https://github.com/spromicky/RCPickerButton.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'RCPickerButton/src/RCPickerButton/*'
end