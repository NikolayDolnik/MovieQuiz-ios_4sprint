//
//  ArrayTest.swift
//  MovieQuizTests
//
//  Created by Dolnik Nikolay on 23.04.2023.
//

import Foundation
import XCTest
@testable import MovieQuiz

class ArrayTest: XCTestCase {
    func testGetalueInRange() throws {
        //Given
        let array = [1,1,2,3,5]
        //When
        let value = array[safe: 2]
        
        //Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    func testGetValueOutOfRange() throws {
        //Given
        let array = [1,1,2,3,5]
        //When
        let value = array[safe: 20]
        //Then
        XCTAssertNil(value)
    }
}
