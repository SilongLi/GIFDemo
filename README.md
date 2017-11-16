# iOS GIF动画效果
## 一、GIF概念和特点
- 简介：
  GIF是一种常用于动画效果的图片格式。
  GIF的原义是“图像互换格式”，是CompuServe公司在1987年开发的图像文件格式，与常见的静态图像村塾格式JPG、PNG类似，GIF是一种常用于动态图片的储存的格式。
- 特点：可以通过单帧图像合成GIF或对GIF尽心单帧分解。
   
   
## 二、GIF的使用场景
- 1、GIF图片分解为单帧图片；
- 2、一系列单帧图片合成GIF图片；
- 3、iOS系统上展示GIF动画效果。
 
## 三、GIF的使用
### 1、GIF分解单帧图片
#### GIF图片分解的过程 

![GIF图片分解的过程](https://github.com/SilongLi/GifDemo/raw/master/shots/GIFDecomposeProcess.png)

##### 整个过程分为5个模块、4个过程，分别如下。
- （1）本地读取GIF图片，将其转换为NSData数据类型；
- （2）将NSData作为ImageIO模块的输入；
- （3）获取ImageIO的输出数据：UIImage;
- （4）将获取到的UIImage数据存储为JPG或PNG格式保存到本地。

> 在整个GIF图片分解的过程中，ImageIO是处理过程的核心部分。它负责对GIF文件格式进行解析，并将解析之后的数据转换为一帧帧图片输出。


#### 代码解析过程
- 读取GIF文件并将之转换为NSData类型：

~~~Swift
	/// 从本地读取gif图片 ==> 生成data数据
    func loadGifInLocal(gifName: String?) -> Data? {
        guard gifName != nil else {
            return nil
        }
        
        let gifPath = Bundle.main.path(forResource: gifName, ofType: "gif")
        guard gifPath != nil else {
            print("文件名为" + gifName! + "的gif图不存在！")
            return nil
        }
        var gifData: Data = Data.init()
        do {
            gifData = try Data.init(contentsOf: URL.init(fileURLWithPath: gifPath!))
        } catch {
            print(error)
        }
        return gifData
    }
~~~

- 利用ImageIO框架，遍历所有GIF子帧。需要注意的是使用ImageIO必须吧读取到的NSData数据换成为ImageIO可以处理的数据类型，这里使用CGImageSourceRef实现。

~~~Swift
	/// 将data图片数据转换成image
    func createImage(gifData: Data?) -> NSArray? {
        guard gifData != nil else {
            return nil
        }
        
        let gifDataSource: CGImageSource = CGImageSourceCreateWithData(gifData! as CFData, nil)!
        let gifImageCount: NSInteger = CGImageSourceGetCount(gifDataSource)
        let images: NSMutableArray   = NSMutableArray.init()
        for index in 0...gifImageCount-1 {
            let imageref: CGImage? = CGImageSourceCreateImageAtIndex(gifDataSource, index, nil)
            let image: UIImage = UIImage.init(cgImage: imageref!, scale: UIScreen.main.scale, orientation: UIImageOrientation.up)
            images.add(image)
        }
        return images
    }
~~~
>其中CGImageSourceCreateImageAtIndex方法的作用是返回GIF中其中共某一帧图像的CGImage类型数据。该方法有三个参数，参数1位GIF原始数据，参数2位GIF子帧中的序号（该序号从0开始），参数3位GIF数据提取的一些选择参数，因为这里不是很常用，所以设置为nil。
>
>其中用UIImage类的实例化方法来实例化UIImage对象，该方法有三个参数，参数1位需要构建UIImage的内容，注意这里的内容是CGImage类型，参数2为手机物理像素与手机和手机显示分辨率的换算系数，参数3标明构建的UIImage的图像方向。通过这个方法就可以在某种手机分辨率下构建指定方向的图像，当然图像的类型是UIIamge类型。

- 保存UIImage图像为png格式的图像到沙盒中

~~~Swift
	// 将image图片保存到本地沙盒
    func saveImagesToLocal(imageArray images: Array<UIImage>?) -> () {
        guard images?.count != 0 else {
            return
        }
        
        for image in images! {
            let index = images?.index(of: image)
            let imageData: Data = UIImagePNGRepresentation(image)!
            let docs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory: String = docs[0] as String
            let imagePath = documentsDirectory + "/shopping\(index ?? 0)" + ".png"
            try? imageData.write(to: URL.init(fileURLWithPath: imagePath), options: [.atomic])
            print(imagePath)
        }
    }
~~~
>其中UIImagePNGRepresentation方法将UImage数据类型存储为PNG格式的data数据类型，并保存到沙盒中。

- GIF图片分解最终实现效果  

![GIF图片分解最终实现效果](https://github.com/SilongLi/GifDemo/raw/master/shots/shppingImage.png)


## 三、PNG图片合成GIF图片

##### GIF图片的合成三步骤：
- （1）加载待处理的原始数据源；
- （2）在Document目录下构建GIF文件；
- （3）设置GIF文件属性，利用ImageIO编码GIF文件。

#### 代码实现：
~~~Swift'
// 1. 加载本地图片
    func loadImages() -> NSArray {
        let imageArray: NSMutableArray = NSMutableArray()
        for i in 1...25 {
            let image = UIImage.init(named: "refresh_gif\(i).png")
            if image != nil {
                imageArray.add(image!)
            }
        }
        return imageArray
    }
    
    // 2.创建Gif图在Document中的保存路径
    func creatGifPath() -> String {
        let docs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let gifPath = docs[0] as String + "/refresh.gif"
        print(gifPath)
        return gifPath
    }
    
    // 3.设置GIF属性，利用ImageIO编码GIF文件
    func saveGifToDocument(imageArray images: NSArray, _ gifPath: String) -> Bool {
        guard images.count > 0 &&
             gifPath.characters.count > 0 else {
            return false
        }
        let url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, gifPath as CFString, .cfurlposixPathStyle, false)
        let destion = CGImageDestinationCreateWithURL(url!, kUTTypeGIF, images.count, nil)
        
        // 设置gif图片属性
        // 设置每帧之间播放的时间0.1
        let delayTime = [kCGImagePropertyGIFDelayTime as String:0.1]
        let destDic   = [kCGImagePropertyGIFDictionary as String:delayTime]
        // 依次为gif图像对象添加每一帧属性
        for image in images {
            CGImageDestinationAddImage(destion!, (image as AnyObject).cgImage!!, destDic as CFDictionary?)
        }
        
        let propertiesDic: NSMutableDictionary = NSMutableDictionary()
        propertiesDic.setValue(kCGImagePropertyColorModelRGB, forKey: kCGImagePropertyColorModel as String)
        propertiesDic.setValue(16, forKey: kCGImagePropertyDepth as String)         // 设置图片的颜色深度
        propertiesDic.setValue(1, forKey: kCGImagePropertyGIFLoopCount as String)   // 设置Gif执行次数
        
        let gitDestDic = [kCGImagePropertyGIFDictionary as String:propertiesDic]    // 为gif图像设置属性
        CGImageDestinationSetProperties(destion!, gitDestDic as CFDictionary?)
        CGImageDestinationFinalize(destion!)
        return true
    }
~~~

需要导入 import MobileCoreServices 框架；

其中CGImageDestinationCreateWithURL方法的作用是创建一个图片的目标对象，四个参数分别代表图片的URL地址、图片类型、图片的帧数和配置信息等。



## iOS播放Gif的方式介绍
###主要三种方式：
- 使用UIImageView直接展示；
- 基于Timer定时器的逐帧动画效果；
- 基于CADisplaylink的逐帧动画效果；
- 使用WebView直接加载gif图。

~~~Swift 
    let kImagesCount: NSInteger = 24   // 图片集个数
    
    lazy var imageView: UIImageView = {
        let imageView: UIImageView = UIImageView()
        return imageView
    }()
    
    var timer: Timer?
    var displayLink: CADisplayLink?
    
    var index: NSInteger = 1 
    override func viewDidLoad() {
        super.viewDidLoad() 
        
        self.view.addSubview(imageView)
        imageView.center = self.view.center;
        imageView.bounds.size = CGSize.init(width: self.view.bounds.size.width, height: 50)
        
        // 方法一：使用UIimageView播放gif图片
//        self.showGifByUIImageView(images: self.loadImages())
        
        // 方法二：使用定时器Timer播放gif图片
//        self.showGifByTimer()
        
        // 方法三：使用CADisplayLink播放gif图片
//        self.showGifByCADisplayLink()

        // 方式四：用WebView直接加载gif图
        self.view.addSubview(self.webView)
        self.webView.frame = self.view.bounds
        self.showGifByWebView(gifName: "shopping")
    }
~~~

~~~Swift



// MARK: - 播放Gif图
extension ViewController {
    
    // 方法一：使用UIimageView播放gif图片
    func showGifByUIImageView(images: NSArray) -> () {
        if images.count > 0 {
            self.imageView.animationImages = images as? [UIImage]
            self.imageView.animationDuration = 2.0
            self.imageView.animationRepeatCount = 300
            self.imageView.startAnimating()
        }
    }
    
    // 方法二：使用定时器Timer播放gif图片
    func showGifByTimer() -> () {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(refreshImageView), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
    }
    
    // 方法三：使用CADisplayLink播放gif图片
    func showGifByCADisplayLink() -> () {
        displayLink = CADisplayLink.init(target: self, selector: #selector(refreshImageView))
        displayLink?.frameInterval = 6
        displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
    }
     
    func loadImages() -> NSArray {
        let imageArray: NSMutableArray = NSMutableArray()
        for i in 1...kImagesCount {
            let image = UIImage.init(named: "refresh_gif\(i).png")
            if image != nil {
                imageArray.add(image!)
            }
        }
        return imageArray
    }
    
    // 方式四：用WebView直接加载gif图，进行播放
    func showGifByWebView(gifName: String) -> () {
        guard gifName.characters.count > 0 else {
            return
        }
        
        let path: String = Bundle.main.path(forResource: gifName, ofType: "gif") ?? ""
        let gifData = NSData.dataWithContentsOfMappedFile(path)
        if gifData != nil {
            self.webView.load(gifData as! Data, mimeType: "image/gif", textEncodingName: "", baseURL: NSURL() as URL)
        } else {
            print("GIF图名为：" + gifName + "的图不存在！")
        }
    }
    
    @objc func refreshImageView() -> () {
        if index < 1 || index > kImagesCount {
            index = 1
        }
        let image: UIImage = UIImage.init(named: "refresh_gif\(index).png")!
        imageView.image = image
        index += 1
    }
}
~~~ 

