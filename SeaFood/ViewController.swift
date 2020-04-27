//
//  ViewController.swift
//  SeaFood
//
//  Created by Imanol Bernal on 27/04/2020.
//  Copyright © 2020 Imanol Bernal. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        //imagePicker.sourceType = .photoLibrary
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
    }
    // Button presenting the camera view controller
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    // Delegate method that detects when the user finish then creates a UImage and converts to CIImage to process it in CoreML.
    // It is then passed on to the detect function
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
        
            imageView.image = image
            
            // CoreML requires an CIImage
            
            guard let ciimage = CIImage(image: image) else {
                fatalError("Could not convert to CIImage")
            }
            detect(image: ciimage)
            
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    // CoreML. Create a model from the Incepcionv3 model. Create a request for that model and a handler to make that request.
    // When the handler finishes making the request It saves the results of that request in results that are an array of
    // VNClassificationObservation. With the first result I search for the hotdog String and then I change the title of the navigation
    // This is the first result with a photo of a computer keyboard. You can see the confidence, the first result has the most confidence.

    // <VNClassificationObservation: 0x2819f2250> E898D096-FD60-4DF4-B664-ABCB8633DBE5 requestRevision=1 confidence=0.695266 "computer keyboard, keypad"
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML model Failed")
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model Failed to process image")
            }
            print(results)
            
            // Once I have the array with the results I check if the first one is a hotdog
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "HotDog!"
                } else {
                    self.navigationItem.title = "Not HogDog!"
                }
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    


    
}

