//
//  SquareCache.m
//  BigHomework
//
//  Created by noosc on 15/12/18.
//
//

#import "SquareCache.h"
#import "SquareSprite.h"
#import "GameScene.h"

@implementation SquareCache
@synthesize boundingBox;

static const int numSquare = 128;
static const int matrixSize = 8;

-(id) init
{
    if (self = [super init]) {
        CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [frameCache addSpriteFramesWithFile:@"square.plist"];
        CCTexture2D* gameArtTexture = [[CCTextureCache sharedTextureCache] addImage:@"square.png"];
        batch = [CCSpriteBatchNode batchNodeWithTexture:gameArtTexture];
        
        CCSprite* outFrame = [CCSprite spriteWithSpriteFrameName:@"outframe.png"];
        [batch addChild:outFrame z:-1];
        [self addChild:batch];
        
        isAnimating = YES;
        isTouchEnable = NO;
        isInit = YES;
        isRemoving = NO;
        needFill = NO;
        squareSrc = ccp(-1, -1);
        squareDest = ccp(-1, -1);
        
        time = 180;
        temperature = 5;
        electricity = 0;
        signal = 0;
        
        squares = [[CCArray alloc] initWithCapacity:numSquare];
        for (int i = 0; i < numSquare; i++) {
            SquareSprite* square = [SquareSprite createSquare];
            square.visible = NO;
            [batch addChild:square z:1 tag:i];
            [squares addObject:square];
        }
        matrix = [[CCArray alloc] initWithCapacity:matrixSize];
        for (int i = 0; i < matrixSize; i++) {
            CCArray* column = [CCArray arrayWithCapacity:numSquare];
            [matrix addObject:column];
        }
        removing = [[CCArray alloc] initWithCapacity:15];
        usedSprites = [[CCArray alloc] initWithCapacity:5];
        lineSprites = [[CCArray alloc] initWithCapacity:numSquare];
        for (int i = 0; i < numSquare; i++) {
            CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:@"hleft.png"];
            sprite.visible = NO;
            [lineSprites addObject:sprite];
            [batch addChild:sprite z:11];
        }
        [self resetSquares];
        
        //mask
        CCSprite* mask = [CCSprite spriteWithFile:@"mask.png"];
        mask.position = ccp(0, 124);
        [self addChild:mask z:2];
        
        //astronaut
        astronaut = [CCSprite spriteWithSpriteFrameName:@"astronaut.png"];
        astronaut.position = ccp(0, 124);
        [self addChild:astronaut z:3];
        
        [self scheduleUpdate];
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    }
    return self;
}

//arrange squares to matrix
-(void) resetSquares
{
    isInit = YES;
    [removing removeAllObjects];
    for (int i = 0; i < numSquare; i++) {
        SquareSprite* square = [squares objectAtIndex:i];
        [square stopAllActions];
        square.visible = NO;
        square.isUsing = NO;
        square.toBeRemove = NO;
        square.generateSignal = NO;
        square.generateSpecial = NO;
        square.scale = 1;
    }
    for (int j = 0; j < matrixSize; j++) {
        CCArray* column = [matrix objectAtIndex:j];
        [column removeAllObjects];
        for (int i = 0; i < matrixSize; i++) {
            int type = arc4random() % (MAXSquare - 1);
            [self createAtRow:i Column:j WithType:type canMove:YES isSpecial:NO];
        }
    }
    //make sure no 3-sequence at initial time
    while (isInit) {
        [self scanSquares];
    }
    for (int j = 0; j < matrixSize; j++) {
        for (int i = 0; i < matrixSize; i++) {
            [self dropSquareAtRow:i Column:j From:[self positionOfItemAtRow:i + matrixSize Column:j]];
        }
    }
}

-(SquareSprite*) squareAtRow:(int)row Column:(int)column
{
    return (SquareSprite*)[[matrix objectAtIndex:column] objectAtIndex:row];
}

//return whether there are any 3-squence to be removed
-(BOOL) isAvailable
{
    for (int i = 0; i < matrixSize; i++) {
        for (int j = 0; j < matrixSize; j++) {
            SquareSprite* square = [self squareAtRow:i Column:j];
            if (square.canMerge == NO || square.canMove == NO) {
                continue;
            }
            /*    o
                 #    */
            if (i > 0 && j > 0 && [self squareAtRow:i - 1 Column:j - 1].squareType == square.squareType) {
                /*    o
                     #
                     #    */
                if (i > 1 && [self squareAtRow:i - 2 Column:j - 1].squareType == square.squareType && [self squareAtRow:i Column:j - 1].canMove) {
                    return YES;
                }
                /*    o
                    ##    */
                if (j > 1 && [self squareAtRow:i - 1 Column:j - 2].squareType == square.squareType && [self squareAtRow:i - 1 Column:j].canMove) {
                    return YES;
                }
                /*    o
                     # #  */
                if (j < matrixSize - 1 && [self squareAtRow:i - 1 Column:j + 1].squareType == square.squareType && [self squareAtRow:i - 1 Column:j].canMove) {
                    return YES;
                }
            }
            /*   o
                  #  */
            if (i > 0 && j < matrixSize - 1 && [self squareAtRow:i - 1 Column:j + 1].squareType == square.squareType) {
                /*   o
                      #
                      #   */
                if (i > 1 && [self squareAtRow:i - 2 Column:j + 1].squareType == square.squareType && [self squareAtRow:i Column:j + 1].canMove) {
                    return YES;
                }
                /*   o
                      ##  */
                if (j < matrixSize - 2 && [self squareAtRow:i - 1 Column:j + 2].squareType == square.squareType && [self squareAtRow:i - 1 Column:j].canMove) {
                    return YES;
                }
                /*    #
                     o
                      #   */
                if (i < matrixSize - 1 && [self squareAtRow:i + 1 Column:j + 1].squareType == square.squareType && [self squareAtRow:i Column:j + 1].canMove) {
                    return YES;
                }
            }
            /*    #
                 o    */
            if (i < matrixSize - 1 && j < matrixSize - 1 && [self squareAtRow:i + 1 Column:j + 1].squareType == square.squareType) {
                /*    #
                      #
                     o   */
                if (i < matrixSize - 2 && [self squareAtRow:i + 2 Column:j + 1].squareType == square.squareType && [self squareAtRow:i Column:j + 1].canMove) {
                    return YES;
                }
                /*    ##
                     o   */
                if (j < matrixSize - 2 && [self squareAtRow:i + 1 Column:j + 2].squareType == square.squareType && [self squareAtRow:i + 1 Column:j].canMove) {
                    return YES;
                }
                /*  # #
                     o   */
                if (j > 0 && [self squareAtRow:i + 1 Column:j - 1].squareType == square.squareType && [self squareAtRow:i + 1 Column:j].canMove) {
                    return YES;
                }
            }
            /*  #
                 o   */
            if (i < matrixSize - 1 && j > 0 && [self squareAtRow:i + 1 Column:j - 1].squareType == square.squareType) {
                /*  #
                    #
                     o   */
                if (i < matrixSize - 2 && [self squareAtRow:i + 2 Column:j - 1].squareType == square.squareType && [self squareAtRow:i Column:j - 1].canMove) {
                    return YES;
                }
                /* ##
                     o   */
                if (j > 1 && [self squareAtRow:i + 1 Column:j - 2].squareType == square.squareType && [self squareAtRow:i + 1 Column:j].canMove) {
                    return YES;
                }
                /*  #
                     o
                    #    */
                if (i > 0 && [self squareAtRow:i - 1 Column:j - 1].squareType == square.squareType && [self squareAtRow:i Column:j - 1].canMove) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

-(void) createAtRow:(int)row Column:(int)column WithType:(SquareTypes)type canMove:(BOOL)move isSpecial:(BOOL)special
{
    SquareSprite* square;
    CCARRAY_FOREACH(squares, square)
    {
        if (square.isUsing == NO) {
            [square setType:type canMove:move isSpecial:special];
            [[matrix objectAtIndex:column] insertObject:square atIndex:row];
            square.isUsing = YES;
            return;
        }
    }
}

-(CCSprite*) lineSpriteWithType:(lineTypes)type
{
    CCSprite* sprite;
    CCARRAY_FOREACH(lineSprites, sprite)
    {
        if (sprite.visible == NO) {
            sprite.scale = 1;
            sprite.visible = YES;
            NSString* frameName;
            switch (type) {
                case hleft:
                    frameName = @"hleft.png";
                    break;
                case hright:
                    frameName = @"hright.png";
                    break;
                case vdown:
                    frameName = @"vdown.png";
                    break;
                case vup:
                    frameName = @"vup.png";
                    break;
                    
                default:
                    [NSException exceptionWithName:@"lineSprite exception!" reason:@"Unhandled sprite type" userInfo:nil];
                    break;
            }
            sprite.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
            break;
        }
    }
    return sprite;
}

-(void) removeAnimate
{
    if (removing.count == 0 || isRemoving) {
        return;
    }
    isRemoving = YES;
    isAnimating = YES;
    SquareSprite* square;
    CCARRAY_FOREACH(removing, square)
    {
        square.isUsing = YES;
        if (square.squareType == SignalSquare) {
            [square runAction:[CCMoveBy actionWithDuration:0.2 position:ccp(0, -square.contentSize.height)]];
        }else if (square.squareType == DefenceSquare && square.isSpecial){
            CCSprite* hl = [self lineSpriteWithType:hleft];
            CCSprite* hr = [self lineSpriteWithType:hright];
            hl.position = square.position;
            hr.position = square.position;
            CGPoint leftEnd = square.position;
            CGPoint rightEnd = square.position;
            leftEnd.x = [self positionOfItemAtRow:0 Column:-8].x;
            rightEnd.x = [self positionOfItemAtRow:0 Column:15].x;
            CCEaseOut* extendLeft = [CCEaseOut actionWithAction:[CCScaleTo actionWithDuration:1.5 scaleX:8 scaleY:0.7] rate:3];
            CCEaseOut* extendRight = [CCEaseOut actionWithAction:[CCScaleTo actionWithDuration:1.5 scaleX:8 scaleY:0.7] rate:3];
            CCEaseOut* moveLeft = [CCEaseOut actionWithAction:[CCMoveTo actionWithDuration:1.5 position:leftEnd] rate:3];
            CCEaseOut* moveRight = [CCEaseOut actionWithAction:[CCMoveTo actionWithDuration:1.5 position:rightEnd] rate:3];
            [hl runAction:extendLeft];
            [hl runAction:moveLeft];
            [hr runAction:extendRight];
            [hr runAction:moveRight];
            [usedSprites addObject:hl];
            [usedSprites addObject:hr];
        }else{
            [square runAction:[CCScaleTo actionWithDuration:0.2 scale:0]];
            NSString* file = [NSString stringWithFormat:@"remove-%i.plist", square.squareType + 1];
            CCParticleSystemQuad* sys = [CCParticleSystemQuad particleWithFile:file];
            sys.position = square.position;
            sys.autoRemoveOnFinish = YES;
            [self addChild:sys z:10];
        }
    }
}

-(void) onCallFunc:(id) sender{
    CCLOG(@"func!!!!!!!!!!!");
}

-(void) dropSquareAtRow:(int)row Column:(int)column From:(CGPoint)startPoint
{
    isAnimating = YES;
    SquareSprite* square = [self squareAtRow:row Column:column];
    CGPoint endPoint = [self positionOfItemAtRow:row Column:column];
    square.position = startPoint;
    square.visible = YES;
    square.scale = 1;
    float duration = 0.1 * (startPoint.y - endPoint.y) / square.contentSize.height + 0.01 * row;
    [square runAction:[CCMoveTo actionWithDuration:duration position:endPoint]];
}

-(CGPoint) positionOfItemAtRow:(int)row Column:(int)column
{
    SquareSprite* square = [squares objectAtIndex:0];
    CGSize squareSize = square.contentSize;
    float x = (column - matrixSize/2 + 0.5f) * squareSize.width;
    float y = (row - matrixSize/2 + 0.5f) * squareSize.height;
    return ccp(x, y);
}

-(CGPoint) existHorizontalChainAt:(int)row Column:(int)column
{
    SquareSprite* square = [self squareAtRow:row Column:column];
    if (!square.canMerge) {
        return ccp(0, 0);
    }
    int left = column;
    while (left > 0) {
        SquareSprite* leftNeighbor = [self squareAtRow:row Column:left - 1];
        if (leftNeighbor.squareType == square.squareType) {
            left--;
        }else{
            break;
        }
    }
    int right = column;
    while (right < matrixSize - 1) {
        SquareSprite* rightNeighbor = [self squareAtRow:row Column:right + 1];
        if (rightNeighbor.squareType == square.squareType) {
            right++;
        }else{
            break;
        }
    }
    return ccp(left, right);
}

-(CGPoint) existVerticalChainAt:(int)row Column:(int)column
{
    SquareSprite* square = [self squareAtRow:row Column:column];
    if (!square.canMerge) {
        return ccp(0, 0);
    }
    int up = row;
    while (up < matrixSize - 1) {
        SquareSprite* upNeighbor = [self squareAtRow:up + 1 Column:column];
        if (upNeighbor.squareType == square.squareType) {
            up++;
        }else{
            break;
        }
    }
    int down = row;
    while (down > 0) {
        SquareSprite* downNeighbor = [self squareAtRow:down - 1 Column:column];
        if (downNeighbor.squareType == square.squareType) {
            down--;
        }else{
            break;
        }
    }
    return ccp(down, up);
}


-(void)checkSpecial
{
    BOOL needRecurse = NO;
    for (int i = 0; i < matrixSize; i++) {
        for (int j = 0; j < matrixSize; j++) {
            SquareSprite* square = [self squareAtRow:i Column:j];
            if (square.toBeRemove == YES && square.isSpecial) {
                for (int k = 0; k < matrixSize; k++) {
                    SquareSprite* rowSquare = [self squareAtRow:k Column:j];
                    if (rowSquare.squareType == SignalSquare) {
                        continue;
                    }
                    if (rowSquare.toBeRemove == NO && rowSquare.isSpecial) {
                        needRecurse = YES;
                    }
                    rowSquare.toBeRemove = YES;
                }
                for (int k = 0; k < matrixSize; k++) {
                    SquareSprite* columnSquare = [self squareAtRow:i Column:k];
                    if (columnSquare.squareType == SignalSquare) {
                        continue;
                    }
                    if (columnSquare.toBeRemove == NO && columnSquare.isSpecial) {
                        needRecurse = YES;
                    }
                    columnSquare.toBeRemove = YES;
                }
            }
        }
    }
    if (needRecurse) {
        [self checkSpecial];
    }
}

-(void) scanSquares
{
    //prevent visible squares appear
    for (int i = 0; i < matrixSize; i++) {
        for (int j = 0; j < matrixSize; j++) {
            CGPoint horizontal = [self existHorizontalChainAt:i Column:j];
            CGPoint vertical = [self existVerticalChainAt:i Column:j];
            if (horizontal.y - horizontal.x + 1 >= 3) {
                for (int k = horizontal.x; k <= horizontal.y; k++) {
                    SquareSprite* square = [self squareAtRow:i Column:k];
                    square.toBeRemove = YES;
                    needFill = YES;
                }
                if (!isInit && horizontal.y - horizontal.x + 1 >= 5) {
                    if (squareSrc.x == i) {
                        [self squareAtRow:squareSrc.x Column:squareSrc.y].generateSignal = YES;
                    }else if (squareDest.x == i) {
                        [self squareAtRow:squareDest.x Column:squareDest.y].generateSignal = YES;
                    }else {
                        [self squareAtRow:i Column:horizontal.y].generateSignal = YES;
                    }
                }else if (!isInit && horizontal.y - horizontal.x + 1 == 4){
                    if (squareSrc.x == i) {
                        [self squareAtRow:squareSrc.x Column:squareSrc.y].generateSpecial = YES;
                    }else if (squareDest.x == i) {
                        [self squareAtRow:squareDest.x Column:squareDest.y].generateSpecial = YES;
                    }else {
                        [self squareAtRow:i Column:horizontal.y].generateSpecial = YES;
                    }
                }
            }
            if (vertical.y - vertical.x + 1 >= 3) {
                for (int k = vertical.x; k <= vertical.y; k++) {
                    SquareSprite* square = [self squareAtRow:k Column:j];
                    square.toBeRemove = YES;
                    needFill = YES;
                }
                if (!isInit && vertical.y - vertical.x + 1 >= 5) {
                    if (squareSrc.y == j) {
                        [self squareAtRow:squareSrc.x Column:squareSrc.y].generateSignal = YES;
                    }else if (squareDest.y == j){
                        [self squareAtRow:squareDest.x Column:squareDest.y].generateSignal = YES;
                    }else{
                        [self squareAtRow:vertical.x Column:j].generateSignal = YES;
                    }
                }else if (!isInit && vertical.y - vertical.x + 1 == 4){
                    if (squareSrc.y == j) {
                        [self squareAtRow:squareSrc.x Column:squareSrc.y].generateSpecial = YES;
                    }else if (squareDest.y == j){
                        [self squareAtRow:squareDest.x Column:squareDest.y].generateSpecial = YES;
                    }else{
                        [self squareAtRow:vertical.x Column:j].generateSpecial = YES;
                    }
                }
            }
            //eliminate SignalSquare!!!!!!
            SquareSprite* square = [self squareAtRow:i Column:j];
            if (i == 0 && square.squareType == SignalSquare) {
                square.toBeRemove = YES;
                needFill = YES;
            }
        }
    }
    if (isInit && !needFill) {
        isInit = NO;
        return;
    }
    if (needFill) {
        [self checkSpecial];
        [self removeSquare];
    }
}

-(void) removeSquare
{
    for (int i = 0; i < matrixSize; i++) {
        for (int j = 0; j < matrixSize; j++) {
            SquareSprite* square = [self squareAtRow:i Column:j];
            if (square.toBeRemove == YES) {
                
                //add to removeArray except special to be generate
                if (!isInit && square.visible == YES) {
                    [removing addObject:square];
                }
            }
        }
    }
    [self removeAnimate];
    [self fillVacancies];
}

-(void) recycle
{
    SquareSprite* square;
    CCARRAY_FOREACH(removing, square)
    {
        if ([square numberOfRunningActions] == 0) {
            square.generateSignal = NO;
            square.generateSpecial = NO;
            square.isSpecial = NO;
            square.scale = 1;
            square.visible = NO;
            [removing removeObject:square];
        }
    }
    if (removing.count == 0) {
        isRemoving = NO;
    }
    CCSprite* sprite;
    CCARRAY_FOREACH(usedSprites, sprite)
    {
        if ([sprite numberOfRunningActions] == 0) {
            sprite.visible = NO;
            sprite.scale = 1;
            [usedSprites removeObject:sprite];
        }
    }
}

-(void) fillVacancies
{
    if (isRemoving) {
        return;
    }
    isAnimating = YES;
    for (int j = 0; j < matrixSize; j++) {
        int vacancies = 0;
        CCArray* colum = (CCArray*)[matrix objectAtIndex:j];
        for (int i = 0; i < colum.count ; i++) {
            SquareSprite* square = (SquareSprite*)[colum objectAtIndex:i];
            if (square.toBeRemove == YES) {
                
                //update status
                if (!isInit && square.toBeRemove == YES) {
                    if (square.squareType == FoodSquare) {
                        time += 3;
                    }
                    if (square.squareType == Electriciysquare) {
                        electricity++;
                    }
                    if (square.squareType == HeatSquare) {
                        temperature++;
                    }
                    if (square.squareType == SignalSquare) {
                        signal++;
                    }
                    if (square.squareType == FoodSquare) {
                        NSMutableArray* frames = [NSMutableArray arrayWithCapacity:3];
                        for (int i = 0; i < 3; i++) {
                            NSString* file = [NSString stringWithFormat:@"eat%i.png", i+1];
                            CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
                            [frames addObject:frame];
                        }
                        [frames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"astronaut.png"]];
                        CCAnimation* anim = [CCAnimation animationWithSpriteFrames:frames delay:0.2f];
                        eat = [CCAnimate actionWithAnimation:anim];
                        [astronaut runAction:eat];
                    }
                }
                CCLOG(@"!!!time: %f", time);
                CCLOG(@"!!!temperature: %i", temperature);
                CCLOG(@"!!!electricity: %i", electricity);
                CCLOG(@"!!!signal: %i", signal);
                
                vacancies++;
                square.toBeRemove = NO;
                if (square.generateSignal == YES) {
                    square.generateSignal = NO;
                    [square setType:SignalSquare canMove:YES isSpecial:NO];
                    square.visible = YES;
                    square.scale = 1;
                    vacancies--;
                }else if (square.generateSpecial == YES){
                    square.generateSpecial = NO;
                    [square setType:square.squareType canMove:YES isSpecial:YES];
                    square.visible = YES;
                    square.scale = 1;
                    vacancies--;
                }else {
                    [colum removeObjectAtIndex:i];
                    square.isUsing = NO;
                }
                i--;
            }else if (!isInit && vacancies > 0){
                CGPoint endPoint = [self positionOfItemAtRow:i Column:j];
                float duration = 0.1 * vacancies;
                [square stopAllActions];
                [square runAction:[CCEaseInOut actionWithAction:[CCMoveTo actionWithDuration:duration position:endPoint] rate:3]];
            }
        }
        for (int k = 0; k < vacancies ; k++) {
            int type = arc4random() % (MAXSquare - 1);
            [self createAtRow:matrixSize - vacancies + k Column:j WithType:type canMove:YES isSpecial:NO];
            if (!isInit) {
                [self dropSquareAtRow:matrixSize - vacancies + k Column:j From:[self positionOfItemAtRow:matrixSize + k Column:j]];
            }
        }
    }
    needFill = NO;
    squareSrc = ccp(-1, -1);
    squareDest = ccp(-1, -1);
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [GameScene locationFromTouch:touch];
    BOOL isTouchHandled = CGRectContainsPoint(boundingBox, touchLocation);
    if (isTouchHandled) {
        squareSrc = [self squareAtPoint:touchLocation];
        isTouchEnable = YES;
    }
    return isTouchHandled;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (squareSrc.x == -1 || squareSrc.y == -1 || !isTouchEnable) {
        return;
    }
    CGPoint touchLocation = [GameScene locationFromTouch:touch];
    int row = squareSrc.x;
    int column = squareSrc.y;
    CGRect upRect = [self rectAtRow:row + 1 Column:column];
    CGRect downRect = [self rectAtRow:row - 1 Column:column];
    CGRect leftRect = [self rectAtRow:row Column:column - 1];
    CGRect rightRect = [self rectAtRow:row Column:column + 1];
    if (CGRectContainsPoint(upRect, touchLocation)) {
        if (row + 1 < matrixSize) {
            squareDest = ccp(row + 1, column);
            [self swapSquare];
            CCLOG(@"~~~~to (%i, %i)", row + 1, column);
            return;
        }
    }
    if (CGRectContainsPoint(downRect, touchLocation)) {
        if (row - 1 >= 0) {
            squareDest = ccp(row - 1, column);
            [self swapSquare];
            CCLOG(@"~~~~to (%i, %i)", row - 1, column);
            return;
        }
    }
    if (CGRectContainsPoint(leftRect, touchLocation)) {
        if (column - 1 >= 0) {
            squareDest = ccp(row, column - 1);
            [self swapSquare];
            CCLOG(@"~~~~to (%i, %i)", row, column - 1);
            return;
        }
    }
    if (CGRectContainsPoint(rightRect, touchLocation)) {
        if (column + 1 < matrixSize) {
            squareDest = ccp(row, column + 1);
            [self swapSquare];
            CCLOG(@"~~~~to (%i, %i)", row, column + 1);
            return;
        }
    }
}

-(CGPoint) squareAtPoint:(CGPoint)location
{
    float left = boundingBox.origin.x;
    float width = boundingBox.size.width;
    float bottom = boundingBox.origin.y;
    float height= boundingBox.size.height;
    int column = (location.x - left) / (width / matrixSize);
    int row = (location.y - bottom) / (height / matrixSize);
    CCLOG(@"row: %i, column: %i", row, column);
    return ccp(row, column);
}

-(CGRect) rectAtRow:(int)row Column:(int)column
{
    float left = boundingBox.origin.x;
    float width = boundingBox.size.width;
    float bottom = boundingBox.origin.y;
    float height= boundingBox.size.height;
    float originX = left + column * (width / matrixSize);
    float originY = bottom + row * (height / matrixSize);
    return CGRectMake(originX, originY, (width / matrixSize), (height / matrixSize));
}

-(void) swapSquare
{
    if (isRemoving || isAnimating || squareSrc.x == -1 || squareDest.x == -1) {
        return;
    }
    isAnimating = YES;
    isTouchEnable = NO;
    
    CCArray* srcColumn = (CCArray*)[matrix objectAtIndex:squareSrc.y];
    CCArray* destColumn = (CCArray*)[matrix objectAtIndex:squareDest.y];
    SquareSprite* src = (SquareSprite*)[srcColumn objectAtIndex:squareSrc.x];
    SquareSprite* dest = (SquareSprite*)[destColumn objectAtIndex:squareDest.x];
    if (!src.canMove || !dest.canMove) {
        return;
    }
    [srcColumn removeObjectAtIndex:squareSrc.x];
    [srcColumn insertObject:dest atIndex:squareSrc.x];
    [destColumn removeObjectAtIndex:squareDest.x];
    [destColumn insertObject:src atIndex:squareDest.x];
    
    CGPoint horizontalSrc = [self existHorizontalChainAt:squareSrc.x Column:squareSrc.y];
    CGPoint verticalSrc = [self existVerticalChainAt:squareSrc.x Column:squareSrc.y];
    CGPoint horizontalDest = [self existHorizontalChainAt:squareDest.x Column:squareDest.y];
    CGPoint verticalDest = [self existVerticalChainAt:squareDest.x Column:squareDest.y];
    if (horizontalSrc.y - horizontalSrc.x + 1 >= 3 || verticalSrc.y - verticalSrc.x + 1 >= 3 || horizontalDest.y - horizontalDest.x + 1 >= 3 || verticalDest.y - verticalDest.x + 1 >= 3) {
        //valid movement
        temperature--;
        CCMoveTo* moveSrc = [CCMoveTo actionWithDuration:0.4 position:[self positionOfItemAtRow:squareDest.x Column:squareDest.y]];
        CCMoveTo* moveDest = [CCMoveTo actionWithDuration:0.4 position:[self positionOfItemAtRow:squareSrc.x Column:squareSrc.y]];
        [src runAction:[CCEaseInOut actionWithAction:moveSrc rate:3]];
        [dest runAction:[CCEaseInOut actionWithAction:moveDest rate:3]];
    }else{
        //invalid movement
        [srcColumn removeObjectAtIndex:squareSrc.x];
        [srcColumn insertObject:src atIndex:squareSrc.x];
        [destColumn removeObjectAtIndex:squareDest.x];
        [destColumn insertObject:dest atIndex:squareDest.x];
        
        CCMoveTo* moveSrc = [CCMoveTo actionWithDuration:0.4 position:[self positionOfItemAtRow:squareDest.x Column:squareDest.y]];
        CCMoveTo* moveDest = [CCMoveTo actionWithDuration:0.4 position:[self positionOfItemAtRow:squareSrc.x Column:squareSrc.y]];
        CCMoveTo* moveSrcBack = [CCMoveTo actionWithDuration:0.3 position:[self positionOfItemAtRow:squareSrc.x Column:squareSrc.y]];
        CCMoveTo* moveDestBack = [CCMoveTo actionWithDuration:0.3 position:[self positionOfItemAtRow:squareDest.x Column:squareDest.y]];
        CCSequence* SrcSequence = [CCSequence actions:moveSrc, moveSrcBack, nil];
        CCSequence* DestSequence = [CCSequence actions:moveDest, moveDestBack, nil];
        [src runAction:[CCEaseInOut actionWithAction:SrcSequence rate:3]];
        [dest runAction:[CCEaseInOut actionWithAction:DestSequence rate:3]];
    }
}

-(void) update:(ccTime)delta
{
    time -= delta;
    if (isAnimating) {
        isAnimating = NO;
        for (int i = 0; i < matrixSize; i++) {
            for (int j = 0; j < matrixSize; j++) {
                SquareSprite* square = [self squareAtRow:i Column:j];
                if ([square numberOfRunningActions] > 0) {
                    isAnimating = YES;
                    break;
                }
            }
        }
        //CCLOG(@"is animating");
    }
    if (!isInit && !isAnimating) {
        [self scanSquares];
        if (![self isAvailable]) {
            //no square can be move to remove
            [self resetSquares];
        }
        [self recycle];
        //CCLOG(@"is not animating");
    }
}

-(void) dealloc
{
    [squares release];
    [matrix release];
    [removing release];
    [usedSprites release];
    [lineSprites release];
    [super dealloc];
}
@end