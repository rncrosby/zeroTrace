#import "SignatureDrawView.h"

@implementation SignatureDrawView

@synthesize theSwipeGesture;
@synthesize drawImage;
@synthesize lastPoint;
@synthesize mouseSwiped;
@synthesize mouseMoved;

#pragma mark - View lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder]))
    {
        drawImage = [[UIImageView alloc] initWithImage:nil];
        drawImage.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self addSubview:drawImage];
        self.backgroundColor = [UIColor whiteColor];
        mouseMoved = 0;
    }
    return self;
}

#pragma mark touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches)
    {
        NSArray *array = touch.gestureRecognizers;
        for (UIGestureRecognizer *gesture in array)
        {
            if (gesture.enabled & [gesture isMemberOfClass:[UISwipeGestureRecognizer class]])
            {
                gesture.enabled = NO;
                self.theSwipeGesture = gesture;
            }
        }
    }
    
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    
    lastPoint = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    mouseSwiped = YES;
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    
    UIGraphicsBeginImageContext(self.frame.size);
    [drawImage.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 3.0);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    drawImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
    
    mouseMoved++;
    
    if (mouseMoved == 10) {
        mouseMoved = 0;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!mouseSwiped)
    {
        UIGraphicsBeginImageContext(self.frame.size);
        [drawImage.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 3.0);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        drawImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    self.theSwipeGesture.enabled = YES;
    mouseSwiped = YES;
}

#pragma mark Methods

- (void)erase
{
    mouseSwiped = NO;
    drawImage.image = nil;
}

- (void)setSignature:(NSData *)theLastData
{
    UIImage *image = [UIImage imageWithData:theLastData];
    if (image != nil)
    {
        drawImage.image = [UIImage imageWithData:theLastData];
        mouseSwiped = YES;
    }
}

- (BOOL)isSignatureWrite
{
    return mouseSwiped;
}

@end
