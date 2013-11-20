//
//  NSString+JSON.m
//  ChatterCheckin
//
//  Created by John Gifford on 10/24/12.
//  Copyright (c) 2012 Model Metrics. All rights reserved.
//

#import "NSString+JSON.h"

@implementation NSString (JSON)

- (NSString *)stringByReplacingAsciiCodes {
    
    NSString *string = [self stringByReplacingOccurrencesOfString: @"&amp;" withString: @"&"];
    
    string = [string stringByReplacingOccurrencesOfString: @"&quot;" withString: @"\""];
    string = [string stringByReplacingOccurrencesOfString: @"&#39;" withString: @"'"];
    string = [string stringByReplacingOccurrencesOfString: @"&gt;" withString: @">"];
    string = [string stringByReplacingOccurrencesOfString: @"&lt;" withString: @"<"];
    
    return string;
}

@end
