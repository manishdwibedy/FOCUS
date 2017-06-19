/*Copyright (c) 2016, Andrew Walz.

Redistribution and use in source and binary forms, with or without modification,are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */

import UIKit

class PhotoViewController: UIViewController {

    var parentVC: EventIconViewController? = nil
    
	override var prefersStatusBarHidden: Bool {
		return true
	}

	private var backgroundImage: UIImage

	init(image: UIImage) {
		self.backgroundImage = image
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor.gray
		let backgroundImageView = UIImageView(frame: view.frame)
		backgroundImageView.contentMode = UIViewContentMode.scaleAspectFit
        
        
		backgroundImageView.image = crop(image: backgroundImage, width: Double(UIScreen.main.bounds.width), height: Double(UIScreen.main.bounds.width))
		view.addSubview(backgroundImageView)
		let cancelButton = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: 30.0, height: 30.0))
		cancelButton.setImage(#imageLiteral(resourceName: "cancel"), for: UIControlState())
		cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
		view.addSubview(cancelButton)
        
        
        let doneButton = UIButton(frame: CGRect(x: view.frame.width - 75.0, y: 10.0, width: 70.0, height: 30.0))
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)
        view.addSubview(doneButton)
	}

	func cancel() {
		dismiss(animated: true, completion: nil)
	}
    
    func crop(image: UIImage, width width: Double, height height: Double) -> UIImage? {
        
        if let cgImage = image.cgImage {
            
            let contextImage: UIImage = UIImage(cgImage: cgImage)
            
            let contextSize: CGSize = contextImage.size
            
            var posX: CGFloat = 0.0
            var posY: CGFloat = 0.0
            var cgwidth: CGFloat = CGFloat(width)
            var cgheight: CGFloat = CGFloat(height)
            
            // See what size is longer and create the center off of that
            if contextSize.width > contextSize.height {
                posX = ((contextSize.width - contextSize.height) / 2)
                posY = 0
                cgwidth = contextSize.height
                cgheight = contextSize.height
            } else {
                posX = 0
                posY = ((contextSize.height - contextSize.width) / 2)
                cgwidth = contextSize.width
                cgheight = contextSize.width
            }
            
            let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
            
            // Create bitmap image from context using the rect
            var croppedContextImage: CGImage? = nil
            if let contextImage = contextImage.cgImage {
                if let croppedImage = contextImage.cropping(to: rect) {
                    croppedContextImage = croppedImage
                }
            }
            
            // Create a new image based on the imageRef and rotate back to the original orientation
            if let croppedImage:CGImage = croppedContextImage {
                let image: UIImage = UIImage(cgImage: croppedImage, scale: image.scale, orientation: image.imageOrientation)
                return image
            }
            
        }
        
        return nil
    }

    
    func done(){
//        let _ = self.event?.saveToDB(ref: Constants.DB.event)
//        self.performSegue(withIdentifier: "event_invite", sender: nil)
        let chosenImage = backgroundImage
        let imageData = UIImagePNGRepresentation(chosenImage)
        parentVC?.imageData = imageData!
        dismiss(animated: true, completion: nil)
    }
}
