//
//  ViewController.swift
//  IcoSnap
//
//  Created by Andres Felipe Ocampo Eljaiesk on 10/9/17.
//  Copyright © 2017 icologic. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {
    
    
    //MARK - IBOutlets
    @IBOutlet weak var myUserNameTF: UITextField!
    
    
    //MARK - IBActions
    
    @IBAction func AccessWithLoginACTION(_ sender: Any) {
        
        PFUser.logInWithUsername(inBackground: myUserNameTF.text!,
                                 password: "1234") { (userLogin, errorLogin) in
                                    if userLogin != nil{
                                        print("Acceso concedido")
                                        self.performSegue(withIdentifier: "showUsers", sender: self)
                                    }else{
                                        let user = PFUser()
                                        user.username = self.myUserNameTF.text!
                                        user.password = "1234"
                                        
                                        user.signUpInBackground(block: { (succesSignup, errorSignup) in
                                            if errorSignup == nil{
                                                print("Usuario creado")
                                                self.performSegue(withIdentifier: "showUsers", sender: self)
                                            }else{
                                                print(errorSignup?.localizedDescription as Any)
                                            }
                                        })
                                        
                                    }
        }
        
        
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if PFUser.current() != nil{
            self.performSegue(withIdentifier: "showUsers", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK - Utils
    @IBAction func logoutICoSnap(_ segue: UIStoryboardSegue){
        print("Logout exitoso")
    }
    
    


}

