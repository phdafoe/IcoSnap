//
//  ICOUserTableViewController.swift
//  IcoSnap
//
//  Created by Andres Felipe Ocampo Eljaiesk on 10/9/17.
//  Copyright © 2017 icologic. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import PKHUD

class ICOUserTableViewController: UITableViewController {
    
    
    //MARK - variables globales
    var userArray : [String] = []
    var customTimer = Timer()
    var grupoImagenes = 1
    
    
    
    //MARK - IBActions
    @IBAction func logoutICOSnap(_ sender: Any) {
        PFUser.logOutInBackground { (errorLogout) in
            if errorLogout == nil{
                self.performSegue(withIdentifier: "logout", sender: self)
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        loadDataFromParse()
        timer()
        self.title = PFUser.current()?.username
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        customTimer.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = userArray[indexPath.row]

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        loadPickerController()
    }
    


    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            //tableView.deleteRows(at: [indexPath], with: .fade)
            let queryDelete = PFUser.query()
            queryDelete?.whereKey("username", notEqualTo: (PFUser.current()?.username)!)
            queryDelete?.findObjectsInBackground(block: { (objectDelete, errorDelete) in
                if errorDelete == nil{
                    if let objectDeleteDes = objectDelete{
                        for object in objectDeleteDes{
                            object.deleteInBackground(block: nil)
                            self.tableView.reloadData()
                        }
                    }
                }else{
                    print("Error: \(String(describing: errorDelete?.localizedDescription))")
                }
            })
        }
    }
    

    
    //MARK - Utils
    func loadDataFromParse(){
        let queryUser = PFUser.query()
        queryUser?.whereKey("username", notEqualTo: (PFUser.current()?.username)!)
        HUD.show(.progress)
        queryUser?.findObjectsInBackground(block: { (userData, errorData) in
            if errorData == nil{
                if let userDataDes = userData {
                        for item in userDataDes {
                        print(item["username"] as! String)
                        self.userArray.append(item["username"] as! String)
                        self.tableView.reloadData()
                        HUD.hide(afterDelay: 0)
                    }
                }
            }
        })
        self.tableView.reloadData()
    }
    
    
    func timer(){
        customTimer = Timer.scheduledTimer(timeInterval: 5,target: self,selector: #selector(self.checkMessage),userInfo: nil,repeats: true)
    }
    
    func checkMessage(){
        let queryImage = PFQuery(className: "ImageSnap")
        queryImage.whereKey("recipientUserName", equalTo: (PFUser.current()?.username)!)
        queryImage.findObjectsInBackground { (imageData, errorData) in
            if errorData == nil{
                if let imageDataDes = imageData{
                    for item in imageDataDes{
                        let senderUsername = item["username"] as! String
                        //print("Hay un mensaje de parte de \(senderUsername)")
                        let imageView = PFImageView()
                        imageView.file = item["image"] as? PFFile
                        imageView.load(inBackground: { (imageData, errorData) in
                            if errorData == nil{
                                
                                let alertVC = UIAlertController(title: "Tienes un mensaje", message: "Mensaje de \(senderUsername)",preferredStyle: .alert)
                                alertVC.addAction(UIAlertAction(title: "OK",style: .default,handler: { _ in
                                                                    
                                                                    let background = UIView(frame: CGRect(x: 0,y: 0,width: self.view.frame.width, height: self.view.frame.height))
                                    
                                                                    background.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                                                                    background.alpha = 0.5
                                                                    background.tag = self.grupoImagenes
                                                                    self.view.addSubview(background)
                                    
                                                                    let displayImage = UIImageView(frame: CGRect(x: 0,y: 0,width: self.view.frame.width,height: self.view.frame.height))
                                    
                                                                    displayImage.image = imageData
                                                                    displayImage.contentMode = .scaleAspectFit
                                                                    displayImage.tag = self.grupoImagenes
                                                                    self.view.addSubview(displayImage)
                                                                    
                                                                    self.customTimer = Timer.scheduledTimer(timeInterval: 5,target: self,selector: #selector(self.hideImage),userInfo: nil,repeats: false)
                                }))
                                self.present(alertVC,animated: true,completion: nil)
                            }
                        })
                        //Aqui eliminamos de parse
                        item.deleteInBackground(block: { (exitoso, error) in
                            if error == nil{
                                print("Imagen borrada")
                            }
                        })
                    }
                }
            }
        }
    }
    
    
    func hideImage(){
        for c_subvista in self.view.subviews{
            if c_subvista.tag == grupoImagenes{
                c_subvista.removeFromSuperview()
            }
        }
    }
    

}


//MARK: - EXTENSION
extension ICOUserTableViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func loadPickerController(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            muestraMenu()
        }else{
            muestraLibreria()
        }
    }
    
    func muestraMenu(){
        let menuVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        menuVC.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        menuVC.addAction(UIAlertAction(title: "Camara de Fotos", style: .default, handler: { Void in
            self.muestraCamaraFotos()
        }))
        menuVC.addAction(UIAlertAction(title: "Libreria de Fotos", style: .default, handler: { Void in
            self.muestraLibreria()
        }))
        present(menuVC, animated: true, completion: nil)
    }
    
    
    func muestraLibreria(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func muestraCamaraFotos(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let imageData = info[UIImagePickerControllerOriginalImage] as? UIImage{
           
            let imageSaveInParse = PFObject(className: "ImageSnap")
            imageSaveInParse["image"] = PFFile(name: "imagejpg", data: UIImageJPEGRepresentation(imageData, 0.3)!)
            imageSaveInParse["username"] = PFUser.current()?.username
            
            //aqui a quien le envio
            let recipientUsername = self.userArray[(self.tableView.indexPathForSelectedRow?.row)!]
            imageSaveInParse["recipientUserName"] = recipientUsername
            
            imageSaveInParse.saveInBackground(block: { (exitoso, error) in
                if error == nil{
                    print("TODO OK")
                }else{
                    print("OOPS")
                }
            })
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
}






