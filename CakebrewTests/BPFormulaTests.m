//
//  BPFormulaTests.m
//  
//
//  Created by Marek Hrusovsky on 19/08/15.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "BPFormula.h"

@interface BPFormulaTests : XCTestCase

@end

@implementation BPFormulaTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFormulaCreation
{
  BPFormula *formula = [BPFormula formulaWithName:@""];
  XCTAssertNotNil(formula, @"Formula failed to initialize");
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
