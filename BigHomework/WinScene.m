//
//  WinScene.m
//  BigHomework
//
//  Created by noosc on 16/1/1.
//
//

#include "WinScene.h"
#include "GameScene.h"

@implementation WinScene

+(id) scene
{
    CCScene* scene = [CCScene node];
    CCLayer* layer = [WinScene node];
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
        
        CCLabelTTF* label = [CCLabelTTF labelWithString:@"Win!" fontName:@"Marker Felt" fontSize:64];
        CGSize size = [[CCDirector sharedDirector] winSize];
        label.position = CGPointMake(size.width/2, size.height/2);
        [self addChild:label];
    }
    return self;
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[CCDirector sharedDirector] replaceScene:[GameScene scene]];
}

@end