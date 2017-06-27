//
//  ViewController.swift
//  FIRImagePicker
//
//  Created by User01 on 27/06/17.
//  Copyright © 2017 User01. All rights reserved.
//

import UIKit
import MobileCoreServices
import Foundation
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func uploadButtonWasPressed(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func uploadImageToFirebaseStorage(data: NSData) {
        let storageRef = Storage.storage().reference(withPath: "myPics/demoPic.jpg")
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        let uploadTask = storageRef.putData(data as Data, metadata: uploadMetadata) { (metadata, error) in
            if (error != nil) {
                print("I received an error! \(error?.localizedDescription)")
            } else {
                print("Upload complete! \(metadata)")
                print("Download URL \(metadata?.downloadURL())")
            }
        }
        uploadTask.observe(.progress) { [weak self] (snapshot) in
            guard let strongSelf = self else { return }
            guard let progress = snapshot.progress else { return }
            strongSelf.progressBar.progress = Float(progress.fractionCompleted)
            
        }
        
    }
    
    func uploadMovieToFirebaseStorage(url: NSURL) {
        let storageRef = Storage.storage().reference(withPath: "myMovies/demoMovie.mov")
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "video/quicktime"
        let uploadTask = storageRef.putFile(from: url as URL, metadata: uploadMetadata) { (metadata, error) in
            if (error != nil) {
                print("I received an error! \(error?.localizedDescription)")
            } else {
                print("Upload complete! \(metadata)")
                print("Download URL \(metadata?.downloadURL())")
            }
            
        }
        uploadTask.observe(.progress) { [weak self] (snapshot) in
            guard let strongSelf = self else { return }
            guard let progress = snapshot.progress else { return }
            strongSelf.progressBar.progress = Float(progress.fractionCompleted)
            print("Uploaded \(progress.completedUnitCount) so far")
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let mediaType: String = info[UIImagePickerControllerMediaType] as? String else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        //User selects an image
        if mediaType == (kUTTypeImage as String) {
            if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage, let imageData = UIImageJPEGRepresentation(originalImage, 0.8) {
                uploadImageToFirebaseStorage(data: imageData as NSData)
            }
            
        //User selects a movie
        } else if mediaType == (kUTTypeMovie as String) {
            if let movie = info[UIImagePickerControllerMediaURL] as? NSURL {
                uploadMovieToFirebaseStorage(url: movie)
            }
        }
        dismiss(animated: true, completion: nil)
    }
}

