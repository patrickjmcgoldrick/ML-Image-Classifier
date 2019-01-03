//
//  ViewController.swift
//  ML Image Classifier
//
//  Created by dirtbag on 1/3/19.
//  Copyright © 2019 dirtbag. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblConfidence: UILabel!
    @IBOutlet weak var lblClassification: UILabel!
    
    let imagePicker = UIImagePickerController()
    
    let resnetModel = Resnet50()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        if let image = imageView.image {
            processImage(image: image)
        }
    }
    
    func processImage(image: UIImage) {
        
        if let model = try? VNCoreMLModel(for: self.resnetModel.model) {
            let request = VNCoreMLRequest(model: model) { (request, error) in
                if let results = request.results as? [VNClassificationObservation] {
                    for classification in results {
                        print("ID: \(classification.identifier) Confidence: \(classification.confidence)")
                    }
                    
                    if let observation = results.first {
                        self.lblClassification.text = observation.identifier
                        let confidence = round(observation.confidence * 1000.0) / 10.0
                        self.lblConfidence.text = "\(confidence)%"
                    }
                }
                
            }
            
            if let imageData = image.pngData() {
                let handler = VNImageRequestHandler(data: imageData, options: [:])
                try? handler.perform([request])
                
            }
            
        }
        
    }
    
    
    @IBAction func actionTakePhoto(_ sender: Any) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func actionFindImages(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = selectedImage
            processImage(image: selectedImage)
        }
        dismiss(animated: true, completion: nil)
    }
}

