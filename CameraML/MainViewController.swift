//
//  MainViewController.swift
//  CameraML
//
//  Created by Kviatkovskii on 26.06.17.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import UIKit
import Photos
import SnapKit
import CoreML
//import RxSwift
//import RxCocoa
//import Lightbox

final class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LookPhotoLibraryDelegate {
    fileprivate let router: Router
    //fileprivate let disposeBag = DisposeBag()
    fileprivate let cameraController = CameraController()
    fileprivate let inceptionModel = Inceptionv3()
    
    // пикер для галереи
    fileprivate let imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        return picker
    }()
    
    // выбранное или сфотографированно еизображение
    fileprivate let capturePhoto: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    fileprivate let answerFromMLLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.fontBold19
        label.numberOfLines = 0
        label.textColor = UIColor.white
        return label
    }()
    
    fileprivate let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.textColor = UIColor.white
        button.titleLabel?.font = UIFont.font17
        return button
    }()
    
    // фон заблюренный
    fileprivate lazy var blurView: UIView = {
        let view = UIView()
        view.isHidden = true
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, aboveSubview: self.capturePhoto)
        return view
    }()
    
    // кнопка сделать снимок
    fileprivate let captureButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0))
        button.backgroundColor = UIColor.white
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = min(button.frame.width, button.frame.height) / 2
        return button
    }()
    
    ///вью отображающая, то что видит камера
    fileprivate let capturePreviewView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray
        return view
    }()
    
    // для открытия галереи
    fileprivate let openLibraryButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0))
        return button
    }()
    
    // кнопка смены фронт/основаная камера
    fileprivate let toggleCameraButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 25.0, height: 25.0))
        let image = #imageLiteral(resourceName: "ic_switch_camera").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(white: 1.0, alpha: 1.0)
        return button
    }()
    
    // вкл/выкл вспышку
    fileprivate let toggleFlashButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 25.0, height: 25.0))
        let image = #imageLiteral(resourceName: "ic_flash_off").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(white: 1.0, alpha: 1.0)
        return button
    }()
        
    fileprivate func updateConstraints() {
        capturePreviewView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        
        blurView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        
        capturePhoto.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: view.frame.size.width - 40.0, height: view.frame.size.height / 2))
            make.center.equalToSuperview()
        }
        
        answerFromMLLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(capturePhoto)
            make.bottom.equalTo(capturePhoto.snp.top).offset(-20.0)
        }
        
        cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(capturePhoto.snp.bottom).offset(30.0)
            make.left.right.equalTo(capturePhoto)
        }
        
        captureButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 50.0, height: 50.0))
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-25.0)
        }
        
        openLibraryButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 40.0, height: 40.0))
            make.centerY.equalTo(captureButton)
            make.left.equalToSuperview().offset(15.0)
        }
        
        toggleCameraButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 25.0, height: 25.0))
            make.centerY.equalTo(captureButton)
            make.right.equalToSuperview().offset(-15.0)
        }
        
        toggleFlashButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 25.0, height: 25.0))
            make.centerX.equalTo(toggleCameraButton)
            make.right.equalTo(toggleCameraButton)
            make.bottom.equalTo(toggleCameraButton.snp.top).offset(-20.0)
        }
        
        super.updateViewConstraints()
    }
    
    init(router: Router) {
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getLastPhotoFromLibrary()
        imagePicker.delegate = self
        
        self.view.addSubview(capturePreviewView)
        self.view.addSubview(blurView)
        blurView.addSubview(capturePhoto)
        blurView.addSubview(answerFromMLLabel)
        blurView.addSubview(cancelButton)
        capturePreviewView.addSubview(captureButton)
        capturePreviewView.addSubview(openLibraryButton)
        capturePreviewView.addSubview(toggleCameraButton)
        capturePreviewView.addSubview(toggleFlashButton)
        
        updateConstraints()
        
        configureCameraController()
        
        captureButton.addTarget(self, action: #selector(captureImage), for: .touchUpInside)
        toggleCameraButton.addTarget(self, action: #selector(switchCameras), for: .touchUpInside)
        toggleFlashButton.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        openLibraryButton.addTarget(self, action: #selector(openLibrary), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(hideBlueView), for: .touchUpInside)
        
//        captureButton.rx.tap.asDriver()
//            .drive(onNext: { [unowned self] _ in
//                self.captureImage()
//            }).addDisposableTo(disposeBag)
//
//        toggleCameraButton.rx.tap.asDriver()
//            .drive(onNext: { [unowned self] _ in
//                self.switchCameras()
//            }).addDisposableTo(disposeBag)
//
//        toggleFlashButton.rx.tap.asDriver()
//            .drive(onNext: { [unowned self] _ in
//                self.toggleFlash()
//            }).addDisposableTo(disposeBag)
//
//        openLibraryButton.rx.tap.asDriver()
//            .drive(onNext: { [unowned self] _ in
//                self.present(self.imagePicker, animated: true, completion: nil)
//            }).addDisposableTo(disposeBag)
//
//        cancelButton.rx.tap.asDriver()
//            .drive(onNext: { [unowned self] _ in
//                self.blurView.isHidden = true
//            }).addDisposableTo(disposeBag)
    }
    
    func openLibrary() {
        present(self.imagePicker, animated: true, completion: nil)
    }
    
    func hideBlueView() {
        blurView.isHidden = true
    }
    
    // MARK: - Delegates Picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            router.showLookPhotoLibrary(controller: picker, image: chosenImage, delegate: self)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func choosePhoto(image: UIImage) {
        setAnalazyPhoto(image: image)
        imagePicker.popToRootViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
        DispatchQueue.main.async { [unowned self] _ in
            self.classifierImage(image: image)
        }
    }
    
    // MARK: - Camera Controller
    func configureCameraController() {
        cameraController.flashMode = .off
        cameraController.prepare { (error) in
            if let error = error {
                print(error)
            }
            
            try? self.cameraController.displayPreview(on: self.capturePreviewView)
        }
    }
    
    // переключаем вспышку
    func toggleFlash() {
        if cameraController.flashMode == .on {
            cameraController.flashMode = .off
            let image = #imageLiteral(resourceName: "ic_flash_off").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            toggleFlashButton.setImage(image, for: .normal)
        } else {
            cameraController.flashMode = .on
            let image = #imageLiteral(resourceName: "ic_flash_on").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            toggleFlashButton.setImage(image, for: .normal)
        }
    }
    
    // переключаем камеры
    func switchCameras() {
        do {
            try cameraController.switchCameras()
        } catch {
            print(error)
        }
        
        switch cameraController.currentCameraPosition {
        case .some(.front):
            let image = #imageLiteral(resourceName: "ic_switch_camera").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            toggleCameraButton.setImage(image, for: .normal)
            
        case .some(.rear):
            let image = #imageLiteral(resourceName: "ic_switch_camera").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            toggleCameraButton.setImage(image, for: .normal)
            
        case .none:
            return
        }
    }
    
    // делаем снимок
    func captureImage() {
        cameraController.captureImage { [unowned self] (image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            
            do {
                try PHPhotoLibrary.shared().performChangesAndWait {
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }
                self.getLastPhotoFromLibrary()
                self.setAnalazyPhoto(image: image)
            } catch {
                print(error)
            }
        }
    }
    
    // фото, которое будем сканировать
    fileprivate func setAnalazyPhoto(image: UIImage) {
        capturePhoto.image = image
        self.blurView.isHidden = false
    }
    
    // берём самое последнее фото из галереи
    fileprivate func getLastPhotoFromLibrary() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        if let lastAsset: PHAsset = fetchResult.lastObject {
            let manager = PHImageManager.default()
            
            manager.requestImage(for: lastAsset,
                                 targetSize: openLibraryButton.bounds.size,
                                 contentMode: .aspectFill,
                                 options: requestOptions,
                                 resultHandler: { [unowned self] (image, _) in
                                    self.openLibraryButton.setImage(image, for: .normal)
            })
        }
    }
    
    fileprivate func classifierImage(image: UIImage) {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 299.0, height: 299.0), true, 2.0)
        image.draw(in: CGRect(x: 0.0, y: 0.0, width: 299.0, height: 299.0))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(newImage.size.width),
                                         Int(newImage.size.height),
                                         kCVPixelFormatType_32ARGB,
                                         attrs,
                                         &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData,
                                width: Int(newImage.size.width),
                                height: Int(newImage.size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0.0, y: newImage.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        newImage.draw(in: CGRect(x: 0.0, y: 0.0, width: newImage.size.width, height: newImage.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        // Core ML
        
        guard let prediction = try? inceptionModel.prediction(image: pixelBuffer!) else {
            return
        }
        
        answerFromMLLabel.text = prediction.classLabel
    }
}
