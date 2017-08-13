//
//  UIImageView+Extensions.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/20/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import UIKit
import ImageIO

extension UIImageView {
    
    func roundedImage() {

        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true
    }
    
    func addBorder(width: CGFloat, color : UIColor){
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
    
    
    func download(urlString: String, completion: @escaping (UIImage?) -> Void) {
        if let url = URL(string: urlString) {
            let urlRequest = URLRequest(url: url)
            let urlSession = URLSession(configuration: .default)
            let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
                if error != nil {
                    print("There has been an image download error: \(String(describing: error?.localizedDescription))")
                    return
                } else {
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            if let dta = data {
                                let img = UIImage(data: dta)
                                self.image = img!
                                DispatchQueue.main.async(execute: { 
                                    completion(img)
                                })
                            }
                        } else {
                            print("The status code was not 200: \(httpResponse.statusCode)")
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    public func loadGif(name: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(name: name)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
}

extension UIImage {
    
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}
