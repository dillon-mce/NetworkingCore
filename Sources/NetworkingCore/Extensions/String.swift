//
//  String.swift
//
//  Created by Dillon McElhinney on 6/11/22.
//

import Foundation

public extension String {
    func obfuscated() -> String {
        let bytes = utf8.map { $0 ^ 0b111 }.reversed()
        return String(bytes: bytes, encoding: .utf8)!
    }
}
