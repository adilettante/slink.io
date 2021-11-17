//
//  BaseViewController.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 9/28/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController {

    let disposeBag = DisposeBag()
    let errorTitle = "Something went wrong"
    internal let deleteMessage = "This card and its information will be erased. Do you wish to continue?"

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
    }

    func setTitleImage() {
        let logo = UIImage(named: "ic_chains")
        let imageView = UIImageView(image: logo)
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
    }

    func setNavigationBar() {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 246/255, green: 245/255, blue: 241/255, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor(red: 103/255, green: 102/255, blue: 98/255, alpha: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showErrorAlert(message: String) {
        showAlert(title: errorTitle, message: message)
    }

    func showNoInternetAlert() {
        showErrorAlert(message: "There is no internet connection.")
    }

    func showUnAutorizedAlert() {
        showErrorAlert(message: "Please close the app and run again.")
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func showYesNoAlert(
        message: String,
        yesBtnMessage: String,
        noBtnMessage: String,
        yesAction: @escaping (UIAlertAction?) -> Void,
        noAction: @escaping (UIAlertAction?) -> Void
        ) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: yesBtnMessage, style: UIAlertActionStyle.default, handler: yesAction))
        alert.addAction(UIAlertAction(title: noBtnMessage, style: UIAlertActionStyle.default, handler: noAction))
        self.present(alert, animated: true, completion: nil)
    }
}
