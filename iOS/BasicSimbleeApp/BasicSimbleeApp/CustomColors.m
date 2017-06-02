//
//  CustomColors.m
//  BasicSimbleeApp
//
//  Created by Robert Rehrig on 6/1/17.
//  Copyright © 2017 Rob Rehr. All rights reserved.
//

#import "CustomColors.h"

@implementation UIColor (CustomColors)

+ (UIColor *)appleBlueColor {
    
    static UIColor *appleBlueColor;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appleBlueColor = [UIColor colorWithRed:0.0/255.0
                                         green:122.0/255.0
                                          blue:255.0/255.0
                                         alpha:1.0];
    });
    
    return appleBlueColor;
}

@end
