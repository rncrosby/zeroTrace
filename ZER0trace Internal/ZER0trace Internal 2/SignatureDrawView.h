#import <UIKit/UIKit.h>

@interface SignatureDrawView : UIView

@property (nonatomic, retain) UIGestureRecognizer *theSwipeGesture;
@property (nonatomic, retain) UIImageView *drawImage;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, assign) BOOL mouseSwiped;
@property (nonatomic, assign) NSInteger mouseMoved;

- (void)erase;
- (void)setSignature:(NSData *)theLastData;
- (BOOL)isSignatureWrite;

@end
