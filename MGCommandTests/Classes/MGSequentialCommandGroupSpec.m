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

#import "Kiwi.h"
#import "MGSequentialCommandGroup.h"
#import "CommandFixture.h"

SPEC_BEGIN(MGSequentialCommandGroupSpec)

describe(@"MGSequentialCommandGroup", ^
{
	__block MGSequentialCommandGroup *sequentialCommandGroup;

	beforeEach(^
	{
		COMMAND_CALL_COUNT = 0;
		sequentialCommandGroup = [[MGSequentialCommandGroup alloc] init];
	});

	context(@"with two commands added", ^
	{
		__block AsyncTestCommand *command1 = [[AsyncTestCommand alloc] init];
		__block AsyncDirectFinishTestCommand *command2 = [[AsyncDirectFinishTestCommand alloc] init];
		__block TestCommand *command3 = [[TestCommand alloc] init];

		beforeEach(^
		{
			[sequentialCommandGroup addCommand:command1];
			[sequentialCommandGroup addCommand:command2];
			[sequentialCommandGroup addCommand:command3];
		});

		it(@"should execute commands one after the other", ^
		{
			id mockReceiver = [KWMock mock];

			sequentialCommandGroup.callback = ^
			{
				[mockReceiver performSelector:@selector(testCall)];
			};

			[sequentialCommandGroup execute];

			[[mockReceiver shouldEventuallyBeforeTimingOutAfter(1)] receive:@selector(testCall)];
			[[theValue(command1.callCount) shouldEventuallyBeforeTimingOutAfter(1)] equal:theValue(0)];
			[[theValue(command2.callCount) shouldEventuallyBeforeTimingOutAfter(2)] equal:theValue(1)];
			[[theValue(command3.callCount) shouldEventuallyBeforeTimingOutAfter(3)] equal:theValue(2)];
		});

		it(@"should work without callback beeing set", ^
		{
			[sequentialCommandGroup execute];
		});
	});

	context(@"with nested command group", ^
	{
		__block MGSequentialCommandGroup *commandGroup = [[MGSequentialCommandGroup alloc] init];
		__block TestCommand *subCommandA = [[TestCommand alloc] init];
		__block TestCommand *subCommandB = [[TestCommand alloc] init];

		__block AsyncTestCommand *command1 = [[AsyncTestCommand alloc] init];
		__block TestCommand *command2 = [[TestCommand alloc] init];

		beforeEach(^
		{
			[commandGroup addCommand:subCommandA];
			[commandGroup addCommand:subCommandB];

			[sequentialCommandGroup addCommand:commandGroup];
			[sequentialCommandGroup addCommand:command1];
			[sequentialCommandGroup addCommand:command2];
		});

		it(@"should execute all tasks in order", ^
		{
			id mockReceiver = [KWMock mock];

			sequentialCommandGroup.callback = ^
			{
				[mockReceiver performSelector:@selector(testCall)];
			};

			[sequentialCommandGroup execute];

			[[mockReceiver shouldEventuallyBeforeTimingOutAfter(1)] receive:@selector(testCall)];
			[[theValue(subCommandA.callCount) shouldEventuallyBeforeTimingOutAfter(1)] equal:theValue(0)];
			[[theValue(subCommandB.callCount) shouldEventuallyBeforeTimingOutAfter(1)] equal:theValue(1)];
			[[theValue(command1.callCount) shouldEventuallyBeforeTimingOutAfter(1)] equal:theValue(5)];
			[[theValue(command2.callCount) shouldEventuallyBeforeTimingOutAfter(1)] equal:theValue(6)];
		});
	});
});

SPEC_END