//
//  PhotoSearchViewModel.swift
//  BindingWithBond
//
//  Created by Dmitry Roytman on 25.02.16.
//  Copyright © 2016 Razerware. All rights reserved.
//

import Foundation
import Bond

class PhotoSearchViewModel {
    let searchString = Observable<String?>("")
    let validSearchText = Observable<Bool>(false)
    private let searchService: PhotoSearch =  {
        let apiKey = NSBundle.mainBundle().objectForInfoDictionaryKey("apiKey") as! String
        return PhotoSearch(key: apiKey)
    }()
    let searchResults = ObservableArray<Photo>()
    let searchInProgress = Observable<Bool>(false)
    let errorMessages = EventProducer<String>()
    let searchMetadataViewModel = PhotoSearchMetadataViewModel()
    
    init() {
        searchString
            .map { $0!.characters.count > 3 }
            .bindTo(validSearchText)

        validSearchText
            .throttle(0.5, queue: Queue.Main)
            .observe { [unowned self] in
                if $0 { self.executeSearch() }
            }
    }
    
    private func executeSearch() {
        var query = PhotoQuery()
        query.text = self.searchString.value ?? ""
        
        // settings
        query.creativeCommonsLicence = searchMetadataViewModel.creativeCommons.value
        query.dateFilter = searchMetadataViewModel.dateFilter.value
        query.minDate = searchMetadataViewModel.minUploadDate.value
        query.maxDate = searchMetadataViewModel.maxUploadDate.value
        
        searchInProgress.value = true
        searchService.findPhotos(query) { result in
            self.searchInProgress.value = false
            switch result {
            case .Success(let photos):
                print("500px API returned \(photos.count) photos")
                self.searchResults.removeAll()
                self.searchResults.insertContentsOf(photos, atIndex: 0)
            case .Error(_):
                self.errorMessages.next("There was an API request issue of some sort. Go ahead, hit me with that 1-star review!")
            }
        }
    }
}