//
//  main.m
//  PunchMouse
//
//  Created by Khanh Nguyen on 2/9/10.
//  Copyright KAIST 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	int retVal = UIApplicationMain(argc, argv, nil, @"PunchMouseAppDelegate");
	[pool release];
	return retVal;
}
