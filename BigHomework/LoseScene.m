//
//  LoseScene.m
//  BigHomework
//
//  Created by noosc on 15/12/30.
//
//
#include "LoseScene.h"
#include "GameScene.h"

@implementation LoseScene

+(id) scene
{
    CCScene* scene = [CCScene node];
    CCLayer* layer = [LoseScene node];
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
        
        CCLabelTTF* label = [CCLabelTTF labelWithString:@"Game Over" fontName:@"Marker Felt" fontSize:64];
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