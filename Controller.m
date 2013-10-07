#import "Controller.h"

@implementation Controller

NSTimer * updateTimer;
int numberOfSignals;
int numberOfCfImages;

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:
	(NSApplication *)theApplication {
    return YES;
}

- (void)awakeFromNib
{
	defaults = [NSUserDefaults standardUserDefaults];
    [[statusField window]setFrameAutosaveName:@"controllerWindow"];	// save and restore the location of the window
	[session release];
	session = [[SnmpSession alloc] initWithHost:@"evertz-frame-2.filmworkers.com"
									  community:@"private"];
	if (nil == session)
	{
		[statusField setStringValue:@"Not Connected"];
	}
	[self getVideoStandards];
	[self loadVideoFormats];
	[self getAspectRatios];
	[self getGlSource];
	[self getTestSignals];
	[self update];
	[self doUpdate];
}

- (void)getTestSignals
{
	[tGOutputSignalPopUp removeAllItems];
	numberOfSignals = [[session stringForOid:@"1.3.6.1.4.1.6827.10.129.4.1.1.5.12"]intValue];
	numberOfCfImages = [[session stringForOid:@"1.3.6.1.4.1.6827.10.129.4.7.1.1.12"]intValue];
	int count;
	for (count = 1; count < numberOfSignals + 1; count++)
	{
		NSString *oid = [NSString stringWithFormat:@"1.3.6.1.4.1.6827.10.129.3.2.1.2.%i.12", count];
		NSString *signal = [session stringForOid:oid];
		if (signal)
			[tGOutputSignalPopUp addItemWithTitle:signal];
	}
    for (count = 1; count < numberOfCfImages + 1; count++)
	{
		NSString *oid = [NSString stringWithFormat:@"1.3.6.1.4.1.6827.10.129.3.4.1.2.%i.12", count];
		NSString *signal = [session stringForOid:oid];
		if (signal)
            [tGOutputSignalPopUp addItemWithTitle:signal];
	}
    
}

- (void)getVideoStandards
{
	videoStandards = [NSDictionary dictionaryWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/Resources/vidStdDetected2.plist"]];
    
    if (nil == videoStandards) {
        NSLog (@"Error unable to open vidStdDetected2.plist");
        [videoStandards release];
        [statusField setStringValue:@"ERROR!! unable to open vidStdDetected2.plist"];
    } else [videoStandards retain];
}

- (void)loadVideoFormats
{
	videoFormats = [NSArray arrayWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/Resources/videoFormat.plist"]];
    
    if (nil == videoFormats) {
        NSLog (@"Error unable to open videoFormat.plist");
        [videoFormats release];
        [statusField setStringValue:@"ERROR!! unable to open videoFormat.plist"];
    } else {
		[videoFormats retain];
		[tGOutputFormatPopUp removeAllItems];
		[tGOutputFormatPopUp addItemsWithTitles:videoFormats];
	}
	
}

- (void)getAspectRatios
{
	aspectRatios = [NSArray arrayWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/Resources/aspectRatios.plist"]];
    
    if (nil == aspectRatios) {
        NSLog (@"Error unable to open aspectRatios.plist");
        [aspectRatios release];
        [statusField setStringValue:@"ERROR!! unable to open aspectRatios.plist"];
    } else {
		[aspectRatios retain];
		[f1AspectPopUp removeAllItems];
		[f1AspectPopUp addItemsWithTitles:aspectRatios];
		[f2AspectPopUp removeAllItems];
		[f2AspectPopUp addItemsWithTitles:aspectRatios];
		[f3AspectPopUp removeAllItems];
		[f3AspectPopUp addItemsWithTitles:aspectRatios];
	}
}

- (void)getGlSource
{
	glSource = [NSArray arrayWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/Resources/GLSource.plist"]];
    
    if (nil == glSource) {
        NSLog (@"Error unable to open GLSource.plist");
        [glSource release];
        [statusField setStringValue:@"ERROR!! unable to open GLSource.plist"];
    } else {
		[glSource retain];
		[f1GlSourcePopUp removeAllItems];
		[f1GlSourcePopUp addItemsWithTitles:glSource];
		[f2GlSourcePopUp removeAllItems];
		[f2GlSourcePopUp addItemsWithTitles:glSource];
		[f3GlSourcePopUp removeAllItems];
		[f3GlSourcePopUp addItemsWithTitles:glSource];
	}
}

- (void)update
{
	if (NULL == session)
	{
		NSLog(@"NULL session in update");
		return;
	}
	// Detected Video Standard
	[f1Standard setStringValue:[videoStandards objectForKey:
		[session stringForOid:@"1.3.6.1.4.1.6827.10.74.4.1.1.12.3"]]];
	[f2Standard setStringValue:[videoStandards objectForKey:
		[session stringForOid:@"1.3.6.1.4.1.6827.10.74.4.1.1.12.2"]]];
	[f3Standard setStringValue:[videoStandards objectForKey:
		[session stringForOid:@"1.3.6.1.4.1.6827.10.74.4.1.1.12.4"]]];
	[f1AspectPopUp selectItemAtIndex:[[session stringForOid:@"1.3.6.1.4.1.6827.10.74.3.2.1.1.3"] intValue]-1];
	[f2AspectPopUp selectItemAtIndex:[[session stringForOid:@"1.3.6.1.4.1.6827.10.74.3.2.1.1.2"] intValue]-1];
	[f3AspectPopUp selectItemAtIndex:[[session stringForOid:@"1.3.6.1.4.1.6827.10.74.3.2.1.1.4"] intValue]-1];
	[f1GlSourcePopUp selectItemAtIndex:[[session stringForOid:@"1.3.6.1.4.1.6827.10.74.3.1.1.5.3"] intValue]-1];
	[f2GlSourcePopUp selectItemAtIndex:[[session stringForOid:@"1.3.6.1.4.1.6827.10.74.3.1.1.5.2"] intValue]-1];
	[f3GlSourcePopUp selectItemAtIndex:[[session stringForOid:@"1.3.6.1.4.1.6827.10.74.3.1.1.5.4"] intValue]-1];
	
	int signalNumber = [[session stringForOid:@"1.3.6.1.4.1.6827.10.129.4.1.1.6.12"] intValue] -1;
    [tGOutputSignalPopUp selectItemAtIndex:signalNumber];

	if ([[session stringForOid:@"1.3.6.1.4.1.6827.10.74.3.9.1.1.3"] intValue] == 2)
		[f1StatusButton highlight:YES];
	else
		[f1StatusButton highlight:NO];
    
    if ([[session stringForOid:@"1.3.6.1.4.1.6827.10.74.3.9.1.1.2"] intValue] == 2)
		[f2StatusButton highlight:YES];
	else
		[f2StatusButton highlight:NO];
    
	if ([[session stringForOid:@"1.3.6.1.4.1.6827.10.74.3.9.1.1.4"] intValue] == 2)
		[f3StatusButton highlight:YES];
	else
		[f3StatusButton highlight:NO];

	[tGOutputFormatPopUp selectItemAtIndex:[[session stringForOid:@"1.3.6.1.4.1.6827.10.129.4.1.1.1.12"] intValue]-1];
	[tGOutputColorSpaceMatrix selectCellAtRow:[[session stringForOid:@"1.3.6.1.4.1.6827.10.129.4.1.1.3.12"]
		intValue]-1 column:0];
	int outputMode = [[session stringForOid:@"1.3.6.1.4.1.6827.10.129.4.1.1.4.12"]intValue]-1;
	[tGOutputModeMatrix selectCellAtRow:outputMode column:0];
	if (outputMode)
		[tGOutputColorSpaceMatrix setEnabled:TRUE];
	else
		[tGOutputColorSpaceMatrix setEnabled:FALSE];
	// System Time of day
	[statusField setStringValue:[NSString stringWithFormat:@"Evertz system time %@",[session stringForOid:@"1.3.6.1.4.1.6827.10.17.4.5.0"]]];
}

- (void) doUpdate
{
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self
												 selector:@selector(update) userInfo:Nil repeats:TRUE];
}

- (IBAction)f1Status:(id)sender
{
	if ([[session stringForOid:@"1.3.6.1.4.1.6827.10.74.3.9.1.1.3"] intValue] == 2)
	{
		[session setOidIntValue:@"1.3.6.1.4.1.6827.10.74.3.9.1.1.3" value:1];
	}
	else
	{
		[session setOidIntValue:@"1.3.6.1.4.1.6827.10.74.3.9.1.1.3" value:2];
	}
}

- (IBAction)f2Status:(id)sender
{
	if ([[session stringForOid:@"1.3.6.1.4.1.6827.10.74.3.9.1.1.2"] intValue] == 2)
	{
		[session setOidIntValue:@"1.3.6.1.4.1.6827.10.74.3.9.1.1.2" value:1];
	}
	else
	{
		[session setOidIntValue:@"1.3.6.1.4.1.6827.10.74.3.9.1.1.2" value:2];
	}
}

- (IBAction)f3Status:(id)sender
{
	if ([[session stringForOid:@"1.3.6.1.4.1.6827.10.74.3.9.1.1.4"] intValue] == 2)
	{
		[session setOidIntValue:@"1.3.6.1.4.1.6827.10.74.3.9.1.1.4" value:1];
	}
	else
	{
		[session setOidIntValue:@"1.3.6.1.4.1.6827.10.74.3.9.1.1.4" value:2];
	}
}

- (IBAction)f1aspectRatio:(id)sender
{
	[session setOidIntValue:@"1.3.6.1.4.1.6827.10.74.3.2.1.1.3" value:[sender indexOfSelectedItem]+1];
}

- (IBAction)f2aspectRatio:(id)sender
{
	[session setOidIntValue:@"1.3.6.1.4.1.6827.10.74.3.2.1.1.2" value:[sender indexOfSelectedItem]+1];
}

- (IBAction)f3aspectRatio:(id)sender
{
	[session setOidIntValue:@"1.3.6.1.4.1.6827.10.74.3.2.1.1.4" value:[sender indexOfSelectedItem]+1];
}

- (IBAction)f1GlSource:(id)sender
{
	[session setOidIntValue:@"1.3.6.1.4.1.6827.10.74.3.1.1.5.3" value:[sender indexOfSelectedItem]+1];
}

- (IBAction)f2GlSource:(id)sender
{
	[session setOidIntValue:@"1.3.6.1.4.1.6827.10.74.3.1.1.5.2" value:[sender indexOfSelectedItem]+1];
}

- (IBAction)f3GlSource:(id)sender
{
	[session setOidIntValue:@"1.3.6.1.4.1.6827.10.74.3.1.1.5.4" value:[sender indexOfSelectedItem]+1];
}

- (IBAction)CFOutputSignal:(id)sender
{
}

- (IBAction)tGOutputSignal:(id)sender
{
    int index = [sender indexOfSelectedItem] + 1;
    if (index <= numberOfSignals) {
        [session setOidIntValue:@"1.3.6.1.4.1.6827.10.129.4.1.1.6.12" value:index];
    } else {
        [session setOidIntValue:@"1.3.6.1.4.1.6827.10.129.4.7.1.2.12" value:index - numberOfSignals];
    }
}

- (IBAction)tGOutputFormat:(id)sender
{
	[session setOidIntValue:@"1.3.6.1.4.1.6827.10.129.4.1.1.1.12" value:[sender indexOfSelectedItem]+1];
	[tGOutputSignalPopUp removeAllItems];
	[statusField setStringValue:@"Waiting 7 seconds for the Evertz to restart"];
	[[tGOutputSignalPopUp window]display];
	sleep(7); // Give Evertz some time to wake up after standard change
	[self getTestSignals];
 }

- (IBAction)tGOutputColorSpace:(id)sender
{
	[session setOidIntValue:@"1.3.6.1.4.1.6827.10.129.4.1.1.3.12" value:[sender selectedRow]+1];
	[tGOutputSignalPopUp removeAllItems];
	[statusField setStringValue:@"Waiting 3 seconds for the Evertz to restart"];
	[[tGOutputSignalPopUp window]display];
	sleep(3);
	[self getTestSignals];
}

- (IBAction)tGOutputMode:(id)sender
{
	[session setOidIntValue:@"1.3.6.1.4.1.6827.10.129.4.1.1.4.12" value:[sender selectedRow]+1];
	[tGOutputSignalPopUp removeAllItems];
	[statusField setStringValue:@"Waiting 10 seconds for the Evertz to restart"];
	[[tGOutputSignalPopUp window]display];
	sleep(10); // Give Evertz some time to wake up after mode change
	[self getTestSignals];
}

- (void)_Quit
{
	[NSApp terminate:self];
}

#pragma mark -
#pragma mark ÑNotificationsÑ

- (void)windowWillClose:(NSNotification *)notification
	// this notification kills the whole app if the user closes our only window.
{
    [self _Quit];
}

@end
