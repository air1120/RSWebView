function setupWebViewJavascriptBridge(callback) {
    if (window.WebViewJavascriptBridge) { return callback(WebViewJavascriptBridge); }
    if (window.WVJBCallbacks) { return window.WVJBCallbacks.push(callback); }
    window.WVJBCallbacks = [callback];
    var WVJBIframe = document.createElement('iframe');
    WVJBIframe.style.display = 'none';
    WVJBIframe.src = 'wvjbscheme://__BRIDGE_LOADED__';
    document.documentElement.appendChild(WVJBIframe);
    setTimeout(function() { document.documentElement.removeChild(WVJBIframe) }, 0)
}
var bridge ;

setupWebViewJavascriptBridge(function(bridge2) {
                             alert("setupWebViewJavascriptBridge加载成功，现在可以进行注册和调用");
                             /* Initialize your app here */
                             bridge = bridge2;
                             bridge.registerHandler('JS Echo', function(data, responseCallback) {
                                                    console.log("JS Echo called with:", data)
                                                    alert("JS received response:"+data);

                                                    responseCallback(data)
                                                    })
                             
                             })
function testEcho(){
    bridge.callHandler('ObjC Echo','数据啦', function responseCallback(responseData) {
                       console.log("JS received response:", responseData)
                       alert("JS received response:"+responseData);
                       bridge.callHandler('ObjC Echo','数据啦2222');
                       
                       })
}


