
#import <UIKit/UIKit.h>
#import "MenuScene.h"
#import "cocos2d.h"


@implementation MenuScene

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MenuScene *layer = [MenuScene node];
	
	// add layer as a child to scene
	[scene addChild:layer z:0 tag:0];
	
	// return the scene
	return scene;
}
-(void) setScore:(float)score {
	gameScore = score;
	printf("nhjk%.0f",score);
}
- (id) init
{
	self = [super init];
	if (self != nil) {
			
		CCMenuItem *menuItem1 = [CCMenuItemFont itemFromString:@"Resume" target:self selector:@selector(onResume:)];
		CCMenuItem *menuItem2 = [CCMenuItemFont itemFromString:@"Submit Score" target:self selector:@selector(onSubmitScore:)];
		CCMenuItem *menuItem3 = [CCMenuItemFont itemFromString:@"Top Scores" target:self selector:@selector(onTopScores:)];
		CCMenu *menu = [CCMenu menuWithItems:menuItem1, menuItem2, menuItem3, nil];
		[menu alignItemsVertically];
		[self addChild:menu];
		
	}
	return self;
}
- (void)onResume:(id)sender
{
	NSLog(@"Resume");
	//[[CCDirector sharedDirector] replaceScene:[CCShrinkGrowTransition transitionWithDuration:1.0 scene:[PunchMouse node]]]; 
	[[CCDirector sharedDirector] popScene];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	//printf("asdf %s sdf",[name text]);
	//printf("asdf %s sdf",[[alertView textFieldAtIndex:0] text]);
	
	if ([name.text length] == 0) return;
	
	[self postScore];
	
}

- (void)onSubmitScore:(id)sender
{
	NSLog(@"Submit Score");
	//[[CCDirector sharedDirector] replaceScene:[CCShrinkGrowTransition transitionWithDuration:1.0 scene:[PunchMouse node]]]; 
	
	NSNumber *favtitle;
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *keychapter = [NSString stringWithFormat:@"gameScore"];
	favtitle = [prefs objectForKey:keychapter];
	gameScore = [favtitle floatValue];
	
	//printf("%.0f",gameScore);
	
	
	UIAlertView * addAlert = [[[UIAlertView alloc] initWithTitle:@"Score Name" 
									message:@"\n" delegate:self 
									cancelButtonTitle:@"Post Score" otherButtonTitles:nil] autorelease];
	
	CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0.0, 80.0);
	[addAlert setTransform:myTransform];
	
	name = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
	
	[name setBackgroundColor:[UIColor whiteColor]];
	[name setPlaceholder:@"Enter your name"];
	//name.clearButtonMode = UITextFieldViewModeWhileEditing;
	//name.keyboardType = UIKeyboardTypeAlphabet;
	//name.keyboardAppearance = UIKeyboardAppearanceAlert;
	
	[addAlert addSubview:name];
	[addAlert show];
	
	//name.borderStyle = UITextBorderStyleRoundedRect;

	//name = tf.text;
	//printf("asdf %s sdf",name);
	
	//if ([name length] == 0) return;
	
	//[self postScore];
	
}


- (void)onTopScores:(id)sender
{
	NSLog(@"Top Scores");
	//[[CCDirector sharedDirector] replaceScene:[CCShrinkGrowTransition transitionWithDuration:1.0 scene:[PunchMouse node]]]; 
	[self requestScore];
}

// Cac ham cho score
/*
@interface AppController (Private)
-(void) testRequest;
-(void) testPost;
@end
*/
// CLASS IMPLEMENTATIONS

@synthesize globalScores;


-(void) requestScore
{
	NSLog(@"Requesting scores...");
	
	request = [[CLScoreServerRequest alloc] initWithGameName:@"PunchIt" delegate:self];
	
	NSString *cat = @"PunchMouse";
	
	// The only supported flags as of v0.2 is kQueryFlagByCountry and kQueryFlagByDevice
	tQueryFlags flags = kQueryFlagIgnore;
	
	//if( world == kCountry )
	//	flags = kQueryFlagByCountry;
	//else if(world == kDevice )
	//	flags = kQueryFlagByDevice;
	
	// request All time Scores: the only supported version as of v0.2
	// request best 15 scores (limit:15, offset:0)
	[request requestScores:kQueryAllTime limit:25 offset:0 flags:flags category:cat];
	
	// Release. It won't be freed from memory until the connection fails or suceeds
	[request release];
}

-(void) postScore
{
	NSLog(@"Posting Score");
	
	// The gameKey is the secret key that is generated when you create you game in cocos live.
	// This secret key is used to prevent spoofing the high scores
	server = [[CLScoreServerPost alloc] initWithGameName:@"PunchIt" gameKey:@"f3de5ef036f5da6b62514040d18e6ee2" delegate:self];
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
	
	// cc_ files are predefined cocoslive fields.
	// set score
	[dict setObject: [NSNumber numberWithInt:(int)round(gameScore)] forKey:@"cc_score"];
	printf("%.0f",gameScore);
	
	// set playername
	[dict setObject:[name text] forKey:@"cc_playername"];
	
	// usr_ are fields that can be modified.
	// set speed
	//[dict setObject: [NSNumber numberWithInt: [self getRandomWithMax:2000] ] forKey:@"usr_speed"];
	// set angle
	//[dict setObject: [NSNumber numberWithInt:[self getRandomWithMax:360] ] forKey:@"usr_angle"];
	
	
	// cc_ are fields that cannot be modified. cocos fields
	// set category... it can be "easy", "medium", whatever you want.
	NSString *cat = @"PunchMouse";
	
	[dict setObject:cat forKey:@"cc_category"];
	
	NSLog(@"Sending data: %@", dict);
	
	// You can add a new score to the database
	// [server sendScore:dict];
	
	// Or you can "update" your score instead of adding a new one.
	// The score will be udpated only if it is better than the previous one
	//
	// "update score" is the recommend way since it can be treated like a profile
	// and it has some benefits like: "tell me if my score was beaten", etc.
	// It also supports "world ranking". eg: "What's my ranking ?"
	[server updateScore:dict];
	
	// Release. It won't be freed from memory until the connection fails or suceeds
	[server release];
}

#pragma mark -
#pragma mark ScorePost Delegate

-(void) scorePostOk: (id) sender
{
	NSLog(@"score post OK");
	if( [server ranking] != kServerPostInvalidRanking && [server scoreDidUpdate]) {
		NSString *message = [NSString stringWithFormat:@"World ranking: %d", [server ranking]];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Post Ok." message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];  
		alert.tag = 2;
		[alert show];
		[alert release];
	}
	else {
		NSString *message = [NSString stringWithFormat:@"Score was lower than previous score. World ranking: %d", [server ranking]];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Updated" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];  
		alert.tag = 2;
		[alert show];
		[alert release];
	}

}

-(void) scorePostFail: (id) sender
{
	NSString *message = nil;
	tPostStatus status = [sender postStatus];
	if( status == kPostStatusPostFailed )
		message = @"Cannot post the score to the server. Retry";
	else if( status == kPostStatusConnectionFailed )
		message = @"Internet connection not available. Enable wi-fi / 3g to post your scores to the server";
	
	NSLog(@"%@", message);
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Score Post Failed" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];  
	alert.tag = 0;
	[alert show];
	[alert release];                
}

#pragma mark - 
#pragma mark ScoreRequest Delegate

-(void) scoreRequestOk: (id) sender
{
	NSLog(@"score request OK");    
	NSArray *scores = [request parseScores];
	NSMutableArray *mutable = [NSMutableArray arrayWithArray:scores];

	//[mutable retain];
	
	// use the property (retain is needed)
	self.globalScores = mutable;
	
	//[globalScores retain];
	
	topScoreView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	
	UINavigationBar *aBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
	UINavigationItem *aBarItem = [[UINavigationItem alloc] initWithTitle:@"Top Scores"];
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
								   initWithTitle:@"Menu"
								   style:UIBarButtonItemStylePlain
								   target:self
								   action:@selector(backToMenu:)];
	aBarItem.leftBarButtonItem = backButton;
	//aBarItem.hidesBackButton = NO;
	[backButton release];
	[aBar pushNavigationItem:aBarItem animated:YES];
	[aBarItem release];
	[topScoreView addSubview:aBar];
	[aBar release];
	
	UITableView *aTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, 320, 480) style:UITableViewStyleGrouped];
	[aTableView setDataSource:self];
	[aTableView setDelegate:self];
	aTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	[topScoreView addSubview:aTableView];
	[[[CCDirector sharedDirector] openGLView] addSubview:topScoreView];
	//[myTableView reloadData];
}
- (IBAction)backToMenu:(id)sender {

	[topScoreView removeFromSuperview];

}



-(void) scoreRequestFail: (id) sender
{
	NSLog(@"score request fail");
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Score Request Failed" message:@"Internet connection not available, cannot view world scores" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];        
	alert.tag = 0;
	[alert show];
	[alert release];        
}

#pragma mark UITableView Delegate

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// TODO: Them row count cua List Chapter
// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	tableView.rowHeight = 20;
    return 20;
}


// TODO: Them setText 
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	//printf("%s",[[ListFavorite objectAtIndex:0] UTF8String]);
	
	// Configure the cell.

	// Neu ma khong co score thi tra lai nil
	if (indexPath.row >= [globalScores count])
		return cell;
	
	NSString *playername = [[globalScores objectAtIndex:indexPath.row] objectForKey:@"cc_playername"];
	playername = [playername stringByPaddingToLength: 18 withString: @" " startingAtIndex:0];
	NSString *text = [NSString stringWithFormat:@"%d.%@ %d",
					  indexPath.row+1, playername,
					  [[[globalScores objectAtIndex:indexPath.row] objectForKey:@"cc_score"] intValue]];
	cell.textLabel.text = text;
	[cell setAccessoryType:UITableViewCellAccessoryNone];
	UIFont *font = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:15];
	cell.textLabel.font = font;
	
    return cell;
}



/*
#pragma mark -
#pragma mark Button Delegate
-(void) buttonCallback:(id) sender
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Post Score" message:@"A random score will be posted. Select category"
												   delegate:self cancelButtonTitle:nil otherButtonTitles:@"easy", @"medium", @"hard", nil];
	alert.tag = 1;
	[alert show];
	[alert release];        
}

#pragma mark -
#pragma mark Segment Delegate
- (void)segmentAction:(id)sender
{      
	int idx = [sender selectedSegmentIndex];
	// category
	if( [sender tag] == 0 ) {
		// 0: easy
		// 1: med
		// 2: hard
		category = idx;
	} else if( [sender tag] == 1 ) {
		// 0 = scores world wide
		// 1 = scores by country
		world = idx;
	}
	
	[self requestScore];
}

#pragma mark -
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)view clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if( [view tag] == 1 )
		[self postScore:buttonIndex];
}

#pragma mark -
#pragma mark Application Delegate

-(void) applicationDidFinishLaunching:(UIApplication*)application
{
	//      [self initRandom];
	//      for( int i=0; i< 15;i++)
	//              [self testPost];
	//      [self testRequest];
	
	
	//      [[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeLeft animated:NO];
	
	self.globalScores = [[NSMutableArray alloc] initWithCapacity:50];
	category = kCategoryEasy;
	world = kAll;
	
	[self initRandom];
	
	[window makeKeyAndVisible];
	
	[self requestScore];
}
*/
#pragma mark -
#pragma mark Init

-(void) dealloc
{
	[globalScores release];
	
	//[mainView release];
	//[window release];
	[super dealloc];
}

@end

