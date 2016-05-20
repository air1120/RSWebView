Pod::Spec.new do |s|
  s.name     = 'RSWebView'
  s.version  = '1.1.3'
  s.platform = :ios, '7.0'
  s.license  = 'MIT'
  s.summary  = 'UIWebView switched automatically into WKWebView'
  s.homepage = 'https://github.com/air1120/RSWebView'
  s.author   = { 'RasonWu' => 'wlww9@163.com' }
  s.source   = { :git => 'https://github.com/air1120/RSWebView.git', :tag => "#{s.version}" }
  s.requires_arc = true
s.ios.deployment_target = '7.0'
s.ios.weak_frameworks = 'WebKit'
s.description  = 'UIWebView switched automatically into WKWebView.'
s.source_files = 'RSWebView/*.{h,m}','RSWebView/Third/NJKWebViewProgress/*.{h,m}','RSWebView/Third/WebViewJavascriptBridge/*.{h,m}'
s.resources = 'RSWebView/*.{js,lproj}'
end
