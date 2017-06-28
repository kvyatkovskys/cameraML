//
//  LookPhotoViewController.swift
//  CameraML
//
//  Created by Kviatkovskii on 27.06.17.
//  Copyright © 2017 Kviatkovskii. All rights reserved.
//

import UIKit
import RxSwift

protocol LookPhotoLibraryDelegate: class {
    func choosePhoto(image: UIImage)
}

final class LookPhotoViewController: UIViewController {
    fileprivate let image: UIImage
    fileprivate weak var delegate: LookPhotoLibraryDelegate?
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var imageView: UIImageView = {
        let image = UIImageView(image: self.image)
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    fileprivate let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.alpha = 0.8
        return view
    }()
    
    fileprivate let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.textColor = UIColor.white
        button.titleLabel?.font = UIFont.font17
        return button
    }()
    
    fileprivate let chooseButton: UIButton = {
        let button = UIButton()
        button.setTitle("Choose", for: .normal)
        button.titleLabel?.textColor = UIColor.white
        button.titleLabel?.font = UIFont.font17
        return button
    }()
    
    fileprivate func updateConstaints() {
        imageView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        
        bottomView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(70.0)
            make.bottom.equalToSuperview()
        }
        
        cancelButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10.0)
            make.centerY.equalToSuperview()
            make.right.equalTo(bottomView.snp.centerX).offset(-15.0)
        }
        
        chooseButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10.0)
            make.centerY.equalToSuperview()
            make.left.equalTo(bottomView.snp.centerX).offset(15.0)
        }
        
        super.updateViewConstraints()
    }
    
    init(image: UIImage, delegate: LookPhotoLibraryDelegate) {
        self.image = image
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(imageView)
        self.view.addSubview(bottomView)
        bottomView.addSubview(cancelButton)
        bottomView.addSubview(chooseButton)
        
        updateConstaints()
        
        cancelButton.addTarget(self, action: #selector(dismissImage), for: .touchUpInside)
        chooseButton.addTarget(self, action: #selector(chooseImage), for: .touchUpInside)
//        cancelButton.rx.tap.asDriver()
//            .drive(onNext: { [unowned self] _ in
//                self.dismiss(animated: true, completion: nil)
//            }).addDisposableTo(disposeBag)
//        
//        chooseButton.rx.tap.asDriver()
//            .drive(onNext: { [unowned self, weak delegate = self.delegate] in
//                delegate?.choosePhoto(image: self.image)
//                self.dismiss(animated: true, completion: nil)
//            }).addDisposableTo(disposeBag)
    }
    
    func dismissImage() {
        dismiss(animated: true, completion: nil)
    }
    
    func chooseImage() {
        delegate?.choosePhoto(image: self.image)
        dismiss(animated: true, completion: nil)
    }
}
