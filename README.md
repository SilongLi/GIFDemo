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


