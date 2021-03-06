/*
 * Copyright (c) 2012 Mattes Groeger
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "BlockViewController.h"
#import "MGSequentialCommandGroup.h"
#import "MGAsyncBlockCommand.h"

@implementation BlockViewController

- (void)viewDidLoad
{
	[self animate:[MGSequentialCommandGroup autoStartGroup]];
}

- (void)animate:(MGSequentialCommandGroup *)animation
{
	[self addAnimationStep:animation duration:0.3 scale:2.0];
	[self addAnimationStep:animation duration:0.2 scale:1.5];
	[self addAnimationStep:animation duration:0.1 scale:1.8];
	[self addAnimationStep:animation duration:1.0 scale:1.0];

	__weak __typeof (self) this = self;

	animation.completeHandler = ^
	{
		[this animate:[MGSequentialCommandGroup autoStartGroup]]; // start over
	};
}

- (void)addAnimationStep:(MGSequentialCommandGroup *)animationGroup duration:(CGFloat)duration scale:(CGFloat)scale
{
	[animationGroup addCommand:[MGAsyncBlockCommand create:^(MGCommandCompleteHandler completeHandler) {
		[UIView animateWithDuration:duration
							  delay:0
							options:UIViewAnimationOptionCurveEaseInOut
						 animations:^{
							 _heart.transform = CGAffineTransformMakeScale(scale, scale);
						 }
						 completion:^(BOOL finished) {
							 completeHandler();
						 }];
	}]];
}

@end