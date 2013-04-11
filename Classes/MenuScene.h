//
//  MenuScene.h
//  PunchMouse
//
//  Created by Khanh Nguyen on 2/11/10.
//  Copyright 2010 KAIST. All rights reserved.
//

#import "PunchMouse.h"
#import "cocos2d.h"
#import <Foundation/Foundation.h>
#import "cocoslive.h"

// Application Delegate class
@interface MenuSceneAppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	// main UIWindow
	// The OpenGL view will be a attached to this UIWindow
    UIWindow *window;
	
}

// Make the main UIWindow a property
@property (nonatomic, retain) UIWindow *window;

@end

@interface MenuScene : CCLayer <UITableViewDelegate,UITableViewDataSource>	{

	NSMutableArray *globalScores;
	float gameScore;
	CLScoreServerPost *server;
	UITextField *name;
	CLScoreServerRequest *request;
	UIView	*topScoreView;
}

@property (nonatomic, retain) NSMutableArray *globalScores;

+(id) scene;
-(void) setScore:(float)score;
-(void) postScore;
-(void) requestScore;

@end
