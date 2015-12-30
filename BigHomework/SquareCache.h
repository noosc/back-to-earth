//
//  SquareCache.h
//  BigHomework
//
//  Created by noosc on 15/12/18.
//
//

#import "cocos2d.h"

typedef enum {
    hleft = 0,
    hright,
    vdown,
    vup,
    MAX,
}lineTypes;

@interface SquareCache : CCNode <CCTargetedTouchDelegate>
{
    CCSpriteBatchNode* batch;
    CCSprite* astronaut;
    CCSprite* outframe;
    CCSprite* mask;
    CCSprite* status;
    CCSprite* foodLeft;
    CCSprite* foodRight;
    CCSprite* foodMiddle;
    CCSprite* electricityLeft;
    CCSprite* electricityRight;
    CCArray* electricityMiddle;
    CCSprite* temperatureLeft;
    CCSprite* temperatureRight;
    CCArray* temperatureMiddle;
    CCArray* ownSignal;
    CCArray* squares;
    CCArray* matrix;
    CCArray* removing;
    CCArray* usedSprites;
    CCArray* lineSprites;
    
    BOOL isAnimating;
    BOOL isTouchEnable;
    BOOL needFill;
    BOOL isInit;
    BOOL isRemoving;
    BOOL gameOver;
    
    CGPoint squareSrc;
    CGPoint squareDest;
    CGRect boundingBox;
    
    ccTime time;
    int temperature;
    int electricity;
    int signal;
    int electricityMax;
    int timeMax;
    int temperatureMax;
    
    ccTime delay;
}
@property CGRect boundingBox;
@end
