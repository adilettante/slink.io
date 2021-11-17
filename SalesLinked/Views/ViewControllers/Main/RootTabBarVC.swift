//
//  RootTabBarVC.swift
//  SalesLinked
//
//  Created by STDev Mac on 6/23/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NohanaImagePicker
import NVActivityIndicatorView
import Photos

class RootTabBarVC: UITabBarController,
    UITabBarControllerDelegate,
    UINavigationControllerDelegate,
UIImagePickerControllerDelegate {

    private let disposeBag = DisposeBag()
    private var backgroundWorkScheduler: OperationQueueScheduler {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 5
        #if !RX_NO_MODULE
            operationQueue.qualityOfService = QualityOfService.userInitiated
        #endif
        return OperationQueueScheduler(operationQueue: operationQueue)
    }
    // MARK: - Variables
    var imagePicker: UIImagePickerController!

    public static var newItemsExists = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
    }

    func showActionSheet() {
        self.selectedIndex = 0
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Camera Roll", style: .default, handler: { (_) -> Void in
            self.photoLibrary()
        })
        let saveAction = UIAlertAction(title: "Take Photo", style: .default, handler: { (_) -> Void in
            self.camera()
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) -> Void in
        })
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }

    // MARK: - UITabBarDelegate
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 1 {
            self.showActionSheet()
        }
    }

    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {

        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        self.dismiss(animated: true) { [weak self] in
            self?.showBusinessCardVC(image: image)
        }
    }

    private func showBusinessCardVC(image: UIImage) {
        guard let vc = SegueHelper.get(
            BusinessCardImportVC.self,
            viewController: "BusinessCardImportVC",
            in: .BusinessCardImport) else { return }
        vc.importedImage = image
        let navController = UINavigationController(rootViewController: vc)
        self.present(navController, animated: true, completion: nil)
    }

    // MARK: - Configuration Prepering  Photo librery
    func camera() {
        checkConnection(to: .camera) { [weak self] in
            guard let strongSelf = self else { return }
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = strongSelf
            myPickerController.sourceType = UIImagePickerControllerSourceType.camera
            strongSelf.present(myPickerController, animated: true, completion: nil)
        }
    }

    func photoLibrary() {
        checkConnection(to: .photoLibrary) { [weak self] in
            guard let strongSelf = self else { return }
            let picker = NohanaImagePickerController()
            picker.delegate = strongSelf
            picker.toolbarHidden = true
            picker.maximumNumberOfSelection = 5
            strongSelf.present(picker, animated: true, completion: nil)
        }
    }

    // MARK: - UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return !viewController.isKind(of: TakePhotoVC.self)
    }

    func checkConnection(to: UIImagePickerControllerSourceType, complition: @escaping () -> Void) {
        if UIImagePickerController.isSourceTypeAvailable(to) {
            complition()
        } else {
            let text = "Device has no \(to == .camera ? "camera" : "photoLibrary") connection."
            let alertController = UIAlertController(title: "Oops!", message: text, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: {_ in })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension RootTabBarVC: NohanaImagePickerControllerDelegate {

    func nohanaImagePickerDidCancel(_ picker: NohanaImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func nohanaImagePicker(_ picker: NohanaImagePickerController, didFinishPickingPhotoKitAssets pickedAssts: [PHAsset]) {
        picker.dismiss(animated: true) { [weak self] in
            guard let strongSelf = self else { return }
            if pickedAssts.count == 1, let asset = pickedAssts.first {
                strongSelf.rxGetAssetThumbnail(asset: asset)
                    .filterNil()
                    .subscribe(onNext: { [weak self] image in
                        self?.showBusinessCardVC(image: image)
                    })
                    .disposed(by: strongSelf.disposeBag)
            } else {
                RootTabBarVC.newItemsExists = true
                strongSelf.multipleItemsUploaded(assets: pickedAssts)
            }
        }
    }

    func rxGetAssetThumbnail(asset: PHAsset) -> Observable<UIImage?> {
        return Observable.create { observer in
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            option.isSynchronous = true
            option.isNetworkAccessAllowed = true
            let requestedId = manager.requestImage(
                for: asset,
                targetSize: CGSize(
                    width: asset.pixelWidth,
                    height: asset.pixelHeight
                ),
                contentMode: .aspectFit,
                options: option,
                resultHandler: { (result, _) -> Void in
                    observer.onNext(result)
                    observer.onCompleted()
            })
            return Disposables.create {
                manager.cancelImageRequest(requestedId)
            }
        }
    }

    func multipleItemsUploaded(assets: [PHAsset]) {
        Observable
            .from(assets)
            .flatMap(rxGetAssetThumbnail)
            .filterNil()
            .subscribeOn(backgroundWorkScheduler)
            .map { UIImageJPEGRepresentation($0, 0.7)?.saveDataAsImage(resizeImage: true, folderName: imagesFolderName) }
            .filterNil()
            .toArray()
            .map {
                $0.map {
                    BusinessCardInfo(
                        image: $0.original.absoluteString,
                        thumbnail: $0.thumbnail?.absoluteString
                    )
                }
            }
            .observeOn(MainScheduler.instance)
            .subscribe(RealmService.shared.realm.rx.add())
            .disposed(by: disposeBag)

    }
}
