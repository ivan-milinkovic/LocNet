//
//  NetworkError.swift
//  LocNetMobile
//
//  Created by Ivan Milinkovic on 26. 5. 2025..
//

import Foundation

enum NetworkError: Error {
    case unspecified(Error?)
    case unauthorized
    case json(Error)
}
