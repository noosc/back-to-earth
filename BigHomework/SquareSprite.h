//
//  SquareSprite.h
//  BigHomework
//
//  Created by noosc on 15/12/18.
//
//

#import "cocos2d.h"

typedef enum {
    DefenceSquare = 0,
    Electricitysquare,
    HeatSquare,
    FoodSquare,
    Watersquare,
    SignalSquare,
    MAXSquare,
}SquareTypes;

@interface SquareSprite : CCSprite
{
    SquareTypes squareType;
    BOOL toBeRemove;
    BOOL generateSignal;
    BOOL isUsing;
    BOOL generateSpecial;
    
    //special
    BOOL canMerge;
    BOOL canMove;
    BOOL isSpecial;
}
@property BOOL canMove;
@property BOOL isUsing;
@property BOOL isSpecial;
@property BOOL generateSpecial;
@property (nonatomic, readonly) BOOL canMerge;
@property (nonatomic, readonly) SquareTypes squareType;
@property BOOL toBeRemove;
@property BOOL generateSignal;
+(id) createSquare;
-(void) setType:(SquareTypes)type isSpecial:(BOOL)special;

@end
