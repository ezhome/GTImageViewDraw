Pod::Spec.new do |s|
  s.name             = 'GTImageViewDraw'
  s.version          = '0.1'
  s.summary          = 'This is a simple category to make your UIImageView drawable.'
  s.description      = 'This is a simple category to make your UIImageView drawable.'
  s.homepage         = 'https://github.com/gianlucatursi/GTImageViewDraw'
  s.license          = 'MIT'
  s.author           = { 'Gianluca Tursi' => 'gian.tursi@gmail.com' }
  s.social_media_url   = 'https://twitter.com/gianlucatursi'
  s.source           = { :git => 'git@github.com:ezhome/GTImageViewDraw.git', :tag => s.version.to_s }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'GTImageViewDraw/src/**/*.{h,m}'
  s.public_header_files = 'GTImageViewDraw/src/**/*.h'
end