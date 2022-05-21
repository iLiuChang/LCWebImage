Pod::Spec.new do |s|
  s.name         = "LCWebImage"
  s.version      = "1.0.0"
  s.summary      = "一个基于AFNetworking实现的轻量级异步图片加载框架，支持内存和磁盘缓存，同时提供了自定义缓存、自定义图片解码、自定义网络配置等功能。"
  s.homepage     = "https://github.com/iLiuChang/LCWebImage"
  s.license      = "MIT"
  s.author       = "LiuChang"
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/iLiuChang/LCWebImage.git", :tag => s.version }
  s.requires_arc = true
  s.source_files = "LCWebImage/**/*.{h,m}"
  s.requires_arc = true
  s.dependency   'AFNetworking/NSURLSession', '~> 4.0'
end