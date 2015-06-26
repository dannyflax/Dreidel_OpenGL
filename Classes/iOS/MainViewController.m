/*
     File: MainViewController.m
 Abstract: The main view controller
  Version: 1.6
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 */

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    result = [[UILabel alloc] initWithFrame:CGRectMake(0.0, glView.frame.size.height - 200.0, glView.frame.size.width, 20.0)];
    [result setTextAlignment:NSTextAlignmentCenter];
    [result setFont:[UIFont fontWithName:@"helvetica" size:18.0]];
    [result setTextColor:[UIColor whiteColor]];
    [glView addSubview:result];
    [result setHidden:YES];
    
    isReturning = false;
    isSpinning = false;
    
    glView.dataObj = [GLDataModel new];
    
    [super viewDidLoad];
    
    glView.dataObj.rotationY = 50;
    glView.dataObj.rotationX = 0;
    
    ctrlTimer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(controlLoop) userInfo:nil repeats:YES];
    
       
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeHandle:)];
    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [rightRecognizer setNumberOfTouchesRequired:1];
    
    //add the your gestureRecognizer , where to detect the touch..
    [self.view addGestureRecognizer:rightRecognizer];
    [rightRecognizer release];
    
    UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeHandle:)];
    leftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [leftRecognizer setNumberOfTouchesRequired:1];
    
    [self.view addGestureRecognizer:leftRecognizer];
    [leftRecognizer release];
    
	// Do any additional setup after loading the view.
}

- (void)rightSwipeHandle:(UISwipeGestureRecognizer*)gestureRecognizer
{
    if (!isReturning && !isFalling) {
        startEnergy = -150;
        startRot = glView.dataObj.rotationY;
        glView.dataObj.rotationLetter = [self getRandomLetterRotation];
        isSpinning = true;
        rIterations = 0;
        [result setHidden:YES];
    }
}

- (void)leftSwipeHandle:(UISwipeGestureRecognizer*)gestureRecognizer
{
    if (!isReturning && !isFalling) {
        startEnergy = 150;
        startRot = glView.dataObj.rotationY;
        glView.dataObj.rotationLetter = [self getRandomLetterRotation];
        isSpinning = true;
        rIterations = 0;
        [result setHidden:YES];
    }
}

-(float)getRandomLetterRotation{
    int r = rand()%4;
    lastLetter = r;
    return (float)r*90.0;
}

float dX = 0;
float dY = 0;
float dL = 0;

float iterations = 30.0;
float waitTime = 60.0;

float spinIterations = 60.0;

-(void)controlLoop{
    if (isSpinning) {
        
        int dx = fabsf(glView.dataObj.rotationY - startRot);
        float fricForce = .04;
        float energy = 30.0+fabsf(startEnergy) - dx*fricForce;
        float speed = sqrt(energy);
        
        if (startEnergy > 0) {
            glView.dataObj.rotationY = glView.dataObj.rotationY + speed;
        }
        else{
            glView.dataObj.rotationY = glView.dataObj.rotationY - speed;
        }
        rIterations++;
        
        if (energy <= fabsf(startEnergy)) {
            isFalling = true;
            isSpinning = false;
            startRot = glView.dataObj.rotationY;
        }
    }
    else if (isFalling) {
        
        int dx = fabsf(glView.dataObj.rotationY - startRot);
        float fricForce = .15;
        float energy = fabsf(startEnergy) - dx*fricForce;
        
        if (ABS(energy) < 1) {
            isFalling = false;
            isReturning = true;
            
            float xx = (int)-glView.dataObj.rotationX % 360;
            float yy = (int)-glView.dataObj.rotationY % 360;
            
            xx = xx > 0 ? xx : xx + 360.0;
            yy = yy > 0 ? yy : yy + 360.0;
            
            xx = xx > 180.0 ? (xx - 360) : xx;
            yy = yy > 180.0 ? (yy - 360) : yy;
            
            dX = (xx) / iterations;
            dY = (yy) / iterations;
            dL = 180.0 / iterations;
            
            rIterations = 0;
        }
        else{
            float speed = sqrtf(energy);
            if (startEnergy > 0) {
                glView.dataObj.rotationY = glView.dataObj.rotationY + speed;
            }
            else{
                glView.dataObj.rotationY = glView.dataObj.rotationY - speed;
            }
        }
        
        if (glView.dataObj.rotationX < 90.0) {
            glView.dataObj.rotationX+=.6;
        }
        
    }
    else if(isReturning){
        if (rIterations < waitTime) {
            rIterations++;
        }
        else if (rIterations < iterations + waitTime) {
            glView.dataObj.rotationX+=dX;
            glView.dataObj.rotationY+=dY;
            glView.dataObj.rotationLetter+=dL;
            rIterations++;
        }
        else{
            isReturning = false;
            [self setDisplayToResult:lastLetter];
        }
    }
}

-(void)setDisplayToResult:(int)res{
    [result setHidden:NO];
    NSString *name;
    switch (res) {
        case 0:
            name = @"Nun";
            break;
        case 1:
            name = @"Gimmel";
            break;
        case 2:
            name = @"Shin";
            break;
        case 3:
            name = @"Hay";
            break;
            
        default:
            [result setHidden:YES];
            break;
    }
    [result setText:[NSString stringWithFormat:@"You spun a %@", name]];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!isReturning && !isFalling) {
        glView.dataObj.rotationX = 0.0;
        if ([touches count] == 1) {
            isSpinning = false;
            startRot = glView.dataObj.rotationY;
            startPoint = [[touches anyObject] locationInView:self.view];
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!isReturning && !isFalling) {
        if ([touches count] == 1) {
            CGPoint currentPoint = [[touches anyObject] locationInView:self.view];
            glView.dataObj.rotationY = startRot + (startPoint.x - currentPoint.x)/1.7;
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
