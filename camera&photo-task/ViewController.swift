//
//  ViewController.swift
//  camera&photo-task
//
//  Created by Ravan on 17.10.24.
//

import UIKit
import PhotosUI
import Foundation
import AVFoundation

class ViewController: UIViewController {
    
    // MARK: - UI Elements
    
    var picturesData: [UIImage?] = []
    var collectionView: UICollectionView!
    
    private lazy var imageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Tap me for taking Image", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(didTapImage), for: .touchUpInside)
        return button
    }()
    
    private lazy var photoButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Tap me for taking Photo", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(didTapPhoto), for: .touchUpInside)
        return button
    }()
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    // MARK: - Functions
    
    func setupView() {
        view.backgroundColor = .systemMint
        view.addSubview(imageButton)
        view.addSubview(photoButton)
        
        NSLayoutConstraint.activate([
            
            imageButton.bottomAnchor.constraint(equalTo: photoButton.topAnchor, constant: -16),
            imageButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 36),
            imageButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -36),
            
            photoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -36),
            photoButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 36),
            photoButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -36),
            
        ])
        setupCollectionView()
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.itemSize = CGSize(width: 100, height: 100)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: "CustomCollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 36),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    
    @objc private func didTapImage(_ sender: UIButton) {
        print("Iamge button tapped")
        presentImagePicker()
    }
    
    @objc private func didTapPhoto(_ sender: UIButton) {
        print("Photo button tapped")
        presentPhotoPicker()
        checkCameraAuthorization()
    }
    
    func presentImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0
        configuration.filter = .images
            
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
        
        //let imagePicker = UIImagePickerController()
        //imagePicker.sourceType = .photoLibrary
        //imagePicker.delegate = self
        //present(imagePicker, animated: true)
    }
    
    func presentPhotoPicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(message: "Camera is not available on this device.")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    func checkCameraAuthorization() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch authStatus {
        case .authorized:
            presentPhotoPicker()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.presentPhotoPicker()
                    }
                } else {
                    self.showAlert(message: "сamera access was denied")
                }
            }
        case .denied:
            showAlert(message: "сamera access was denied")
        case .restricted:
            showAlert(message: "сamera access is restricted")
        @unknown default:
            fatalError("error")
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "camera access", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picturesData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.identifier, for: indexPath) as! CustomCollectionViewCell
        if let image = picturesData[indexPath.row] {
            cell.imageView.image = image
        } else {
            cell.imageView.image = nil
        }
        return cell
    }
    
    
    /*func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            picturesData.append(image)
            collectionView.reloadData()
        }
        picker.dismiss(animated: true, completion: nil)
        print("picture selected")
    }*/
}

extension ViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)

        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                    if let image = object as? UIImage {
                        self?.picturesData.append(image)
                        DispatchQueue.main.async {
                            self?.collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
}
