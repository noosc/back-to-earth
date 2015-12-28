//
//  MenuScene.m
//  BigHomework
//
//  Created by noosc on 15/12/18.
//
//

//
//  HelloWorldLayer.m
//  BigHomework
//
//  Created by noosc on 15/12/18.
//  Copyright __MyCompanyName__ 2015年. All rights reserved.
//


// Import the interfaces
#import "MenuScene.h"
#import "GameScene.h"
#import "AppDelegate.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation MenuLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];
    
    // 'layer' is an autorelease object.
    MenuLayer *layer = [MenuLayer node];
    
    // add layer as a child to scene
    [scene addChild: layer];
    
    // return the scene
    return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
    // always call "super" init
    // Apple recommends to re-assign "self" with the "super's" return value
    if( (self=[super init]) ) {
        self.isTouchEnabled = YES;
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [frameCache addSpriteFramesWithFile:@"start1.plist"];
        [frameCache addSpriteFramesWithFile:@"start2.plist"];
        [frameCache addSpriteFramesWithFile:@"start3.plist"];
        [frameCache addSpriteFramesWithFile:@"go.plist"];
        NSMutableArray* frames = [NSMutableArray arrayWithCapacity:9];
        for (int i = 0; i < 9; i++) {
            NSString* file = [NSString stringWithFormat:@"进门图 5s (%i).png", i+1];
            CCSpriteFrame* frame = [frameCache spriteFrameByName:file];
            [frames addObject:frame];
        }
        CCAnimation* anim = [CCAnimation animationWithSpriteFrames:frames delay:1.2f];
        CCAnimate* animate = [CCAnimate actionWithAnimation:anim];
        CCCallFunc* func = [CCCallFunc actionWithTarget:self selector:@selector(onCallFunc:)];
        CCSequence* sequence = [CCSequence actions:animate, func, nil];
        background = [CCSprite spriteWithFile:@"background.png"];
        background.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:background z:-1];
        
        [background runAction:sequence];
        
        go = [CCSprite spriteWithSpriteFrameName:@"go1.png"];
        go.visible = NO;
        go.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:go];
    }
    return self;
}

-(void) onCallFunc:(id) sender{
    
    CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    NSMutableArray* frames = [NSMutableArray arrayWithCapacity:2];
    for (int i = 0; i < 2; i++) {
        NSString* file = [NSString stringWithFormat:@"go%i.png", i+1];
        CCSpriteFrame* frame = [frameCache spriteFrameByName:file];
        [frames addObject:frame];
    }
    CCAnimation* anim = [CCAnimation animationWithSpriteFrames:frames delay:0.5f];
    CCAnimate* animate = [CCAnimate actionWithAnimation:anim];
    CCRepeatForever* repeat = [CCRepeatForever actionWithAction:animate];
    go.visible = YES;
    [go runAction:repeat];
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([background numberOfRunningActions] == 0) {
        [[CCDirector sharedDirector] replaceScene:[GameScene scene]];
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
}

@end
