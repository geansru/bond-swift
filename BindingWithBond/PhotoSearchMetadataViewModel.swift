//
//  PhotoSearchMetadataViewModel.swift
//  BindingWithBond
//
//  Created by Dmitry Roytman on 26.02.16.
//  Copyright © 2016 Razeware. All rights reserved.
//

import Foundation
import Bond

class PhotoSearchMetadataViewModel {
    let creativeCommons = Observable<Bool>(false)
    let dateFilter = Observable<Bool>(false)
    let minUploadDate = Observable<NSDate>(NSDate())
    let maxUploadDate = Observable<NSDate>(NSDate())
}