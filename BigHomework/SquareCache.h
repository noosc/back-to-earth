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
    CCArray* squares;
    CCArray* matrix;
    CCArray* removing;
    CCArray* usedSprites;
    CCArray* lineSprites;
    CCAnimate* eat;
    
    BOOL isAnimating;
    BOOL isTouchEnable;
    BOOL needFill;
    BOOL isInit;
    BOOL isRemoving;
    
    CGPoint squareSrc;
    CGPoint squareDest;
    CGRect boundingBox;
    
    ccTime time;
    int temperature;
    int electricity;
    int signal;
}
@property CGRect boundingBox;
@end
