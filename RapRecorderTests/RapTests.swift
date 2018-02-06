//
//  RapTests.swift
//  RapTests
//
//  Created by Hwa Soo on 07/10/2017.
//  Copyright © 2017 hwa. All rights reserved.
//

import XCTest
@testable import Rap

class RapTests: XCTestCase {

    func testUtilBeatPath() {
        for i in 1...8 {
            let path = Util.beatPath(file: String(i))
            XCTAssertNotNil(path)
        }
    }
    
}
