//
//	DCOAboutWindowController.m
//	Tapetrap
//
//	Created by Boy van Amstel on 20-01-14.
//	Copyright (c) 2014 Danger Cove. All rights reserved.
//

#import "DCOAboutWindowController.h"

@interface DCOAboutWindowController()

/** The window nib to load. */
+ (NSString *)nibName;

/** The info view. */
@property (assign) IBOutlet NSView *infoView;

/** The credits text view. */
@property (assign) IBOutlet NSTextView *creditsTextView;

/** The button that opens the app's website. */
@property (assign) IBOutlet NSButton *visitWebsiteButton;

/** The button that opens the acknowledgements. */
@property (assign) IBOutlet NSButton *acknowledgementsButton;

@end

@implementation DCOAboutWindowController

#pragma mark - Class Methods

+ (NSString *)nibName {
    return @"DCOAboutWindow";
}

#pragma mark - Overrides

- (id)init {
    return [super initWithWindowNibName:[[self class] nibName]];
}

- (void)windowDidLoad {
    
    // Load variables
    NSDictionary *bundleDict = [[NSBundle mainBundle] infoDictionary];
    
    // Set app name
    if(!self.appName) {
        self.appName = [bundleDict objectForKey:@"CFBundleName"];
    }

    // Set app version
    if(!self.appVersion) {
        NSString *version = [bundleDict objectForKey:@"CFBundleVersion"];
        NSString *shortVersion = [bundleDict objectForKey:@"CFBundleShortVersionString"];
        self.appVersion = [NSString stringWithFormat:@"Version %@ (Build %@)", shortVersion, version];
    }
    
    // Set copyright
    if(!self.appCopyright) {
        self.appCopyright = [bundleDict objectForKey:@"NSHumanReadableCopyright"];
    }

    // Set "visit website" caption
    self.visitWebsiteButton.title = [NSString stringWithFormat:self.visitWebsiteButton.title, self.appName];
    
    // Set acknowledgements
    if(!self.acknowledgementsPath) {
        self.acknowledgementsPath = [[NSBundle mainBundle] pathForResource:@"Acknowledgements" ofType:@"rtf"];
    }

    // Set credits
    if(!self.appCredits) {
		[self loadAppCredits];
    }

    // Disable editing
    [self.creditsTextView setEditable:NO]; // Somehow IB checkboxes are not working
//	  [self.creditsTextView setSelectable:NO]; // Somehow IB checkboxes are not working
    
    // Add border
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = [NSColor grayColor].CGColor;
    [bottomBorder setBorderWidth:1];
    bottomBorder.frame = CGRectMake(-1.f, .0f, CGRectGetWidth(self.infoView.frame) + 2.f, CGRectGetHeight(self.infoView.frame) + 1.f);
    [self.infoView.layer addSublayer:bottomBorder];
}

- (void)loadAppCredits
{
	NSURL *creditsURL = [[NSBundle mainBundle] URLForResource:@"Credits" withExtension:@"rtf"];
	NSError *error = nil;
	NSAttributedString *credits = [[NSAttributedString alloc] initWithURL:creditsURL
																  options:@{}
													   documentAttributes:nil
																	error:&error];

	if (!credits) {
		return;
	}

	NSMutableAttributedString *mutableCredits = [credits mutableCopy];

	[credits enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(0, [credits length]) options:0
					 usingBlock:^(id _Nullable value, NSRange range, BOOL * _Nonnull stop) {
		if (value == nil && range.length > 0) {
			[mutableCredits addAttribute:NSForegroundColorAttributeName value:[NSColor textColor] range:range];
		}
	}];

	self.appCredits = mutableCredits;
}

#pragma mark - Getters/Setters

- (void)setAcknowledgementsPath:(NSString *)acknowledgementsPath {
    _acknowledgementsPath = acknowledgementsPath;
    
    if(!acknowledgementsPath) {
        
        // Remove the button (and constraints)
        [self.acknowledgementsButton removeFromSuperview];
        
    }
}

#pragma mark - Interface Methods

- (IBAction)visitWebsite:(id)sender {
    
    if(self.appWebsiteURL) {
        [[NSWorkspace sharedWorkspace] openURL:self.appWebsiteURL];
    } else {
        NSLog(@"Error: please set the appWebsiteURL property on the about window");
    }
    
}

- (IBAction)showAcknowledgements:(id)sender {
    
    if(self.acknowledgementsPath) {
        
        // Load in default editor
        [[NSWorkspace sharedWorkspace] openFile:self.acknowledgementsPath];
        
    } else {
        NSLog(@"Error: couldn't load the acknowledgements file");
    }
}

@end
