//
//  GaanaModel.swift
//  CollectionView
//
//  Created by Mac on 10/31/17.
//  Copyright © 2017 AtulPrakash. All rights reserved.
//

import UIKit

protocol GaanaModelDelegate:class {
    
    func itemsDownloaded(result:[GaanaCategory])
}


class GaanaModel: NSObject {
    
   weak var gaanaModelDelegate:GaanaModelDelegate?
    
    func getItems() {
        
        Request.sharedInstance.request(url: kbaseUrl, method: "GET", params: ["":""]){
            (result)in
            if result.object(forKey: "tracks") != nil{
                let tracksArray = result.object(forKey: "tracks")! as! Array<Dictionary<String,Any>>
                self.parseJson(tracksArray: tracksArray)
            }
        }
    }
    
    func parseJson(tracksArray:Array<Dictionary<String,Any>>) {
        
        var locArray = [GaanaCategory]()
        
        // Parse it into subcategory structures
        
        for tracks in tracksArray{
            
            let tempArtist = tracks["artist"] as! Array<Dictionary<String,Any>>
            var artistList = [String]()
            for artist in tempArtist{
                artistList.append(artist["name"] as! String)
            }
            // Create new subcategory and set its properties
            let loc = GaanaCategory(album: tracks["album_title"] as! String, track: tracks["track_title"] as! String, thumbImageUrl: tracks["artwork_web"] as! String, largeImageUrl: tracks["artwork_large"] as! String, artist: artistList)
            
            // Add it to the array
            locArray.append(loc)
            
            
        }
        
        gaanaModelDelegate?.itemsDownloaded(result: locArray)
    }
}
