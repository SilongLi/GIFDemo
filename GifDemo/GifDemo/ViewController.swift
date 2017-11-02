//
//  ViewController.swift
//  GifDemo
//
//  Created by lisilong on 2017/11/1.
//  Copyright © 2017年 LongShaoDream. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. 读取gif图片为data数据
        let gifData = self.loadGifInLocal(gifName: "shopping")

        // 2. 生成image图片数据
        let images = self.createImage(gifData: gifData)

        // 3. 把图片保存到本地沙盒
        self.saveImageToLocal(imageArray: images as? Array<UIImage>)
    }
}

// MARK: - actions

extension ViewController {
    
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
    
    // 将image图片保存到本地沙盒
    func saveImageToLocal(imageArray images: Array<UIImage>?) -> () {
        guard images?.count != 0 else {
            return
        }
        
        for image in images! {
            let index = images?.index(of: image)
            let imageData: Data = UIImagePNGRepresentation(image)!
            let docs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = docs[0] as String
            let imagePath = documentsDirectory + "\(index ?? 0)" + ".png"
            try? imageData.write(to: URL.init(fileURLWithPath: imagePath), options: [.atomic])
            print(imagePath)
        }
    }
}

