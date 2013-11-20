//
//  User.h
//  ChatterCheckin
//
//  Created by John Gifford on 10/24/12.
//  Copyright (c) 2012 Model Metrics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject {
    NSString *_fullName;
    NSString *_userId;
}

@property (nonatomic, copy) NSString *fullName;
@property (nonatomic, copy) NSString *userId;
@end
