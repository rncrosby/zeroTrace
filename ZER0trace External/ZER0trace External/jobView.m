//
//  jobView.m
//  ZER0trace External
//
//  Created by Robert Crosby on 12/11/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "jobView.h"

@interface jobView ()

@end

@implementation jobView

-(void)viewWillAppear:(BOOL)animated {
    [References cornerRadius:playButton radius:playButton.frame.size.width/2];
    table.backgroundColor = [UIColor clearColor];
    date.text = _job.dateOfDestruction;
    videoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [References screenWidth], [References screenHeight])];
    [self.view addSubview:videoView];
    [self.view sendSubviewToBack:videoView];
    videoPlayer = [[CTVideoView alloc] init];
    videoPlayer.frame = CGRectMake(-10,-10,videoView.frame.size.width+20,(videoView.frame.size.height+20));
    [videoView addSubview:videoPlayer];
    videoPlayer.operationDelegate = self;
    videoPlayer.userInteractionEnabled = NO;
    [videoPlayer setShouldPlayAfterPrepareFinished:NO];
    [videoPlayer setIsMuted:YES];
    NSLog(@"%@",_job.videoURL.absoluteString);
    videoPlayer.videoUrl = _job.videoURL; // mp4 playable
    [videoPlayer prepare];
    videoView.alpha = 0.5;
    [drives setTitle:[NSString stringWithFormat:@"%lu DRIVES",_job.driveTimes.count] forState:UIControlStateNormal];
    [self.view bringSubviewToFront:table];
    timeSincePlaying = 0;
}

-(UIImage *)changeWhiteColorTransparent: (UIImage *)image
{
    CGImageRef rawImageRef=image.CGImage;
    
    CGFloat colorMasking[6] = {222, 255, 222, 255, 222, 255};
    
    UIGraphicsBeginImageContext(image.size);
    CGImageRef maskedImageRef=CGImageCreateWithMaskingColors(rawImageRef, colorMasking);
    {
        //if in iphone
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0, image.size.height);
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    }
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, image.size.width, image.size.height), maskedImageRef);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRelease(maskedImageRef);
    UIGraphicsEndImageContext();
    return result;
}

- (UIImage *)negativeImage:(UIImage*)passedImage
{
    // get width and height as integers, since we'll be using them as
    // array subscripts, etc, and this'll save a whole lot of casting
    CGSize size = passedImage.size;
    int width = size.width;
    int height = size.height;
    
    // Create a suitable RGB+alpha bitmap context in BGRA colour space
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *memoryPool = (unsigned char *)calloc(width*height*4, 1);
    CGContextRef context = CGBitmapContextCreate(memoryPool, width, height, 8, width * 4, colourSpace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colourSpace);
    
    // draw the current image to the newly created context
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), passedImage.CGImage);
    
    // run through every pixel, a scan line at a time...
    for(int y = 0; y < height; y++)
    {
        // get a pointer to the start of this scan line
        unsigned char *linePointer = &memoryPool[y * width * 4];
        
        // step through the pixels one by one...
        for(int x = 0; x < width; x++)
        {
            // get RGB values. We're dealing with premultiplied alpha
            // here, so we need to divide by the alpha channel (if it
            // isn't zero, of course) to get uninflected RGB. We
            // multiply by 255 to keep precision while still using
            // integers
            int r, g, b;
            if(linePointer[3])
            {
                r = linePointer[0] * 255 / linePointer[3];
                g = linePointer[1] * 255 / linePointer[3];
                b = linePointer[2] * 255 / linePointer[3];
            }
            else
                r = g = b = 0;
            
            // perform the colour inversion
            r = 255 - r;
            g = 255 - g;
            b = 255 - b;
            
            // multiply by alpha again, divide by 255 to undo the
            // scaling before, store the new values and advance
            // the pointer we're reading pixel data from
            linePointer[0] = r * linePointer[3] / 255;
            linePointer[1] = g * linePointer[3] / 255;
            linePointer[2] = b * linePointer[3] / 255;
            linePointer += 4;
        }
    }
    
    // get a CG image from the context, wrap that into a
    // UIImage
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    
    // clean up
    CGImageRelease(cgImage);
    CGContextRelease(context);
    free(memoryPool);
    
    // and return
    return returnImage;
}

-(void)videoViewDidFinishPrepare:(CTVideoView *)videoView {
    totalTime.text = [self timeFormatted:videoView.totalDurationSeconds];
    currentTime.text = @"00:00:00";
    [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(videoProgressManager) userInfo:nil repeats:YES];
}

-(void)videoProgressManager {
    if (isPlaying == YES) {
        currentTime.text = [self timeFormatted:videoPlayer.currentPlaySecond];
        float progress = videoPlayer.currentPlaySecond / videoPlayer.totalDurationSeconds;
        NSLog(@"%f",progress);
        [slider setValue:progress animated:YES];
        timeSincePlaying = timeSincePlaying + 1;
    }
    if (timeSincePlaying == 10) {
        int width = playButton.frame.size.width/2;
        [UIView animateWithDuration:0.5 animations:^(void){
            [References cornerRadius:playButton radius:width/2];
            playButton.frame = CGRectMake(playButton.frame.origin.x+(width/2), lowerLine.frame.origin.y-width-8, width, width);
        }];
    }

}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

- (BOOL)shouldAutorotate {
    return NO;
}
- (void)viewDidLoad {
    [playButton setImageEdgeInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:_job.signature]];
    UIImage *image = [self changeWhiteColorTransparent:[UIImage imageWithData:data]];
    [signatureImage setImage:[self negativeImage:image]];
    UILabel *bottomShadow = [[UILabel alloc] initWithFrame:CGRectMake(-50, [References screenHeight], [References screenWidth]+100, 44)];
    bottomShadow.backgroundColor = [UIColor blackColor];
    [References topshadow:bottomShadow];
    [self.view addSubview:bottomShadow];
    [self.view bringSubviewToFront:bottomShadow];
    [self.view bringSubviewToFront:playButton];
    [self.view bringSubviewToFront:slider];
    [self.view bringSubviewToFront:totalTime];
    [self.view bringSubviewToFront:lowerLine];
    [References lightCardShadow:playButton];
    [References cornerRadius:signatureImage radius:12.0f];
    [References lightCardShadow:slider];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _job.driveTimes.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"driveCell";
    
    driveCell *cell = (driveCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"driveCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
//    [cell setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
    cell.serial.text = [(NSString*)_job.driveSerials[indexPath.row] uppercaseString];
    cell.time.text = [self timeFormatted:[_job.driveTimes[indexPath.row] intValue]];
    
    return cell;
}

- (NSString *)timeFormatted:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    if (totalSeconds < 3600) {
        return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    } else {
        return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
    }
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)toggleVisibility:(id)sender {
    [UIView animateWithDuration:0.25 animations:^(void){
        if (videoView.alpha < 1) {
            bottomShadow.alpha = 1;
            signatureImage.alpha = 0;
            signatureHeader.alpha = 0;
            upperLine.alpha = 0;
            driveHead.alpha = 0;
            drivesTitle.alpha = 0;
            table.alpha = 0;
            date.alpha = 0;
            backButton.alpha = 0;
            videoView.alpha = 1;
        } else {
            bottomShadow.alpha = 0;
            signatureImage.alpha = 1;
            signatureHeader.alpha = 1;
            upperLine.alpha = 1;
            driveHead.alpha = 1;
            drivesTitle.alpha = 1;
            table.alpha = 1;
            date.alpha = 1;
            backButton.alpha = 1;
            videoView.alpha = 0.5;
        }
    } completion:^(BOOL completion){
        if (completion) {
            if (videoView.alpha == 1) {
                backButton.enabled = FALSE;
            } else {
                backButton.enabled = TRUE;
            }
        }
    }];
}

- (IBAction)play:(id)sender {
    if (isPlaying == YES) {
        isPlaying = NO;
        [videoPlayer pause];
        [playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        if (timeSincePlaying >= 10) {
            int width = playButton.frame.size.width*2;
            [UIView animateWithDuration:0.5 animations:^(void){
                [References cornerRadius:playButton radius:width/2];
                playButton.frame = CGRectMake(playButton.frame.origin.x-(width/4), ([References screenHeight]/2)-(width/2), width, width);
            }];
        }
        timeSincePlaying = 0;
    } else {
        timeSincePlaying = 0;
        isPlaying = YES;
        [videoPlayer play];
        [playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    }
    [self toggleVisibility:sender];
}

- (IBAction)sliderChange:(id)sender {
    [videoPlayer pause];
    
}
@end
