Pod::Spec.new do |s|
  s.name     = 'RSWebView'
  s.version  = '1.0.1'
  s.platform = :ios, '7.0'
  s.license  = 'MIT'
  s.summary  = 'UIWebView switched automatically into WKWebView'
  s.homepage = 'https://github.com/air1120/RSWebView'
  s.author   = { 'RasonWu' => 'wlww9@163.com' }
  s.source   = { :git => 'https://github.com/air1120/RSWebView.git', :tag => "#{s.version}" }
  s.requires_arc = true
s.ios.deployment_target = '7.0'
s.ios.frameworks = 'WebKit'
s.description  = 'UIWebView switched automatically into WKWebView.'
s.source_files = 'RSWebView/RSWebView/RSWebView/*','RSWebView/RSWebView/RSWebView/Third/NJKWebViewProgress/*','RSWebView/RSWebView/RSWebView/Third/WebViewJavascriptBridge/*'
sp.resources = 'RSWebView/*.{lproj}'
end
