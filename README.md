# SHRequestFileManage
SHRequestFileManage
iOS填坑之2 - 如何工具化自己的开发之路，如何深入，更加深入

跟上一篇文章文章[iOS填坑之1 - 项目越做越大，如何更加规范化管理](https://www.jianshu.com/p/b244cdb99225)
对于工具化的深思
因为接口太多，而且有某些接口需要的参数太多，每一个接口去对接，修改，耗费的精力特别大，重复性的工作可以用工具来代替。
![请求封装.001.jpeg](http://upload-images.jianshu.io/upload_images/693139-13de36b5cc78dd2c.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
####MTRequestFileManage设计原因和思路
创建MTRequestFileManage的原因
        查看以往的项目案例，不难发现请求类都是通过AFN的POST与GET请求进行传输，麦麦项目为了更好地统一管理网络请求，在AFN之上封装了MTHttpRequest_Helper进行网络请求的统一管理
        根据MTHttpRequest_Helper暴露出来的请求接口，然后在具体的请求类里面进行调用。  
        请求类由统一格式调用，传入规定好的参数信息，当成功返回Success的obj；当请求失败返回失败的obj;当网络信息错误返回网络信息错误的obj。
![请求封装.002.jpeg](http://upload-images.jianshu.io/upload_images/693139-88f01e9a1d7de73f.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

####创建MTRequestURL的原因
        按照统一的规则有效的将RequestURL拆分，将url拆分为三个部分
1>BASEURL 例如：192.168.0.1:8080/webserver/Verson/ProgectName
2>URL 例如：/requestName/demo
将URL拆分为两部分
1>ParentNode - requestName
2>ChildNode   - demo
根据规则拼接为
![请求封装.003.jpeg](http://upload-images.jianshu.io/upload_images/693139-f1e19e8058e27a48.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

####创建MTRequestURL模板样式
目前没有查找到关于Mac直接读取EXCEL方法，此处有待改进，下一步优化可以直接读取EXCEL就更好了
![请求封装.004.jpeg](http://upload-images.jianshu.io/upload_images/693139-9dcd959b502a8fbc.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

####对接URL的样式
![请求封装.005.jpeg](http://upload-images.jianshu.io/upload_images/693139-5f8978cae72cd9c0.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

####对接Request样式
![请求封装.006.jpeg](http://upload-images.jianshu.io/upload_images/693139-cba0ed9a158d9747.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![请求封装.007.jpeg](http://upload-images.jianshu.io/upload_images/693139-c5359cbd5e66cc92.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![请求封装.008.jpeg](http://upload-images.jianshu.io/upload_images/693139-7c10a627731cc532.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![请求封装.009.jpeg](http://upload-images.jianshu.io/upload_images/693139-821650f3bf39e8cb.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

