//
//  NSAttributedStringTests.m
//  FoundationTests
//
//  Created by Paul Beusterien on 9/18/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "FoundationTests.h"
#import <Foundation/NSAttributedString.h>
#import <UIKit/UIColor.h>
#import <UIKit/UIFont.h>

@testcase(NSAttributedString)

- (BOOL)testNSAttributedStringString
{
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"My string."];
    testassert([[str string] isEqualToString:@"My string."]);
    return YES;
}

- (BOOL)testNSAttributedStringLength
{
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"My string."];
    testassert([str length] == 10);
    return YES;
}

- (BOOL)testNSAttributedStringStringMutable
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"My string."];
    testassert([[str string] isEqualToString:@"My string."]);
    return YES;
}
                
- (BOOL)testNSAttributedStringLengthMutable
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"My string."];
    testassert([str length] == 10);
    return YES;
}

- (BOOL)testNSAttributedStringAttributeNil
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"My string."];
    [str addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(3,5)];
    testassert([str attribute:NSBackgroundColorAttributeName atIndex:0 effectiveRange:nil] == nil);
    testassert([str attribute:NSBackgroundColorAttributeName atIndex:2 effectiveRange:nil] == nil);
    testassert([str attribute:NSBackgroundColorAttributeName atIndex:8 effectiveRange:nil] == nil);
    testassert([str attribute:NSBackgroundColorAttributeName atIndex:9 effectiveRange:nil] == nil);
    return YES;
}

- (BOOL)testNSAttributedStringAttribute
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"My string."];
    [str addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(3,5)];
    UIColor *color = [str attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:nil];
    testassert(color != nil);
    testassert([color isEqual:[UIColor yellowColor]]);
    return YES;
}


- (BOOL)testNSAttributedStringException
{
    BOOL gotException = NO;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"My string."];
    @try
    {
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(10,7)];
    }
    @catch (NSException *caught) {
        testassert([caught.name isEqualToString:@"NSRangeException"]);
        gotException = YES;  //  po caught.reason --- NSMutableRLEArray objectAtIndex:effectiveRange:: Out of bounds
    }
    testassert(gotException);
    return YES;
}

- (BOOL)testNSAttributedStringUseCase
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"My string.abcdefghijklmnopqrstuvwxyz"];
    [str addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(3,5)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(10,7)];
    [str addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(20,10)];
//    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0] range:NSMakeRange(20, 10)];
    
    return YES;
}


- (BOOL)testEnumerateAttributesInRange
{
    __block BOOL found = NO;
//    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"My string."];
//    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(1,4)];
//    
//    NSAttributedString *selectedString = [attributedString attributedSubstringFromRange:NSMakeRange(1,4)];
//    [selectedString enumerateAttributesInRange:NSMakeRange(0, [selectedString length])
//                                       options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
//                                    usingBlock:^(NSDictionary *attributes, NSRange range, BOOL *stop)
//     {
//         found = [[attributes objectForKey:NSForegroundColorAttributeName] isEqual:[UIColor colorWithRed:1 green:0 blue:0 alpha:1]];
//     }];
    testassert(found);
    return YES;
}

@end
