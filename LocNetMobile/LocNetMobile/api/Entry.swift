//
//  Entry.swift
//  LocNetMobile
//
//  Created by Ivan Milinkovic on 26. 5. 2025..
//

struct Entry: Decodable, Identifiable {
    let id: String
    let locale: String
    let key: String
    let keyId: String // for deletion
    var value: String
    
    func with(value: String) -> Entry {
        Entry(id: id, locale: locale, key: key, keyId: keyId, value: value)
    }
}
