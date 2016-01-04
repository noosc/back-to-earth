//
//  SquareSprite.m
//  BigHomework
//
//  Created by noosc on 15/12/18.
//
//

#import "SquareSprite.h"

@implementation SquareSprite

@synthesize squareType, toBeRemove, generateSignal, canMerge, canMove, isUsing, isSpecial, generateSpecial;

+(id) createSquare
{
    return [[[self alloc] initWithDefaultType] autorelease];
}

-(id) initWithDefaultType
{
    toBeRemove = NO;
    generateSignal = NO;
    isUsing = NO;
    generateSpecial = NO;
    canMove = YES;
    
    if (self = [super init]) {
        [self setType:FoodSquare isSpecial:NO];
    }
    return self;
}

-(void) setType:(SquareTypes)type isSpecial:(BOOL)special
{
    squareType = type;
    canMerge = YES;
    isSpecial = special;
    
    NSString* frameName;
    switch (type) {
        case FoodSquare:
            if (!special) {
                frameName = @"square-food.png";
            }else {
                frameName = @"special-food.png";
            }
            break;
        case Watersquare:
            if (!special) {
                frameName = @"square-water.png";
            }else {
                frameName = @"special-water.png";
            }
            break;
        case Electricitysquare:
            if (!special) {
                frameName = @"square-electricity.png";
            }else {
                frameName = @"special-electricity.png";
            }
            break;
        case SignalSquare:
            frameName = @"square-signal.png";
            canMerge = NO;
            break;
        case DefenceSquare:
            if (!special) {
                frameName = @"square-defence.png";
            }else {
                frameName = @"special-defence.png";
            }
            break;
        case HeatSquare:
            if (!special) {
                frameName = @"square-heat.png";
            }else {
                frameName = @"special-heat.png";
            }
            break;
        default:
            [NSException exceptionWithName:@"Square exception!" reason:@"Unhandled square type" userInfo:nil];
            break;
    }
    self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
}

@end