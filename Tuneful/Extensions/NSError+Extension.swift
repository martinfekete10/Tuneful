//
//  NSError+Extension.swift
//  Tuneful
//
//  Created by Martin Fekete on 11/01/2024.
//

import Foundation

extension NSError {
    static func checkOSStatus(_ closure: () -> OSStatus) throws {
      guard let error = NSError(osstatus: closure()) else {
          return
      }

      throw error
    }

    convenience init?(osstatus: OSStatus) {
        guard osstatus != 0 else {
            return nil
        }

        self.init(domain: NSOSStatusErrorDomain, code: Int(osstatus), userInfo: nil)
    }
}
