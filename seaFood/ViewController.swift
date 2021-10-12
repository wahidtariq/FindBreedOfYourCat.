//
//  ViewController.swift
//  seaFood
//
//  Created by wahid tariq on 08/10/21.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBOutlet var breedTextField: UILabel!
    @IBOutlet var imageView: UIImageView!
    let picker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = UIImage(systemName: "pawprint.circle.fill")

        title = "Breed"
        picker.delegate = self
        picker.sourceType = .photoLibrary
//        picker.sourceType = .camera
        picker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let userPickedimage = info[.originalImage] as? UIImage else{ fatalError("no image found.") }
        imageView.alpha = 0.0
        imageView.image = userPickedimage
        UIView.animate(withDuration: 1, delay: 0, options: .transitionFlipFromLeft, animations: {
            self.imageView.alpha = 1.0
        }, completion: nil)
        guard let ciimage = CIImage(image: userPickedimage) else {fatalError("unable to convert uiimage to ciimage ")}
        detect(image: ciimage)
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func detect(image: CIImage){

        guard let model = try? VNCoreMLModel(for: MLModel(contentsOf: Inceptionv3.urlOfModelInThisBundle)) else {
            fatalError("can't load ML model")
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else{fatalError("model failed to process image")}
            if let firstResult = results.first{
                if firstResult.identifier.contains("cat"){
                    self.navigationController?.navigationBar.backgroundColor = UIColor.clear
                    self.breedTextField.text = firstResult.identifier
                }else{
                    self.breedTextField.text = "Not a Cat."
                    self.navigationController?.navigationBar.backgroundColor = UIColor.red
                }
            }            
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do{
            try handler.perform([request])
        }       catch{
            print(error)
        }
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        present(picker, animated: true, completion: nil)
        
    }
    
    
    
    
}

