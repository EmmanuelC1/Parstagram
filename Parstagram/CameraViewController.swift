//
//  CameraViewController.swift
//  Parstagram
//
//  Created by Emmanuel Castillo on 2/26/20.
//  Copyright © 2020 Emmanuel Castillo. All rights reserved.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        //Create table called Posts
        let post = PFObject(className: "Posts")
        
        //Set Columns Caption and Author to have the values of the commentField and the User that is logged in
        post["caption"] = commentField.text!
        post["author"] = PFUser.current()!
        
        //Get imageData from image selected by user and make a PFFileObject
        let imageData = imageView.image!.pngData()
        let file = PFFileObject(name:"image.png", data: imageData!)
        
        //Make Image column in table and add image file url
        post["image"] = file
        
        //Dismiss view if post saved succesfully, otherwise print error message
        post.saveInBackground { (success, error) in
            if(success) {
                self.dismiss(animated: true, completion: nil)
                print("Saved post successfully.")
            }
            else {
                print("Error: Saving post >> \(error?.localizedDescription)")
            }
        }
        
        
    }
    
    @IBAction func onCameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        //If camera is available, then open camera, otherwise show Photo Library
        if(UIImagePickerController.isSourceTypeAvailable(.camera)) {
            picker.sourceType = .camera
        }
        else {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //Get image from imagePicker
        let image = info[.editedImage] as! UIImage
        
        //Scale image to 300x300 and store it in scaledImage variable
        let size = CGSize(width: 300, height: 300)
        let scaledimage = image.af_imageScaled(to: size)
        
        //Put scaledImage in imageView
        imageView.image = scaledimage
        
        //Dismiss camera view
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
