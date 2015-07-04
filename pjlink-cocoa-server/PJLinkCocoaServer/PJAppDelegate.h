//
//  PJAppDelegate.h
//  PJLinkCocoaServer
//
//  Created by Eric Hyche on 5/7/13.
//  Copyright (c) 2013 Eric Hyche. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PJLinkServer;
@class PJProjector;

@interface PJAppDelegate : NSObject <NSApplicationDelegate>

@property(nonatomic,readonly) PJLinkServer* server;
@property(nonatomic,readonly) PJProjector*  projector;

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSPopUpButton* inputsPopUpButton;
@property (weak) IBOutlet NSSegmentedControl *powerStatusSegmentedControl;
@property (weak) IBOutlet NSSegmentedControl *inputTypeSegmentedControl;
@property (weak) IBOutlet NSSegmentedControl *inputNumberSegmentedControl;
@property (weak) IBOutlet NSSegmentedControl *avMuteSegmentedControl;
@property (weak) IBOutlet NSSegmentedControl *fanErrorSegmentedControl;
@property (weak) IBOutlet NSSegmentedControl *lampErrorSegmentedControl;
@property (weak) IBOutlet NSSegmentedControl *temperatureErrorSegmentedControl;
@property (weak) IBOutlet NSSegmentedControl *coverOpenErrorSegmentedControl;
@property (weak) IBOutlet NSSegmentedControl *filterErrorSegmentedControl;
@property (weak) IBOutlet NSSegmentedControl *otherErrorSegmentedControl;
@property (weak) IBOutlet NSSegmentedControl *numberOfLampsSegmentedControl;
@property (weak) IBOutlet NSSegmentedControl *lamp0SegmentedControl;
@property (weak) IBOutlet NSSegmentedControl *lamp1SegmentedControl;
@property (weak) IBOutlet NSSegmentedControl *lamp2SegmentedControl;
@property (weak) IBOutlet NSTextField *lamp0TextField;
@property (weak) IBOutlet NSTextField *lamp1TextField;
@property (weak) IBOutlet NSTextField *lamp2TextField;
@property (weak) IBOutlet NSTextField *projectorNameTextField;
@property (weak) IBOutlet NSTextField *manufacturerNameTextField;
@property (weak) IBOutlet NSTextField *productNameTextField;
@property (weak) IBOutlet NSTextField *otherInfoTextField;
@property (weak) IBOutlet NSButton *class2CheckButton;
@property (weak) IBOutlet NSButton *useAuthenticationCheckButton;
@property (weak) IBOutlet NSTextField *passwordTextField;
@property (weak) IBOutlet NSButton *startStopButton;
@property (weak) IBOutlet NSScrollView *logScrollView;

- (IBAction)powerStatusSegmentedControlChanged:(id)sender;
- (IBAction)inputTypeSegmentedControlChanged:(id)sender;
- (IBAction)inputNumberSegmentedControlChanged:(id)sender;
- (IBAction)avMuteSegmentedControlChanged:(id)sender;
- (IBAction)fanErrorSegmentedControlChanged:(id)sender;
- (IBAction)lampErrorSegmentedControlChanged:(id)sender;
- (IBAction)temperatureErrorSegmentedControl:(id)sender;
- (IBAction)coverOpenErrorSegmentedControlChanged:(id)sender;
- (IBAction)filterErrorSegmentedControlChanged:(id)sender;
- (IBAction)otherErrorSegmentedControlChanged:(id)sender;
- (IBAction)numberOfLampsSegmentedControlChanged:(id)sender;
- (IBAction)lamp0SegmentedControlChanged:(id)sender;
- (IBAction)lamp1SegmentedControlChanged:(id)sender;
- (IBAction)lamp2SegmentedControlChanged:(id)sender;
- (IBAction)lamp0TextFieldChanged:(id)sender;
- (IBAction)lamp1TextFieldChanged:(id)sender;
- (IBAction)lamp2TextFieldChanged:(id)sender;
- (IBAction)projectorNameTextFieldChanged:(id)sender;
- (IBAction)manufacturerNameTextFieldChanged:(id)sender;
- (IBAction)productNameTextFieldChanged:(id)sender;
- (IBAction)otherInfoTextFieldChanged:(id)sender;
- (IBAction)class2CheckButtonChanged:(id)sender;
- (IBAction)useAuthenticationCheckButton:(id)sender;
- (IBAction)passwordTextFieldChanged:(id)sender;
- (IBAction)startStopButtonPressed:(id)sender;

@end
