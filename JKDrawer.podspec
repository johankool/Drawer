
Pod::Spec.new do |s|

  s.name          = "JKDrawer"
  s.version       = "0.7"
 
  s.summary       = "A Maps like drawer for iOS."
  s.description   = <<-DESC
A Maps like drawer for iOS.

Features:

- control drawer size
- snap to preferred sizes
- multiple stacked drawers
- dragging and closing using gestures
- handling nested scroll views
- subtle animations
- no need to subclass view controllers
                    DESC

  s.homepage      = "https://github.com/johankool/Drawer"
  s.license       = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author        = { "Johan Kool" => "johan@egeniq.com" }

  s.ios.deployment_target = "10.0"
  s.swift_versions = ['4.2', '4.3', '5.0', '5.1']
  
  s.source        = { :git => "https://github.com/johankool/Drawer.git", :tag => "#{s.version}"  }
  s.source_files  = "Sources/JKDrawer/*.{h,swift}"
  
end
