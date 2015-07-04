//
//  PJAppDelegate.m
//  PJLinkCocoaServer
//
//  Created by Eric Hyche on 5/7/13.
//  Copyright (c) 2013 Eric Hyche. All rights reserved.
//

#import "PJAppDelegate.h"
#import "PJLinkServer.h"
#import "PJProjector.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "PJAMXBeaconSource.h"
#import "PJInputOption.h"

@interface PJAppDelegate()
{
    PJLinkServer* _server;
}

@end

@implementation PJAppDelegate

- (PJLinkServer*) server {
    if (_server == nil) {
        _server = [[PJLinkServer alloc] init];
    }

    return _server;
}

- (PJProjector*)projector {
    return [PJProjector sharedProjector];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
    // Clear out the popup button content
    [self.inputsPopUpButton removeAllItems];
    // Populate the popup button
    NSUInteger inputsCount = [self.projector countOfInputs];
    for (NSUInteger i = 0; i < inputsCount; i++) {
        PJInputOption* ithInputOption = (PJInputOption*)[self.projector objectInInputsAtIndex:i];
        [self.inputsPopUpButton addItemWithTitle:ithInputOption.name];
    }
}

- (IBAction)powerStatusSegmentedControlChanged:(id)sender {
    NSLog(@"powerStatusSegmentedControlChanged:%@", sender);
    self.projector.powerStatus = self.powerStatusSegmentedControl.selectedSegment;
}

- (IBAction)inputTypeSegmentedControlChanged:(id)sender {
    NSLog(@"inputTypeSegmentedControlChanged:%@", sender);
}

- (IBAction)inputNumberSegmentedControlChanged:(id)sender {
    NSLog(@"inputNumberSegmentedControlChanged:%@", sender);
}

- (IBAction)avMuteSegmentedControlChanged:(id)sender {
    NSLog(@"avMuteSegmentedControlChanged:%@", sender);
}

- (IBAction)fanErrorSegmentedControlChanged:(id)sender {
    NSLog(@"fanErrorSegmentedControlChanged:%@", sender);
}

- (IBAction)lampErrorSegmentedControlChanged:(id)sender {
    NSLog(@"lampErrorSegmentedControlChanged:%@", sender);
}

- (IBAction)temperatureErrorSegmentedControl:(id)sender {
    NSLog(@"temperatureErrorSegmentedControl:%@", sender);
}

- (IBAction)coverOpenErrorSegmentedControlChanged:(id)sender {
    NSLog(@"coverOpenErrorSegmentedControlChanged:%@", sender);
}

- (IBAction)filterErrorSegmentedControlChanged:(id)sender {
    NSLog(@"filterErrorSegmentedControlChanged:%@", sender);
}

- (IBAction)otherErrorSegmentedControlChanged:(id)sender {
    NSLog(@"otherErrorSegmentedControlChanged:%@", sender);
}

- (IBAction)numberOfLampsSegmentedControlChanged:(id)sender {
    NSLog(@"numberOfLampsSegmentedControlChanged:%@", sender);
    BOOL lamp1Enabled = (self.numberOfLampsSegmentedControl.selectedSegment >= 1 ? YES : NO);
    BOOL lamp2Enabled = (self.numberOfLampsSegmentedControl.selectedSegment >= 2 ? YES : NO);
    [self.lamp1SegmentedControl setEnabled:lamp1Enabled];
    [self.lamp2SegmentedControl setEnabled:lamp2Enabled];
    [self.lamp1TextField setEnabled:lamp1Enabled];
    [self.lamp2TextField setEnabled:lamp2Enabled];
}

- (IBAction)lamp0SegmentedControlChanged:(id)sender {
    NSLog(@"lamp0SegmentedControlChanged:%@", sender);
}

- (IBAction)lamp1SegmentedControlChanged:(id)sender {
    NSLog(@"lamp1SegmentedControlChanged:%@", sender);
}

- (IBAction)lamp2SegmentedControlChanged:(id)sender {
    NSLog(@"lamp2SegmentedControlChanged:%@", sender);
}

- (IBAction)lamp0TextFieldChanged:(id)sender {
    NSLog(@"lamp0TextFieldChanged:%@", sender);
}

- (IBAction)lamp1TextFieldChanged:(id)sender {
    NSLog(@"lamp1TextFieldChanged:%@", sender);
}

- (IBAction)lamp2TextFieldChanged:(id)sender {
    NSLog(@"lamp2TextFieldChanged:%@", sender);
}

- (IBAction)projectorNameTextFieldChanged:(id)sender {
    NSLog(@"projectorNameTextFieldChanged:%@", sender);
}

- (IBAction)manufacturerNameTextFieldChanged:(id)sender {
    NSLog(@"manufacturerNameTextFieldChanged:%@", sender);
}

- (IBAction)productNameTextFieldChanged:(id)sender {
    NSLog(@"productNameTextFieldChanged:%@", sender);
}

- (IBAction)otherInfoTextFieldChanged:(id)sender {
    NSLog(@"otherInfoTextFieldChanged:%@", sender);
}

- (IBAction)class2CheckButtonChanged:(id)sender {
    NSLog(@"class2CheckButtonChanged:%@", sender);
}

- (IBAction)useAuthenticationCheckButton:(id)sender {
    NSLog(@"useAuthenticationCheckButton:%@", sender);
}

- (IBAction)passwordTextFieldChanged:(id)sender {
    NSLog(@"passwordTextFieldChanged:%@", sender);
}

- (IBAction)startStopButtonPressed:(id)sender {
    NSLog(@"startStopButtonPressed:%@", sender);

    if (self.server.isRunning) {
        [self.server stop];
        [[PJAMXBeaconSource sharedSource] stop];
        self.startStopButton.title = @"Start Server";
    } else {
        NSError* startError = nil;
        BOOL result = [self.server start:&startError];
        if (result) {
            self.startStopButton.title = @"Stop Server";
        } else {
            NSLog(@"Error starting server = %@", startError);
        }
        NSError* beaconStartError = nil;
        result = [[PJAMXBeaconSource sharedSource] start:&beaconStartError];
        if (!result) {
            NSLog(@"Error starting AMX Beacon source, error = %@", beaconStartError);
        }
    }
}

#pragma mark - PJAppDelegate private methods

@end
