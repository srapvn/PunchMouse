//
// PunchMouse
// KTK
// Based on cocos2d
//
// Needed for UIWindow, NSAutoReleasePool, and other objects
#import <UIKit/UIKit.h>

// Import the interfaces
#import "PunchMouse.h"

// A simple define used a tag
enum {
	// Reserve 0-100 for mouse Sprites
	labelTag = 100,
	headSkeletonTag = 1000,
	cheeseTag = 1001,
	shakerTag = 1002,
	blowerTag = 1003,
	menuTag = 500,
	timerTag = 200,
	menuSceneTag = 600,
};

// HelloWorld implementation
@implementation PunchMouse


+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	PunchMouse *layer = [PunchMouse node];
	
	// add layer as a child to scene
	[scene addChild: layer z:0 tag:0];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {
		
		// Init manual Audio Session
		audioSession = [AVAudioSession sharedInstance];
		
		// Init audio manager
		audioManage = [CDAudioManager sharedManager];
		audioEngine = audioManage.soundEngine;
		
		// Set self delegate cho accelerometer
		[[UIAccelerometer sharedAccelerometer] setDelegate:self];
		
		// Set gamescore to 0
		gameScore = 0;
		gameLevel = 1;
		
		// isTouchEnabled is an property of Layer (the super class).
		// When it is YES, then the touches will be enabled
		self.isTouchEnabled = YES;
		
		// isAccelerometerEnabled is property of Layer (the super class).
		// When it is YES, then the accelerometer will be enabled
		self.isAccelerometerEnabled = YES;
		
		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
		
		// create background
		CCSprite *bg = [CCSprite spriteWithFile:@"background.jpg"];
		bg.position =  ccp( size.width /2 , size.height/2 );
		[self addChild:bg];
		
		// create and initialize a Label
		CCLabel* label = [CCLabel labelWithString:[NSString stringWithFormat:@"Level %d  Score %.0f",gameLevel,gameScore] fontName:@"Marker Felt" fontSize:25];
		
		// position the label on the center of the screen
		label.position =  ccp( size.width /2 , size.height/20 );
		
		// add the label as a child to this Layer
		[self addChild:label z:0 tag:labelTag];
		
		// Tao ra Menu Icon
		CCSprite *menuSprite = [CCSprite spriteWithFile:@"menuicon.png"];
		menuSprite.position =  ccp( size.width*48/50 , size.height*3/50 );
		[self addChild:menuSprite z:0 tag:menuTag];
		menuSprite.visible = NO;
		
		spriteSet = [[NSMutableArray alloc] init];
		
		// Tao ra Sprite
		spriteNumber = 5*(1 + gameLevel*0.1);
		spriteNoMouseConst = spriteNumber;
		
		// Set const number of sprite de check lai sau so' luong sprite da bi. click
		spriteNumberConst = spriteNumber;
		
		for (int i=1; i<=spriteNumber; i++)
			[spriteSet addObject:[CCSprite spriteWithFile:@"mouseicon.png"]];
		
		// Preload sound Effect
		[audioEngine loadBuffer:1 filePath:@"Uhhh.wav"];
		[audioEngine loadBuffer:2 filePath:@"JuOb.wav"];
		[audioEngine loadBuffer:3 filePath:@"Chesta.wav"];
		[audioEngine loadBuffer:4 filePath:@"hide.wav"];
		[audioEngine loadBuffer:5 filePath:@"claphand.m4a"];
		
		for (int i=1; i<=spriteNumber; i++) {
			
			//Delay tuy theo gameLevel
			[[spriteSet objectAtIndex:i-1] setPosition: ccp((size.width/50)*(arc4random()%44+3) , (size.height/50)*(arc4random()%44+3))];
			
			[[spriteSet objectAtIndex:i-1] runAction:[CCHide action]];
			
			[self addChild:[spriteSet objectAtIndex:i-1] z:1 tag:i];
			
			// Delay time interval
			delayInterval = 0.6f/(1+gameLevel*0.05);
			
			id action = [CCSequence actions:
						 [CCDelayTime actionWithDuration:delayInterval*i],
						 [CCShow action],
						 [CCFadeIn actionWithDuration:0.2],
						 nil ];
			
			[[spriteSet objectAtIndex:i-1] runAction:action];
		}
		
	}
	return self;
}

// Play hide Sound for sprite
-(void) playhideSound {
	[audioEngine playSound:4 channelGroupId:0 pitch:1.0f pan:0 gain:1.0f loop:NO];
}

// Khoi tao mot level moi
- (void) initNewLevel {
	
	// Re touchable, bat dau thay menu
	self.isTouchEnabled = YES;
	[self getChildByTag:menuTag].visible = YES;
	
	//Remove 2 cai label luc qua man
	[self removeChild:[self getChildByTag:labelTag+1] cleanup:YES];
	[self removeChild:[self getChildByTag:labelTag+2] cleanup:YES];
	
	//Cai nay chi de test
	//if (gameLevel<100) gameLevel =100;
	
	gameLevel++;
	
	// Remove Sprite cu va head/cheese neu chua duoc picked up
	for (int i=1; i<=spriteNoMouseConst; i++) {
		[self removeChild:[self getChildByTag:i] cleanup:YES];
	}
	for (int i=[spriteSet count]-1;i>=0; i--) {
		[self removeChild:[spriteSet objectAtIndex:i] cleanup:YES];
		[spriteSet removeLastObject];
	}
	
	// Tao ra Sprite
	spriteNumber = 5*(1 + gameLevel*0.2);
	if (spriteNumber>50) spriteNumber = 50;
	
	spriteNoMouseConst = spriteNumber;
	
	// ask director the the window size
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	CCLabel* label;
	
	// Delay time interval
	//if (gameLevel < 20) delayInterval = 0.6f/(1+gameLevel*0.05);
	//else delayInterval *= 1.05;
	
	delayInterval = 0.6f/(1+gameLevel*0.05);
	
	// Tao mouse sprites
	//id action;
	for (int i=1; i<=spriteNumber; i++) {
		
		// Tao ra object
		[spriteSet addObject:[CCSprite spriteWithFile:@"mouseicon.png"]];
		
		// create and initialize a Label sprite
		label = [CCLabel labelWithString:[NSString stringWithFormat:@"%d",i] fontName:@"Marker Felt" fontSize:25];
		
		// position the label on the center of the screen
		label.position =  ccp( 25 , 15 );
		
		// Set label color
		label.color = ccc3(0x00, 0x00, 0x00);
		
		// add the label as a child to this Layer
		[[spriteSet objectAtIndex:i-1] addChild:label z:0 tag:labelTag];
		
		//Delay tuy theo gameLevel
		[[spriteSet objectAtIndex:i-1] setPosition: ccp((size.width/50)*(arc4random()%40+5) , (size.height/50)*(arc4random()%40+5))];
		
		[[spriteSet objectAtIndex:i-1] runAction:[CCHide action]];
		
		[self addChild:[spriteSet objectAtIndex:i-1] z:1 tag:i];
		
		id action = [CCSequence actions:
					 [CCDelayTime actionWithDuration:delayInterval*i],
					 [CCShow action],
					 [CCFadeIn actionWithDuration:0.2],
					 [CCDelayTime actionWithDuration:delayInterval*4],
					 [CCScaleTo actionWithDuration:0.2 scale:0.2],
					 [CCHide action],
					 [CCCallFunc actionWithTarget:self selector:@selector(playhideSound)],
					 nil ];
		
		[[spriteSet objectAtIndex:i-1] runAction:action];
		//lastSpriteAction = action;
	}
	
	// Tao ra mot timer sprite de check luc ket thuc
	lastSpriteAction = [CCSequence actions:
						[CCDelayTime actionWithDuration:delayInterval*spriteNoMouseConst+0.3],
						[CCShow action],
						[CCFadeIn actionWithDuration:0.2],
						[CCDelayTime actionWithDuration:delayInterval*4],
						[CCScaleTo actionWithDuration:0.2 scale:0.2],
						[CCHide action],
						nil ];
	timesprite = nil;
	[self removeChildByTag:timerTag cleanup:YES];
	timesprite = [CCSprite spriteWithFile:@"pixel.png"];
	[self addChild:timesprite z:0 tag:timerTag];
	[timesprite runAction:lastSpriteAction];
	
	// Tao ra Head Skeleton Sprites
	if (arc4random()%4 > 0) {
		CCSprite* headSkeleton;
		if (arc4random()%4 > 2) {
			headSkeleton = [CCSprite spriteWithFile:@"headblue.png"];
			label = [CCLabel labelWithString:@"-10%" fontName:@"Marker Felt" fontSize:20];
			isHeadBlue = YES;
		}
		else {
			headSkeleton = [CCSprite spriteWithFile:@"head.png"];
			label = [CCLabel labelWithString:@"-2K" fontName:@"Marker Felt" fontSize:20];
			isHeadBlue = NO;
		}
		[headSkeleton setPosition: ccp((size.width/50)*(arc4random()%40+5) , (size.height/50)*(arc4random()%40+5))];
		label.position =  ccp( 10 , 10 );
		[headSkeleton addChild:label z:0 tag:labelTag];
		
		[headSkeleton runAction:[CCHide action]];
		[self addChild:headSkeleton z:1 tag:headSkeletonTag];
		id action2;
		if (!isHeadBlue) action2 = [CCSequence actions:
									[CCDelayTime actionWithDuration:delayInterval*(arc4random()%spriteNoMouseConst)],
									[CCShow action],
									[CCFadeIn actionWithDuration:0.2],
									[CCMoveTo actionWithDuration:1 position:ccp((size.width/50)*(arc4random()%40+5) , (size.height/50)*(arc4random()%40+5))],
									//[CCHide action],
									nil ];
		else action2 = [CCSequence actions:
						[CCDelayTime actionWithDuration:delayInterval*(arc4random()%spriteNoMouseConst)],
						[CCShow action],
						[CCFadeIn actionWithDuration:0.2],
						[CCMoveTo actionWithDuration:1 position:ccp((size.width/50)*(arc4random()%40+5) , (size.height/50)*(arc4random()%40+5))],
						[CCMoveTo actionWithDuration:1 position:ccp((size.width/50)*(arc4random()%40+5) , (size.height/50)*(arc4random()%40+5))],
						[CCMoveTo actionWithDuration:1 position:ccp((size.width/50)*(arc4random()%40+5) , (size.height/50)*(arc4random()%40+5))],
						//[CCHide action],
						nil ];
		
		[headSkeleton runAction:action2];
		
		[spriteSet addObject:headSkeleton];
		spriteNumber++;
		
	}
	
	// Tao ra cheese
	if (arc4random()%4 > 0) {
		CCSprite* cheese = [CCSprite spriteWithFile:@"cheese.png"];
		[cheese setPosition: ccp((size.width/50)*(arc4random()%40+5) , (size.height/50)*(arc4random()%40+5))];
		[cheese runAction:[CCHide action]];
		label = [CCLabel labelWithString:@"+500" fontName:@"Marker Felt" fontSize:20];
		label.position =  ccp( 10 , 10 );
		[cheese addChild:label z:0 tag:labelTag];
		
		[self addChild:cheese z:1 tag:cheeseTag];
		id action3 = [CCSequence actions:
					  [CCDelayTime actionWithDuration:delayInterval*(arc4random()%spriteNoMouseConst)],
					  [CCShow action],
					  [CCFadeIn actionWithDuration:0.2],
					  [CCMoveTo actionWithDuration:1 position:ccp((size.width/50)*(arc4random()%40+5) , (size.height/50)*(arc4random()%40+5))],
					  [CCHide action],
					  nil ];
		
		[cheese runAction:action3];
		
		[spriteSet addObject:cheese];
		spriteNumber++;
		
	}
	
	// Tao ra Shaker
	if (arc4random()%4 > 0) {
		CCSprite* shaker = [CCSprite spriteWithFile:@"shaker.png"];
		[shaker setPosition: ccp((size.width/50)*(arc4random()%40+5) , (size.height/50)*(arc4random()%40+5))];
		[shaker runAction:[CCHide action]];
		label = [CCLabel labelWithString:@"Shake +1K" fontName:@"Marker Felt" fontSize:20];
		label.position =  ccp( 25 , 25 );
		[shaker addChild:label z:0 tag:labelTag];
		
		[self addChild:shaker z:1 tag:shakerTag];
		id action4 = [CCSequence actions:
					  [CCDelayTime actionWithDuration:delayInterval*(arc4random()%spriteNoMouseConst)],
					  [CCShow action],
					  [CCFadeIn actionWithDuration:0.2],
					  [CCDelayTime actionWithDuration:1.5],
					  [CCHide action],
					  nil ];
		
		[shaker runAction:action4];
		
		[spriteSet addObject:shaker];
		spriteNumber++;
	}
	
	// Tao ra Blower
	if (audioSession.inputIsAvailable)
	if (arc4random()%4 > 0) {
		CCSprite* blower = [CCSprite spriteWithFile:@"blower.png"];
		[blower setPosition: ccp((size.width/50)*(arc4random()%40+5) , (size.height/50)*(arc4random()%40+5))];
		[blower runAction:[CCHide action]];
		label = [CCLabel labelWithString:@"Ahh+1K+3%" fontName:@"Marker Felt" fontSize:20];
		label.position =  ccp( 25 , 25 );
		[blower addChild:label z:0 tag:labelTag];
		
		[self addChild:blower z:1 tag:blowerTag];
		id action5 = [CCSequence actions:
					  [CCDelayTime actionWithDuration:delayInterval*(arc4random()%spriteNoMouseConst)],
					  [CCShow action],
					  [CCFadeIn actionWithDuration:0.2],
					  [CCDelayTime actionWithDuration:1],
					  [CCHide action],
					  nil ];
		
		[blower runAction:action5];
		
		[spriteSet addObject:blower];
		spriteNumber++;
	}
	
	// Set const number of sprite de check lai sau so' luong sprite da bi. click
	spriteNumberConst = spriteNumber;
	
	// Cho phep game chay den khi tat ca sprite bien mat
	isProcessingAction = NO;
	isProcessingBlowing = NO;
	
	//[self performSelector:@selector(markTimePlayEnded) withObject:nil afterDelay:[lastSpriteAction duration] + 2];
	//printf("%f",[lastSpriteAction duration]);
	SpriteTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target: self selector: @selector(markTimePlayEnded) userInfo: nil repeats: YES];
	//[self schedule:@selector(markTimePlayEnded) interval:0.1];
}

- (void) markTimePlayEnded {
	
	if (shouldChangeTimeScaleBack) {
		[CCScheduler sharedScheduler].timeScale = 1;
		shouldChangeTimeScaleBack = NO;
	}
	
	// Check tat ca cac dieu kien de co the qua man moi
	// printf("- %d, %d, %d ",timesprite.visible, isProcessingAction, isProcessingBlowing);
	if (timesprite.visible || isProcessingAction || isProcessingBlowing) return;
	
	// Deactive timer
	//[self unschedule:@selector(markTimePlayEnded)];
	[SpriteTimer invalidate];
	
	// Giai doan chuyen khong cho touch
	self.isTouchEnabled = NO;
	
	CCLabel* labelNextLevel;
	CCLabel* labelPenalty;
	// Check neu co click duoc 5 con mouses khong
	if (spriteNumberConst < spriteNumber + 5) {
		gameScore = gameScore - gameScore*0.05;
		labelNextLevel = [CCLabel labelWithString:
						  [NSString stringWithFormat:@"Level %d Starting",gameLevel+1] 
										 fontName:@"Marker Felt" fontSize:40];
		labelPenalty = [CCLabel labelWithString:
						[NSString stringWithFormat:@"Penalty! Less than 5 punches last level: -5%%"] 
									   fontName:@"Marker Felt" fontSize:20];
		
	}
	else {
		labelNextLevel = [CCLabel labelWithString:[NSString stringWithFormat:@"Level %d Starting",gameLevel+1] fontName:@"Marker Felt" fontSize:40];
		labelPenalty = [CCLabel labelWithString:
						[NSString stringWithFormat:@""] 
									   fontName:@"Marker Felt" fontSize:30];
	}
	
	CCLabel *label = [self getChildByTag:labelTag];
	[label setString:[NSString stringWithFormat:@"Level %d  Score %d",gameLevel+1,(int)gameScore]];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	labelNextLevel.position =  ccp( size.width /2 , size.height/2 );
	labelPenalty.position =  ccp( size.width /2 , size.height/2 -40 );
	// add the label as a child to this Layer
	[self addChild:labelNextLevel z:2 tag:labelTag+1];
	[self addChild:labelPenalty z:2 tag:labelTag+2];
	
	//if (gameLevel >= 5) exit(0);
	[self performSelector:@selector(initNewLevel) withObject:nil afterDelay:3];
	
}

// Detech neu 1 sprites co' bi. touch hay khong
+(BOOL) spriteIsTouched:(CCNode*)sprite touchedPosition:(CGPoint)touchposition{
	
	CGSize size = [sprite contentSize];
	CGPoint position = [sprite position];
	if ((position.x <= touchposition.x + size.width/2)
		&& (position.x >= touchposition.x - size.width/2)
		&& (position.y <= touchposition.y + size.height/2)
		&& (position.y >= touchposition.y - size.height/2))
	{
		return YES;
	}
	return NO;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	
	if( touch ) {
		
		isProcessingAction = YES;
		
		CGPoint location = [touch locationInView: [touch view]];
		
		// IMPORTANT:
		// The touches are always in "portrait" coordinates. You need to convert them to your current orientation
		CGPoint convertedPoint = [[CCDirector sharedDirector] convertToGL:location];
		
		// Check neu touch Menu
		if ([PunchMouse spriteIsTouched:[self getChildByTag:menuTag] touchedPosition:convertedPoint]) {
			
			NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
			NSString *keychapter = [NSString stringWithFormat:@"gameScore"];
			NSNumber *favtitle = [NSNumber numberWithFloat:gameScore];
			[prefs setObject:favtitle forKey:keychapter];
			
			//[[menuScene getChildByTag:0] setScore:gameScore];
			//[[CCActionManager sharedManager] pauseAllActionsForTarget:self];
			// Lam cham lai time scale
			//[CCScheduler sharedScheduler].timeScale = 0.2;
			[[CCDirector sharedDirector] pushScene:[CCRotoZoomTransition transitionWithDuration:0.3 scene:[MenuScene scene]]];
			
			//Phai co de tro lai check markTimePlayEnded
			isProcessingAction = NO;
			
			return;
		}
		
		// Touch sprites icons
		for (int i=spriteNumber-1; i>=0; i--) {
			
			CCNode *sprite = [spriteSet objectAtIndex:i];
			
			if (sprite.visible && [PunchMouse spriteIsTouched:sprite touchedPosition:convertedPoint])
			{
				// Reset spriteSet, remove ra khoi set sprites, nhung van giu lai cac bonuses
				if (sprite.tag<headSkeletonTag) {
					[spriteSet removeObjectAtIndex:i];
					spriteNumber--;
				}
				// Explode sound
				if (sprite.tag == headSkeletonTag) {
					[audioEngine playSound:2 channelGroupId:0 pitch:1.0f pan:0 gain:1.0f loop:NO];
				}
				else if (sprite.tag == cheeseTag) {
					[audioEngine playSound:3 channelGroupId:0 pitch:1.0f pan:0 gain:1.0f loop:NO];
				}
				else if (sprite.tag == blowerTag) {
					//[audioEngine playSound:1 channelGroupId:0 pitch:1.0f pan:0 gain:1.0f loop:NO];
				}		
				else if (sprite.tag < headSkeletonTag) 
					[audioEngine playSound:1  channelGroupId:0 pitch:1.0f pan:0 gain:1.0f loop:NO];
				
				// Explode sprite image
				ccGridSize gsize; gsize.x =10; gsize.y =10;
				CGPoint rootpos; rootpos.x =0; rootpos.y = 0;
				id shatter = [CCSequence actions:
							  [CCRotateBy actionWithDuration:0.3 angle:720],
							  //[CCShatteredTiles3D actionWithRange:10 shatterZ:NO grid:gsize  duration:0.1],
							  [CCHide action],
							  nil];
				
				// we stop the all running actions and run new action
				[sprite stopAllActions];
				//if (sprite.tag == blowerTag) [sprite runAction:[CCHide action]]; else 
					[sprite	runAction:shatter];
				
				//[[sprite parent] removeChild:sprite cleanup:YES];
				
				CCNode *label = [self getChildByTag:labelTag];
				
				//Mechanism for game score click first image will have higher score
				switch ([sprite tag]) {
					case headSkeletonTag:	// Mat 20% so Diem
						if (isHeadBlue){
							gameScore = gameScore - gameScore*0.1;
						}
						else {
							if (gameScore>2000) gameScore = gameScore - 2000;
						}
						break;
					case cheeseTag:	// Tang 2% so Diem
						gameScore = gameScore + 500;
						break;
					case shakerTag:	// Click shaker khong tang diem
						break;
					case blowerTag:
						//Lam cham thoi gian chay sprite trong luc doi record microphone
						//Phai set lai sau khi chay xong record
						[CCScheduler sharedScheduler].timeScale = 0;
						
						// Bat dau session record
						[audioManage audioSessionInterrupted];
						[self allowStartBlowing];
						break;
					default:
						gameScore+= (1000 + 0.2*spriteNumber*(spriteNoMouseConst-[sprite tag]))/10;
						break;
				}
				
				// Set new game score & Level
				[label setString:[NSString stringWithFormat:@"Level %d  Score %.0f",gameLevel,gameScore]];
				
				// Check neu da het sprite thi qua man moi
				if (([spriteSet count] == 0) || ([[spriteSet objectAtIndex:0] tag] >= headSkeletonTag)) {
					
					// Deactivate touch
					self.isTouchEnabled = NO;
					
					[timesprite stopAllActions];
					[timesprite runAction:[CCHide action]];
					isProcessingAction = NO;
					
					// Qua man moi
					[self markTimePlayEnded];
					return;
				}
				
				isProcessingAction = NO;
				return;
			}
		}
		
		isProcessingAction = NO;
		
	}	
}

// Detect shake activity - Dung cho shaker khi xuat hien
- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
	CCNode *spriteshaker = [self getChildByTag:shakerTag];
	
	// Convert the coordinates to 'landscape' coords
	// since they are always in 'portrait' coordinates
	CGPoint converted = ccp( (float)-acceleration.y, (float)acceleration.x);	
	
	// Hieu ung cho shaker
	if (!spriteshaker.visible) return;
	
	// update the rotation based on the z-rotation
	// the sprite will always be 'standing up'
	spriteshaker.rotation = (float) CC_RADIANS_TO_DEGREES( atan2f( converted.x, converted.y) + M_PI );
	
	// update the scale based on the length of the acceleration
	// the higher the acceleration, the higher the scale factor
	spriteshaker.scale =  0.9f + 0.1*sqrtf( (converted.x * converted.x) + (converted.y * converted.y) );
	
	// Detect shake thi explode shaker va cong diem
	const float violence = 0.7;
	static BOOL beenhere;
	BOOL shake = FALSE;
	
	if (beenhere) return;
	beenhere = TRUE;
	if (acceleration.x > violence * 1.5 || acceleration.x < (-1.5* violence))
		shake = TRUE;
	if (acceleration.y > violence * 2 || acceleration.y < (-2 * violence))
		shake = TRUE;
	if (acceleration.z > violence * 3 || acceleration.z < (-3 * violence))
		shake = TRUE;
	if (shake) {
		// YOUR CODE HERE ****
		//printf("SHaked");
		
		// Explode sound
		[audioEngine playSound:3 channelGroupId:0 pitch:1.0f pan:0 gain:1.0f loop:NO];
		
		// Explode sprite image
		id shatter = [CCSequence actions:
					  [CCRotateBy actionWithDuration:0.3 angle:720],
					  [CCHide action],
					  nil];
		
		[spriteshaker	runAction:shatter];
		
		// Set new game score & Level
		gameScore += 1000;
		CCNode *label = [self getChildByTag:labelTag];
		[label setString:[NSString stringWithFormat:@"Level %d  Score %.0f",gameLevel,gameScore]];
	} 
	beenhere = FALSE;
	
}

- (void) endBlowing {
	
	//const double ALPHA = 0.05;
	//double peakPowerForChannel1 = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
	//lowPassResults = ALPHA * peakPowerForChannel1 + (1.0 - ALPHA) * lowPassResults;
	
	[recorder updateMeters];
	lowPassResults =  [recorder peakPowerForChannel:0];
	//printf("%f\n",lowPassResults);
	
	// Thesthold ma se detech voice cua minh
	if (lowPassResults > -15)
	{
		[recorder stop];
		//[recorder release];
		lowPassResults = -160;
		
		//NSLog(@"Mic blow detected");
		//[levelTimer invalidate];
		
		// Explode sound
		[audioManage audioSessionResumed];
		
		[audioEngine playSound:5 channelGroupId:0 pitch:1.0f pan:0 gain:1.0f loop:NO];
		
		//Phai set lai timescale nhu cu (1) de lam cho toc do chay binh thuong
		[CCScheduler sharedScheduler].timeScale = 0.75;
		shouldChangeTimeScaleBack = YES;
		
		// Set new game score & Level
		gameScore = gameScore + 1000 + (gameScore*0.03);
		CCNode *label = [self getChildByTag:labelTag];
		[label setString:[NSString stringWithFormat:@"Level %d  Score %.0f",gameLevel,gameScore]];
		
		isProcessingBlowing = NO;
		return;
	}
	else {
		
		[recorder stop];
		//[recorder release];
		lowPassResults = -160;
		
		//[levelTimer invalidate];
		
		// Explode sound
		[audioManage audioSessionResumed];
		
		//Phai set lai timescale nhu cu (1) de lam cho toc do chay binh thuong
		[CCScheduler sharedScheduler].timeScale = 0.75;
		shouldChangeTimeScaleBack = YES;
		
		isProcessingBlowing = NO;
		return;
	}
	
}

- (void) allowStartBlowing {
	
	isProcessingBlowing = YES;
	
	NSError *err = nil;
	[audioSession setCategory :AVAudioSessionCategoryRecord error:&err];
	[audioSession setActive:YES error:&err];
	
	if (!recorder) {
		
		NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
		
		NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithFloat: 4000],					AVSampleRateKey,
								  [NSNumber numberWithInt: kAudioFormatAppleIMA4],		AVFormatIDKey,
								  [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
								  [NSNumber numberWithInt: AVAudioQualityMin],         AVEncoderAudioQualityKey,
								  nil];
		
		NSError *error;
		
		recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
		recorder.meteringEnabled = YES;
		lowPassResults = -160;
		[recorder prepareToRecord];
		
	}	
	
  	if (recorder) {
		
  		[recorder record];
		//levelTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target: self selector: @selector(endBlowing) userInfo: nil repeats: YES];
		[self performSelector:@selector(endBlowing) withObject:nil afterDelay:0.05];
  	}
	
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
	
	[spriteSet release];
	[audioEngine release];
	[audioManage release];
}
@end
