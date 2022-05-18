//
//  FileManager-documentsdirectory.swift
//  HotProspects
//
//  Created by Nitish Solanki on 02/05/22.
//

import Foundation

extension FileManager{
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
