/* Controller */

#import <Cocoa/Cocoa.h>
#import "SnmpSession.h"

@interface Controller : NSObject
{
	NSUserDefaults *defaults;
    IBOutlet id statusField;
	IBOutlet id f1StatusButton;
	IBOutlet id f2StatusButton;
	IBOutlet id f3StatusButton;
	IBOutlet id f1Standard;
	IBOutlet id f2Standard;
	IBOutlet id f3Standard;
	IBOutlet id f1AspectPopUp;
	IBOutlet id f2AspectPopUp;
	IBOutlet id f3AspectPopUp;
	IBOutlet id f1GlSourcePopUp;
	IBOutlet id f2GlSourcePopUp;
	IBOutlet id f3GlSourcePopUp;
	IBOutlet id tGOutputSignalPopUp;
	IBOutlet id tGOutputFormatPopUp;
	IBOutlet id tGOutputColorSpaceMatrix;
	IBOutlet id tGOutputModeMatrix;
	SnmpSession *session;
	NSDictionary *videoStandards;
	NSArray *videoFormats;
	NSArray *aspectRatios;
	NSArray *glSource;
}
- (IBAction)f1Status:(id)sender;
- (IBAction)f1aspectRatio:(id)sender;
- (IBAction)f1GlSource:(id)sender;
- (IBAction)f2Status:(id)sender;
- (IBAction)f2aspectRatio:(id)sender;
- (IBAction)f2GlSource:(id)sender;
- (IBAction)f3Status:(id)sender;
- (IBAction)f3aspectRatio:(id)sender;
- (IBAction)f3GlSource:(id)sender;
- (IBAction)tGOutputSignal:(id)sender;
- (IBAction)tGOutputFormat:(id)sender;
- (IBAction)tGOutputColorSpace:(id)sender;
- (IBAction)tGOutputMode:(id)sender;
- (void)loadVideoFormats;
- (void)getVideoStandards;
- (void)getAspectRatios;
- (void)getGlSource;
- (void)update;
- (void)doUpdate;
- (void)getTestSignals;
@end
