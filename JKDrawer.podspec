
Pod::Spec.new do |s|

  s.name          = "JKDrawer"
  s.version       = "0.6.0"
 
  s.summary       = "A Maps like drawer for iOS."
  s.description   = <<-DESC
                    A Maps like drawer for iOS.
                    DESC

  s.homepage      = "https://github.com/johankool/Drawer"
  s.license       = "MIT"
  s.author        = { "Johan Kool" => "johan@egeniq.com" }

  s.ios.deployment_target = "10.0"
  s.swift_version = '4.2'
  
  s.source        = { :git => "https://github.com/johankool/Drawer.git", :tag => "#{s.version}"  }
  s.source_files  = "Sources/JKDrawer/*.{h,swift}"
  
end
