//
//  Util.swift
//  
//
//  Created by me on 19/07/2022.
//

import Foundation
import Vapor

public struct Util {
    static let defaultContentEncoder = (try? ContentConfiguration.global.requireEncoder(for: .json)) ?? JSONEncoder()
    static let defaultContentDecoder = (try? ContentConfiguration.global.requireDecoder(for: .json)) ?? JSONDecoder()

    static let defaultQueryEncoder = (try? ContentConfiguration.global.requireURLEncoder()) ?? URLEncodedFormEncoder()
}
