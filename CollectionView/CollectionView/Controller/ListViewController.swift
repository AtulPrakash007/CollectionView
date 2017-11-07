//
//  ListViewController.swift
//  CollectionView
//
//  Created by Mac on 10/31/17.
//  Copyright © 2017 AtulPrakash. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
        var gaanaData = [GaanaCategory]()
    
    //Mark:- Detail View Section
    
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var detailTracklabel: UILabel!
    @IBOutlet weak var detailAlbumlabel: UILabel!
    @IBOutlet weak var detailArtistLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        detailView.isHidden = true
        if gaanaData.count == 0{
            ShowAlert("Info", message: "The App needs a working internet connection to function properly")
        }
        
        if Reachability.isConnectedToNetwork(){
            
        }else{
            ShowAlert("Info", message: "The App needs a working internet connection to function properly")
        }
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func ShowAlert(_ title:String, message:String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        // Cancel button
        let cancel = UIAlertAction(title: "Ok", style: .destructive, handler: { (action) -> Void in })
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func detailCloseAction(_ sender: Any) {
        detailView.isHidden = true
    }
}

//MARK: UICollectionViewDelegate
extension ListViewController:UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCellData = gaanaData[indexPath.item]
        detailView.isHidden = false
        detailImageView.imageFromServerURL(urlString: selectedCellData.largeImageUrl, PlaceHolderImage: UIImage(named: "place_holder.png")!)
        detailTracklabel.text = selectedCellData.track
        detailAlbumlabel.text = selectedCellData.album
        
        var artistName:String = ""
        for artist in selectedCellData.artist{
            if artistName.characters.count == 0{
                artistName = "\(artist)"
            }else{
                artistName = "\(artistName) & \(artist)"
            }
        }
        detailArtistLabel.text = artistName
    }
}

//MARK: UICollectionViewDataSource
extension ListViewController:UICollectionViewDataSource{
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gaanaData.count
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GaanaCell", for: indexPath)
        if let gaanaCell = cell as? GaanaCell {
            let cellData = gaanaData[indexPath.item]
            gaanaCell.albumLbl.text = cellData.album
            gaanaCell.songNameLbl.text = cellData.track
//            let imageName = UIImage(named: "salesNow.png")
//            gaanaCell.tempImageView?.image = UIImage.init(named: "salesNow.png")
            gaanaCell.tempImageView.imageFromServerURL(urlString: cellData.thumbImageUrl, PlaceHolderImage: UIImage(named: "place_holder.png")!)
        }
        return cell
    }
}

extension ListViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(2 - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(2))
        return CGSize(width: size, height: 250)
    }
}

