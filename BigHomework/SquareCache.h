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

@interface SquareCache : CCNode <CCTargetedTouchDelegate , UIAccelerometerDelegate>
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
    CCArray* signalStars;
    CCArray* timeStars;
    CCArray* lineSprites;
    CCArray* ices;
    CCArray* stars;
    CCArray* streaks;
    CCSprite* shake;
    
    BOOL isAnimating;
    BOOL isTouchEnable;
    BOOL needFill;
    BOOL isInit;
    BOOL isRemoving;
    BOOL frozen;
    BOOL gameOver;
    BOOL win;
    BOOL needReset;
    
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
-(void) setAstronautPositionX:(int)x;
-(void) resetByShake;
@end
