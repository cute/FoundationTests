//
//  NSAttributedStringTests.m
//  FoundationTests
//
//  Created by Paul Beusterien on 9/18/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "FoundationTests.h"
#import <Foundation/NSAttributedString.h>

#ifndef IM_A_MAC_TARGET
#import <UIKit/UIColor.h>
#import <UIKit/UIFont.h>
#endif

@testcase(NSAttributedString)

#ifndef IM_A_MAC_TARGET

- (BOOL)testNSAttributedStringColorTest
{
    UIColor *one = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
    UIColor *two = [UIColor redColor];
    testassert([one isEqual:two]);
    return YES;
}

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

- (BOOL)testNSAttributedStringInitWithStringAttributed
{
    UIColor *color = [UIColor yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"stringy"
                                    attributes:attrsDictionary];
    
    testassert([[attrString string] isEqualToString:@"stringy"]);
    UIFont *color2 = [attrString attribute:NSFontAttributeName atIndex:3 effectiveRange:nil];
    testassert([color isEqual:color2]);
    return YES;
}

- (BOOL)testNSAttributedStringInitWithAttributedString
{
    UIColor *color = [UIColor yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSAttributedString *preAttrString = [[NSAttributedString alloc] initWithString:@"stringy"
                                                                     attributes:attrsDictionary];
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithAttributedString:preAttrString];
    testassert([[attrString string] isEqualToString:@"stringy"]);
    UIFont *color2 = [attrString attribute:NSFontAttributeName atIndex:3 effectiveRange:nil];
    testassert([color isEqual:color2]);
    return YES;
}

- (BOOL)testNSAttributedStringInitWithStringAttributedEffective
{
    UIColor *color = [UIColor yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"stringy"
                                                                     attributes:attrsDictionary];
    
    testassert([[attrString string] isEqualToString:@"stringy"]);
    NSRange range;
    [attrString attribute:NSFontAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 0 && range.length == 7);
    return YES;
}

- (BOOL)testNSAttributedStringInitWithStringAttributedEffectiveAttributesEmpty
{
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"stringy"];
    NSRange range;
    NSDictionary *d = [attrString attributesAtIndex:3 effectiveRange:&range];
    testassert(range.location == 0 && range.length == 7);
    testassert([d count] == 0);
    
    id obj = [attrString attribute:@"foo" atIndex:5 effectiveRange:&range];
    testassert(range.location == 0 && range.length == 7);
    testassert(obj == nil);
    
    return YES;
}

- (BOOL)testNSAttributedStringInitWithStringAttributedEffectiveAttributesEmptyMutable
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"];
    NSRange range;
    [attrString attributesAtIndex:3 effectiveRange:&range];
    testassert(range.location == 0 && range.length == 7);
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(3,2)];
    [attrString attributesAtIndex:1 effectiveRange:&range];
    testassert(range.location == 0 && range.length == 3);
    
    [attrString attributesAtIndex:6 effectiveRange:&range];
    testassert(range.location == 5 && range.length == 2);
    
    NSDictionary *d = [attrString attributesAtIndex:0 effectiveRange:&range];
    testassert(range.location == 0 && range.length == 3);
    testassert([d count] == 0);
    
    id obj = [attrString attribute:@"foo" atIndex:5 effectiveRange:&range];
    testassert(range.location == 5 && range.length == 2);
    testassert(obj == nil);
    
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

- (BOOL)testNSAttributedStringInitWithStringAttributedMutable
{
    UIColor *color = [UIColor yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"
                                                                     attributes:attrsDictionary];
    
    testassert([[attrString string] isEqualToString:@"stringy"]);
    UIFont *color2 = [attrString attribute:NSFontAttributeName atIndex:3 effectiveRange:nil];
    testassert([color isEqual:color2]);
    return YES;
}

- (BOOL)testNSAttributedStringInitWithStringAttributedEffectiveMutable
{
    UIColor *color = [UIColor yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"
                                                                     attributes:attrsDictionary];
    
    testassert([[attrString string] isEqualToString:@"stringy"]);
    NSRange range;
    [attrString attribute:NSFontAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 0 && range.length == 7);
    return YES;
}


- (BOOL)testNSAttributedStringInitWithStringAttributedEffectiveMutable2
{
    UIColor *color = [UIColor yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"
                                                                                   attributes:attrsDictionary];
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(3,2)];
    
    testassert([[attrString string] isEqualToString:@"stringy"]);
    
    NSRange range;
    [attrString attribute:NSFontAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 2);
    
    [attrString attribute:NSFontAttributeName atIndex:2 effectiveRange:&range];
    testassert(range.location == 0 && range.length == 3);
    
    UIFont *color2 = [attrString attribute:NSBackgroundColorAttributeName atIndex:2 effectiveRange:&range];
    testassert(range.location == 0 && range.length == 3);
    testassert(color2 == nil);
    
    [attrString attribute:NSBackgroundColorAttributeName atIndex:4 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 2);
    testassert(color2 == nil);
    
    [attrString attribute:NSFontAttributeName atIndex:6 effectiveRange:&range];
    testassert(range.location == 5 && range.length == 2);
    
    return YES;
}

- (BOOL)testNSAttributedStringInitWithStringAttributedOverlap
{
    UIColor *yellow = [UIColor yellowColor];
    UIColor *blue = [UIColor blueColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:yellow forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"
                                                                                   attributes:attrsDictionary];
    [attrString addAttribute:NSBackgroundColorAttributeName value:yellow range:NSMakeRange(3,2)];
    [attrString addAttribute:NSBackgroundColorAttributeName value:blue range:NSMakeRange(3,3)];
    
    testassert([attrString attribute:NSBackgroundColorAttributeName atIndex:2 effectiveRange:nil] == nil);
    testassert([attrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:nil] == blue);
    testassert([attrString attribute:NSBackgroundColorAttributeName atIndex:4 effectiveRange:nil] == blue);
    testassert([attrString attribute:NSBackgroundColorAttributeName atIndex:5 effectiveRange:nil] == blue);
    testassert([attrString attribute:NSBackgroundColorAttributeName atIndex:6 effectiveRange:nil] == nil);
    return YES;
}

- (BOOL)testNSAttributedStringInitWithStringAttributedOverlap2
{
    UIColor *yellow = [UIColor yellowColor];
    UIColor *blue = [UIColor blueColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:yellow forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"
                                                                                   attributes:attrsDictionary];
    [attrString addAttribute:NSBackgroundColorAttributeName value:yellow range:NSMakeRange(3,2)];
    [attrString addAttribute:NSBackgroundColorAttributeName value:blue range:NSMakeRange(2,2)];

    testassert([attrString attribute:NSBackgroundColorAttributeName atIndex:1 effectiveRange:nil] == nil);
    testassert([attrString attribute:NSBackgroundColorAttributeName atIndex:2 effectiveRange:nil] == blue);
    testassert([attrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:nil] == blue);
    testassert([attrString attribute:NSBackgroundColorAttributeName atIndex:4 effectiveRange:nil] == yellow);
    testassert([attrString attribute:NSBackgroundColorAttributeName atIndex:5 effectiveRange:nil] == nil);
    testassert([attrString attribute:NSBackgroundColorAttributeName atIndex:6 effectiveRange:nil] == nil);
    return YES;
}

- (BOOL)testNSAttributedStringInitWithStringAttributes
{
    UIColor *yellow = [UIColor yellowColor];
    UIColor *blue = [UIColor blueColor];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"];
    [attrString addAttribute:NSFontAttributeName value:yellow range:NSMakeRange(2,3)];
    [attrString addAttribute:NSBackgroundColorAttributeName value:yellow range:NSMakeRange(3,3)];
    [attrString addAttribute:NSBackgroundColorAttributeName value:blue range:NSMakeRange(4,2)];
    
    NSDictionary *d = [attrString attributesAtIndex:1 effectiveRange:nil];
    testassert([d count] == 0);
    testassert([[attrString attributesAtIndex:1 effectiveRange:nil] count] == 0);
    testassert([[attrString attributesAtIndex:2 effectiveRange:nil] count] == 1);
    testassert([[attrString attributesAtIndex:3 effectiveRange:nil] count] == 2);
    testassert([[attrString attributesAtIndex:4 effectiveRange:nil] count] == 2);
    testassert([[attrString attributesAtIndex:5 effectiveRange:nil] count] == 1);
    testassert([[attrString attributesAtIndex:6 effectiveRange:nil] count] == 0);
    return YES;
}


- (BOOL)testNSAttributedStringInitWithStringAttributedEffectiveMutableMerge1
{
    UIColor *color = [UIColor yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"
                                                                                   attributes:attrsDictionary];
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(3,1)];
    
    testassert([[attrString string] isEqualToString:@"stringy"]);
    
    NSRange range;
    [attrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 1);
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(2,1)];
    [attrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:&range];
#warning "Make the implementation defined effectiveRange match iOS
    testassert((range.location == 2 || range.location == 3) && range.length >= 1);
    
    [attrString attribute:NSBackgroundColorAttributeName atIndex:2 effectiveRange:&range];
    testassert(range.location == 2 && range.length >= 1);
    
    [attrString addAttribute:NSFontAttributeName value:[UIColor blueColor] range:NSMakeRange(2,1)];
    
    [attrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 1);
    
    [attrString attribute:NSBackgroundColorAttributeName atIndex:2 effectiveRange:&range];
    testassert(range.location == 2 && range.length == 1);
    
    return YES;
}

- (BOOL)testNSAttributedStringInitWithStringAttributedEffectiveMutableMerge2
{
    UIColor *color = [UIColor yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"
                                                                                   attributes:attrsDictionary];
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(3,1)];
    
    testassert([[attrString string] isEqualToString:@"stringy"]);
    
    NSRange range;
    [attrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 1);
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(4,2)];
    [attrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 3);
    
    id foo = [attrString attribute:NSBackgroundColorAttributeName atIndex:2 effectiveRange:&range];
    testassert(foo == nil);
    testassert(range.location == 0 && range.length == 3);
    
    [attrString addAttribute:NSFontAttributeName value:[UIColor blueColor] range:NSMakeRange(4,1)];
    
    [attrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 1);
    
    [attrString attribute:NSBackgroundColorAttributeName atIndex:4 effectiveRange:&range];
    testassert(range.location == 4 && range.length == 1);
    
    return YES;
}

- (BOOL)testNSAttributedStringInitWithAttributedStringAttributedEffectiveMutableMerge2
{
    UIColor *color = [UIColor yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *preAttrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"
                                                                                   attributes:attrsDictionary];
    [preAttrString addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(3,1)];
    
    testassert([[preAttrString string] isEqualToString:@"stringy"]);
    
    NSRange range;
    [preAttrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 1);
    
    [preAttrString addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(4,2)];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithAttributedString:preAttrString];
    
    [attrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 3);
    
    id foo = [attrString attribute:NSBackgroundColorAttributeName atIndex:2 effectiveRange:&range];
    testassert(foo == nil);
    testassert(range.location == 0 && range.length == 3);
    
    [attrString addAttribute:NSFontAttributeName value:[UIColor blueColor] range:NSMakeRange(4,1)];
    
    [attrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 1);
    
    [attrString attribute:NSBackgroundColorAttributeName atIndex:4 effectiveRange:&range];
    testassert(range.location == 4 && range.length == 1);
    
    return YES;
}

- (BOOL)testNSAttributedStringInitWithAttributedStringAttributedEffectiveMutableMergeFromImmutable
{
    UIColor *yellow = [UIColor yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:yellow forKey:NSFontAttributeName];
    NSAttributedString *preAttrString = [[NSAttributedString alloc] initWithString:@"stringy"
                                                                                      attributes:attrsDictionary];

    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithAttributedString:preAttrString];
    
    UIColor *color = [attrString attribute:NSFontAttributeName atIndex:2 effectiveRange:nil];
    testassert(color == yellow);
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(3,1)];
    testassert([[attrString string] isEqualToString:@"stringy"]);
    
    NSRange range;
    [attrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 1);
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(4,2)];
    
    [attrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 3);
    
    [preAttrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 0 && range.length == 7);
    
    id foo = [attrString attribute:NSBackgroundColorAttributeName atIndex:2 effectiveRange:&range];
    testassert(foo == nil);
    testassert(range.location == 0 && range.length == 3);
    
    [attrString addAttribute:NSFontAttributeName value:[UIColor blueColor] range:NSMakeRange(4,1)];
    
    [attrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 1);
    
    [attrString attribute:NSBackgroundColorAttributeName atIndex:4 effectiveRange:&range];
    testassert(range.location == 4 && range.length == 1);
    
    return YES;
}

- (BOOL)testNSAttributedStringInitWithStringAttributedLongestEffectiveMutableMiss
{
    UIColor *color = [UIColor yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"
                                                                                   attributes:attrsDictionary];
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(3,1)];
    
    testassert([[attrString string] isEqualToString:@"stringy"]);
    
    NSRange range = NSMakeRange(1,2);
    id val = [attrString attribute:NSBackgroundColorAttributeName atIndex:3 longestEffectiveRange:&range inRange:NSMakeRange(4, 2)];
    testassert(range.location == 0 && range.length == 0);
    testassert(val == color);
    
    return YES;
}

- (BOOL)testNSAttributedStringInitWithStringAttributedLongestEffectiveAttributes
{
    UIColor *color = [UIColor yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"stringy" attributes:attrsDictionary];                                                                       
    
    NSRange range = NSMakeRange(1,2);
    NSDictionary *val = [attrString attributesAtIndex:3 longestEffectiveRange:&range inRange:NSMakeRange(4, 2)];
    testassert(range.location == 4 && range.length == 2);
    testassert([val count] == 1);
    
    return YES;
}

- (BOOL)testNSAttributedStringInitWithStringAttributedLongestEffectiveAttribute
{
    UIColor *color = [UIColor yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"stringy" attributes:attrsDictionary];
    
    NSRange range = NSMakeRange(1,2);
    UIColor *color2 = [attrString attribute:NSFontAttributeName atIndex:5 longestEffectiveRange:&range inRange:NSMakeRange(4, 2)];
    testassert(range.location == 4 && range.length == 2);
    testassert(color2 == color);
    
    return YES;
}

- (BOOL)testNSAttributedStringInitWithStringAttributedLongestEffectiveMutableMissAttributes
{
    UIColor *color = [UIColor yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"
                                                                                   attributes:attrsDictionary];
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(3,1)];
    
    NSRange range = NSMakeRange(1,2);
    NSDictionary *val = [attrString attributesAtIndex:3 longestEffectiveRange:&range inRange:NSMakeRange(4, 2)];
    testassert(range.location == 0 && range.length == 0);
    testassert([val count] == 2);
    
    return YES;
}

- (BOOL)testNSAttributedStringInitWithStringAttributedLongestEffectiveMutable
{
    UIColor *color = [UIColor yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"
                                                                                   attributes:attrsDictionary];
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(3,1)];
    
    testassert([[attrString string] isEqualToString:@"stringy"]);
    
    NSRange range;
    [attrString attribute:NSBackgroundColorAttributeName atIndex:3 longestEffectiveRange:&range inRange:NSMakeRange(0, 6)];
    testassert(range.location == 3 && range.length == 1);
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(2,1)];
    [attrString attribute:NSBackgroundColorAttributeName atIndex:3 longestEffectiveRange:&range inRange:NSMakeRange(0, 6)];
    testassert(range.location == 2 && range.length == 2);
    
    [attrString attribute:NSBackgroundColorAttributeName atIndex:2 longestEffectiveRange:&range inRange:NSMakeRange(0, 6)];
    testassert(range.location == 2 && range.length == 2);
    
    [attrString addAttribute:@"foo" value:[UIColor redColor] range:NSMakeRange(2,1)];
    [attrString attribute:NSBackgroundColorAttributeName atIndex:2 longestEffectiveRange:&range inRange:NSMakeRange(0, 6)];
    testassert(range.location == 2 && range.length == 2);
    
    return YES;
}

- (BOOL)testNSAttributedStringInitWithStringAttributedLongestEffectiveMutableAttributes
{
    UIColor *color = [UIColor yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"
                                                                                   attributes:attrsDictionary];
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(3,1)];
    
    NSRange range;
    [attrString attributesAtIndex:3 longestEffectiveRange:&range inRange:NSMakeRange(0, 6)];
    testassert(range.location == 3 && range.length == 1);
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(2,1)];
    [attrString attributesAtIndex:3 longestEffectiveRange:&range inRange:NSMakeRange(0, 6)];
    testassert(range.location == 2 && range.length == 2);
    
    [attrString attributesAtIndex:2 longestEffectiveRange:&range inRange:NSMakeRange(0, 6)];
    testassert(range.location == 2 && range.length == 2);
    
    [attrString addAttribute:@"foo" value:[UIColor redColor] range:NSMakeRange(2,1)];
    [attrString attributesAtIndex:2 longestEffectiveRange:&range inRange:NSMakeRange(0, 6)];
    testassert(range.location == 2 && range.length == 1);
    
    [attrString attributesAtIndex:3 longestEffectiveRange:&range inRange:NSMakeRange(0, 6)];
    testassert(range.location == 3 && range.length == 1);
    
    [attrString addAttribute:@"foo" value:[UIColor redColor] range:NSMakeRange(3,1)];
    [attrString attributesAtIndex:2 longestEffectiveRange:&range inRange:NSMakeRange(0, 6)];
    testassert(range.location == 2 && range.length == 2);
    
    [attrString attributesAtIndex:3 longestEffectiveRange:&range inRange:NSMakeRange(0, 6)];
    testassert(range.location == 2 && range.length == 2);
    
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

- (BOOL)testNSAttributedStringInitWithStringAttributedMutable2
{
    UIColor *color = [UIColor yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"
                                                                                   attributes:attrsDictionary];
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(0,6)];
    testassert([[attrString string] isEqualToString:@"stringy"]);
    UIFont *color2 = [attrString attribute:NSFontAttributeName atIndex:3 effectiveRange:nil];
    testassert([color isEqual:color2]);
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

- (BOOL)testNSAttributedStringExceptionOverlap
{
    BOOL gotException = NO;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"My string."];
    @try
    {
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(4,7)];
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
    
    return YES;
}

- (BOOL)testNSAttributedStringCopy
{
    UIColor *red = [UIColor redColor];
    NSDictionary *dict = @{NSForegroundColorAttributeName: red};
    NSAttributedString *preCopy = [[NSAttributedString alloc] initWithString:@"My string." attributes:dict];
    NSAttributedString *attributedString = [preCopy copy];
    
    
    UIColor *color = [attributedString attribute:NSForegroundColorAttributeName atIndex:3 effectiveRange:nil];
    testassert(color == red);
    
    testassert([[attributedString string] isEqualToString:@"My string."]);
    return YES;
}

- (BOOL)testNSAttributedStringMutableCopy
{
    UIColor *red = [UIColor redColor];
    NSAttributedString *preCopy = [[NSAttributedString alloc] initWithString:@"My string."];
    NSMutableAttributedString *attributedString = [preCopy mutableCopy];
    [attributedString addAttribute:NSForegroundColorAttributeName value:red range:NSMakeRange(2,2)];
    
    NSAttributedString *selectedString = [attributedString attributedSubstringFromRange:NSMakeRange(1,4)];
    
    UIColor *color = [selectedString attribute:NSForegroundColorAttributeName atIndex:3 effectiveRange:nil];
    testassert(color == nil);
    
    color = [selectedString attribute:NSForegroundColorAttributeName atIndex:2 effectiveRange:nil];
    testassert(color == red);
    
    testassert([[selectedString attributesAtIndex:0 effectiveRange:nil] count] == 0);
    testassert([[selectedString attributesAtIndex:1 effectiveRange:nil] count] == 1);
    testassert([[selectedString attributesAtIndex:2 effectiveRange:nil] count] == 1);
    testassert([[selectedString attributesAtIndex:3 effectiveRange:nil] count] == 0);
    return YES;
}

- (BOOL)testNSAttributedStringAttributedSubstringFromRange
{
    UIColor *red = [UIColor redColor];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"My string."];
    [attributedString addAttribute:NSForegroundColorAttributeName value:red range:NSMakeRange(2,2)];
    
    NSAttributedString *selectedString = [attributedString attributedSubstringFromRange:NSMakeRange(1,4)];

    UIColor *color = [selectedString attribute:NSForegroundColorAttributeName atIndex:3 effectiveRange:nil];
    testassert(color == nil);
    
    color = [selectedString attribute:NSForegroundColorAttributeName atIndex:2 effectiveRange:nil];
    testassert(color == red);
    
    testassert([[selectedString attributesAtIndex:0 effectiveRange:nil] count] == 0);
    testassert([[selectedString attributesAtIndex:1 effectiveRange:nil] count] == 1);
    testassert([[selectedString attributesAtIndex:2 effectiveRange:nil] count] == 1);
    testassert([[selectedString attributesAtIndex:3 effectiveRange:nil] count] == 0);
    return YES;
}

- (BOOL)testNSAttributedStringEnumerateAttributesInRange
{
    __block NSUInteger found = NO;
    __block NSUInteger count = 0;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"My string."];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(1,4)];
    
    [attributedString enumerateAttributesInRange:NSMakeRange(0, 6)
                                       options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                    usingBlock:^(NSDictionary *attributes, NSRange range, BOOL *stop)
     {
         found += [[attributes objectForKey:NSForegroundColorAttributeName] isEqual:[UIColor colorWithRed:1 green:0 blue:0 alpha:1]] ? 1 : 0;
         count++;
     }];
    testassert(count == 3);
    testassert(found == 1);
    
    count = 0;
    found = 0;
    
    NSAttributedString *selectedString = [attributedString attributedSubstringFromRange:NSMakeRange(1,4)];

    [selectedString enumerateAttributesInRange:NSMakeRange(0, [selectedString length])
                                       options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                    usingBlock:^(NSDictionary *attributes, NSRange range, BOOL *stop)
    {
        found += [[attributes objectForKey:NSForegroundColorAttributeName] isEqual:[UIColor colorWithRed:1 green:0 blue:0 alpha:1]] ? 1 : 0;
        count++;
    }];
    testassert(count == 1);
    testassert(found == 1);
    return YES;
}

- (BOOL)testNSAttributedStringEnumerateAttribute
{
    __block NSUInteger found = 0;
    __block NSUInteger count = 0;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"My string."];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(1,4)];
    
    [attributedString enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(0, 6)
                                         options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                      usingBlock:^(id val, NSRange range, BOOL *stop)
     {
         found |= val != nil ? 1 : 0;
         count++;
     }];
    testassert(count == 3);
    testassert(found == 1);
    
    count = 0;
    found = 0;
    
    NSAttributedString *selectedString = [attributedString attributedSubstringFromRange:NSMakeRange(1,4)];
    
    [selectedString enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(0, [selectedString length])
                                       options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                    usingBlock:^(id val, NSRange range, BOOL *stop)
     {
         found = val != nil ? 1 : 0;
         count++;
     }];
    testassert(count == 1);
    testassert(found == 1);
    return YES;
}

#endif

@end
