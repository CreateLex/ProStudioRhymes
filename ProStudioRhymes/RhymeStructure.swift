//
//  RhymeStructure.swift
//  ProStudioRhymes
//
//  Created by Taylor Simpson on 11/2/17.
//  Copyright © 2017 Createlex. All rights reserved.
//

import Foundation

struct RhymingWords : Decodable {
    let word: String
    let freq: Int
    let score: Int
    let flags: String
    let syllables: String
}
