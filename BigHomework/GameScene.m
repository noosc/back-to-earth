//
//  GameScene.m
//  BigHomework
//
//  Created by noosc on 15/12/18.
//
//

#import "GameScene.h"
#import "SimpleAudioEngine.h"

@implementation GameScene

+(id) scene
{
    CCScene* scene = [CCScene node];
    CCLayer* layer = [GameScene node];
    [scene addChild:layer];
    return scene;
}

-(id) init
{
    if (self = [super init]) {
        CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
        self.isAccelerometerEnabled = YES;
        self.isTouchEnabled = YES;
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        [self scheduleUpdate];
        
        CCSprite* background = [CCSprite spriteWithFile:@"background.png"];
        background.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:background z:0];
        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Aurora'sTheme.mp4" loop:YES];
        
        CCSprite* outFrame = [CCSprite spriteWithFile:@"outframe.png"];
        outFrame.position = ccp(screenSize.width/2, outFrame.contentSize.height/2 + 5);
        //[self addChild:outFrame z:1];
        
        squareCache = [SquareCache node];
        squareCache.position = outFrame.position;
        squareCache.boundingBox = [outFrame boundingBox];
        [self addChild:squareCache z:2];
    }
    return self;
}

+(CGPoint) locationFromTouch:(UITouch*)touch
{
    CGPoint touchLocation = [touch locationInView: [touch view]];
    return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

-(void) update:(ccTime)delta
{
}

-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    //CCLOG(@"acceleration: %f" , acceleration.x);
    [squareCache setAstronautPositionX:acceleration.x*20];
    if (acceleration.x < -4 || acceleration.x > 4) {
        [squareCache resetByShake];
    }
}

@end

