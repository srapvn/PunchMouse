
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import	"CocosDenshion.h"
#import "CDAudioManager.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "MenuScene.h"

// Application Delegate class
@interface PunchMouseAppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	// main UIWindow
	// The OpenGL view will be a attached to this UIWindow
    UIWindow *window;

}

// Make the main UIWindow a property
@property (nonatomic, retain) UIWindow *window;

@end


// PunchMouse Layer
@interface PunchMouse : CCLayer
{
	float gameScore;
	int gameLevel;
	int spriteNumber;
	int spriteNoMouseConst;
	int spriteNumberConst;
	NSMutableArray *spriteSet;
	
	AVAudioRecorder *recorder;
	//NSTimer *levelTimer;
	double lowPassResults;
	CDAudioManager *audioManage;
	CDSoundEngine *audioEngine;
	float delayInterval;
	BOOL isProcessingAction;
	BOOL isProcessingBlowing;
	id lastSpriteAction;
	NSTimer *SpriteTimer;
	CCSprite *timesprite;
	BOOL isHeadBlue;
	
	AVAudioSession *audioSession;
	
	BOOL shouldChangeTimeScaleBack;
}

// returns a Scene that contains the PunchMouse as the only child
+(id) scene;
- (void) endBlowing;
- (void) allowStartBlowing;
- (void) markTimePlayEnded;
- (void) playhideSound;

@end


//@interface MenuScene : CCLayer	{ } @end

