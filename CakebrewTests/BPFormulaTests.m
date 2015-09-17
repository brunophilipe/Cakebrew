//
//  BPFormulaTests.m
//
//
//  Created by Marek Hrusovsky on 19/08/15.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "BPFormula.h"
#import "BPHomebrewInterface.h"

@interface BPFormulaDataProvider : NSObject <BPFormulaDataProvider>
- (NSString *)informationForFormulaName:(NSString *)name;
@end

@implementation BPFormulaDataProvider

- (NSString *)informationForFormulaName:(NSString *)name
{
	NSString *info = nil;
	if ([name isEqualToString:@"ffmpeg"]) {
		info = [self fileContentForFileName:@"brewInfo_ffmpeg"];
	} else if ([name isEqualToString:@"mysql"]) {
		info = [self fileContentForFileName:@"brewInfo_mysql"];
	} else if ([name isEqualToString:@"percona-server"]) {
		info = [self fileContentForFileName:@"brewInfo_percona-server"];
	} else if ([name isEqualToString:@"bfg"]) {
		info = [self fileContentForFileName:@"brewInfo_bfg"];
	} else if ([name isEqualToString:@"acme"]) {
		info = [self fileContentForFileName:@"brewInfo_acme"];
	} else if ([name isEqualToString:@"fakeformula"]) {
		info = [self fileContentForFileName:@"brewInfo_fakeformula"];
	} else if ([name isEqualToString:@"bison"]) {
		info = [self fileContentForFileName:@"brewInfo_bison"];
	} else if ([name isEqualToString:@"sbtenv"]) {
		info = [self fileContentForFileName:@"brewInfo_sbtenv"];
	}
	
	return info;
}

- (NSString *)fileContentForFileName:(NSString *)fileName
{
	NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:fileName ofType:@"txt"];
	NSString *fileContent;
	fileContent =  [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	return fileContent;
}

@end

@interface BPCustomFormula : BPFormula {
@public
  BOOL observerAdded;
}
- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;
@end

@implementation BPCustomFormula

- (id<BPFormulaDataProvider>)dataProvider
{
	return [[BPFormulaDataProvider alloc] init];
}
- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
			options:(NSKeyValueObservingOptions)options
			context:(void *)context{
  observerAdded = YES;
  [super addObserver:observer forKeyPath:keyPath options:options context:context];
}
@end

static BPCustomFormula *ffmpegFormula;
static BPCustomFormula *mysqlFormula;
static BPCustomFormula *perconaFormula;
static BPCustomFormula *acmeFormula;
static BPCustomFormula *bfgFormula;
static BPCustomFormula *bisonFormula;
static BPCustomFormula *sbtenvFormula;

@interface BPFormulaTests : XCTestCase {
  BPFormula *formula;
}
@end


@implementation BPFormulaTests

+ (void)initialize {
	if (!ffmpegFormula) {
		ffmpegFormula = [BPCustomFormula formulaWithName:@"ffmpeg"];
		[ffmpegFormula setNeedsInformation:YES];
	}
	
	if (!mysqlFormula){
		mysqlFormula = [BPCustomFormula formulaWithName:@"mysql"];
		[mysqlFormula setNeedsInformation:YES];
	}
	if (!perconaFormula) {
		perconaFormula = [BPCustomFormula formulaWithName:@"percona-server"];
		[perconaFormula setNeedsInformation:YES];
	}
	if(!acmeFormula){
		acmeFormula = [BPCustomFormula formulaWithName:@"acme"];
		[acmeFormula setNeedsInformation:YES];
	}
	if(!bfgFormula){
		bfgFormula = [BPCustomFormula formulaWithName:@"bfg"];
		[bfgFormula setNeedsInformation:YES];
	}
	if(!bisonFormula){
		bisonFormula = [BPCustomFormula formulaWithName:@"bison"];
		[bisonFormula setNeedsInformation:YES];
	}
	if(!sbtenvFormula){
		sbtenvFormula = [BPCustomFormula formulaWithName:@"sbtenv"];
		[sbtenvFormula setNeedsInformation:YES];
	}
}

- (void)tearDown {
	[super tearDown];
}

- (void)testFormulaCreation
{
	formula = [BPFormula formulaWithName:@"abcde" version:@"1" andLatestVersion:@"2"];
	XCTAssertNotNil(formula, @"Formula failed to initialize");
	XCTAssertTrue([formula.name isEqualToString:@"abcde"], @"Formula has invalid name");
	XCTAssertTrue([formula.version isEqualToString:@"1"], @"Formula has invalid name");
	XCTAssertTrue([formula.latestVersion isEqualToString:@"2"], @"Formula has invalid name");
}

- (void)testFormulaFullCopy
{
	formula = [BPCustomFormula formulaWithName:@"fakeformula" version:@"1" andLatestVersion:@"2"];
	[formula setNeedsInformation:YES];
	BPFormula *copiedFormula = [formula copy];
	XCTAssertTrue([formula.name isEqualToString:copiedFormula.name] && [copiedFormula.name length] > 0, @"Name failed to copy");
	XCTAssertTrue([formula.version isEqualToString:copiedFormula.version] && [copiedFormula.version length] > 0, @"Version failed to copy");
	XCTAssertTrue([formula.latestVersion isEqualToString:copiedFormula.latestVersion] && [copiedFormula.latestVersion length] > 0, @"LatestVersion failed to copy");
	XCTAssertTrue([[formula.website path] isEqualToString:[copiedFormula.website path]] && [copiedFormula.website.path length] > 0, @"Website failed to copy");
	XCTAssertTrue([formula.shortDescription isEqualToString:copiedFormula.shortDescription] && [copiedFormula.shortDescription length] > 0, @"ShortDescription failed to copy");
	XCTAssertTrue([formula.dependencies isEqualToString:copiedFormula.dependencies] && [copiedFormula.dependencies length] > 0, @"Dependencies failed to copy");
	XCTAssertTrue([formula.conflicts isEqualToString:copiedFormula.conflicts] && [copiedFormula.conflicts length] > 0, @"Conflicts failed to copy");
  	XCTAssertTrue([formula.installPath isEqualToString:copiedFormula.installPath] && [copiedFormula.installPath length] > 0, @"Instal path failed to copy");
  	XCTAssertTrue([formula.information isEqualToString:copiedFormula.information] && [copiedFormula.information length] > 0, @"Console information failed to copy");
	XCTAssertEqual([copiedFormula.options count], 27, @"Number of formula options does not match");
}


- (void)testFormulaConsoleInformation
{
  BPFormulaDataProvider *provider = [[BPFormulaDataProvider alloc] init];
  NSString *ffmpegOutput = [provider informationForFormulaName:@"ffmpeg"];
  XCTAssertEqualObjects(ffmpegFormula.information, ffmpegOutput);
  NSString *mysqlOutput = [provider informationForFormulaName:@"mysql"];
  XCTAssertEqualObjects(mysqlFormula.information, mysqlOutput);
  NSString *acmeOutput = [provider informationForFormulaName:@"acme"];
  XCTAssertEqualObjects(acmeFormula.information, acmeOutput);
  NSString *bfgOutput = [provider informationForFormulaName:@"bfg"];
  XCTAssertEqualObjects(bfgFormula.information, bfgOutput);
  NSString *perconaOutput = [provider informationForFormulaName:@"percona-server"];
  XCTAssertEqualObjects(perconaFormula.information, perconaOutput);
  NSString *bisonOutput = [provider informationForFormulaName:@"bison"];
  XCTAssertEqualObjects(bisonFormula.information, bisonOutput);
  NSString *sbtenvOutput = [provider informationForFormulaName:@"sbtenv"];
  XCTAssertEqualObjects(sbtenvFormula.information, sbtenvOutput);
}

- (void)testFormulaWebsite
{
	XCTAssertEqualObjects(ffmpegFormula.website.absoluteString, @"https://ffmpeg.org/");
	XCTAssertEqualObjects(mysqlFormula.website.absoluteString, @"https://dev.mysql.com/doc/refman/5.6/en/");
	XCTAssertEqualObjects(acmeFormula.website.absoluteString, @"https://web.archive.org/web/20150520143433/https://www.esw-heim.tu-clausthal.de/~marco/smorbrod/acme/");
	XCTAssertEqualObjects(bfgFormula.website.absoluteString, @"https://rtyley.github.io/bfg-repo-cleaner/");
	XCTAssertEqualObjects(perconaFormula.website.absoluteString, @"https://www.percona.com");
	XCTAssertEqualObjects(bisonFormula.website.absoluteString, @"https://www.gnu.org/software/bison/");
	XCTAssertEqualObjects(sbtenvFormula.website.absoluteString, @"https://github.com/mazgi/sbtenv");
}

- (void)testFormulaConflicts
{
	XCTAssertEqualObjects(mysqlFormula.conflicts, @"mariadb, mysql-cluster, mysql-connector-c, percona-server");
	XCTAssertEqualObjects(perconaFormula.conflicts, @"mariadb, mysql, mysql-cluster, mysql-connector-c, mysql-connector-c");
}

- (void)testFormulaNilConflicts
{
	XCTAssertNil(ffmpegFormula.conflicts);
	XCTAssertNil(acmeFormula.conflicts);
	XCTAssertNil(bfgFormula.conflicts);
	XCTAssertNil(bisonFormula.conflicts);
	XCTAssertNil(sbtenvFormula.conflicts);
}

- (void)testFormulaDependencies
{
	XCTAssertEqualObjects(ffmpegFormula.dependencies, @"Build: pkg-config ✔, texi2html ✘, yasm ✘; Recommended: x264 ✘, lame ✘, libvo-aacenc ✘, xvid ✘; Optional: faac ✘, fontconfig ✘, freetype ✘, theora ✘, libvorbis ✘, libvpx ✘, rtmpdump ✘, opencore-amr ✘, libass ✘, openjpeg ✘, speex ✘, schroedinger ✘, fdk-aac ✘, opus ✘, frei0r ✘, libcaca ✘, libbluray ✘, libsoxr ✘, libquvi ✘, libvidstab ✘, x265 ✘, openssl ✘, libssh ✘, webp ✘, zeromq ✘");
	XCTAssertEqualObjects(mysqlFormula.dependencies, @"Build: cmake ✘; Required: openssl ✘");
	XCTAssertEqualObjects(perconaFormula.dependencies, @"Build: cmake ✘; Required: openssl ✘");
}

- (void)testFormulaNilDependencies
{
	XCTAssertNil(acmeFormula.dependencies);
	XCTAssertNil(bfgFormula.dependencies);
	XCTAssertNil(bisonFormula.dependencies);
	XCTAssertNil(sbtenvFormula.dependencies);
}

- (void)testFormulaShortDescription
{
	XCTAssertEqualObjects(ffmpegFormula.shortDescription, @"Play, record, convert, and stream audio and video");
	XCTAssertEqualObjects(mysqlFormula.shortDescription, @"Open source relational database management system");
	XCTAssertEqualObjects(acmeFormula.shortDescription, @"Crossassembler for multiple environments");
	XCTAssertEqualObjects(bfgFormula.shortDescription, @"Removes large files or passwords from Git history like git-filter-branch does, but faster.");
	XCTAssertEqualObjects(perconaFormula.shortDescription, @"Drop-in MySQL replacement");
	XCTAssertEqualObjects(bisonFormula.shortDescription, @"Parser generator");
}

- (void)testFormulaWithoutShortDescription
{
	XCTAssertNil(sbtenvFormula.shortDescription);
}

- (void)testFormulaInstallPath
{
	XCTAssertEqualObjects(mysqlFormula.installPath, @"/usr/local/Cellar/mysql/5.6.21 (9621 files, 339M) *");
}

- (void)testFormulaNilInstallPath
{
	XCTAssertNil(ffmpegFormula.installPath);
	XCTAssertNil(acmeFormula.installPath,  @"");
	XCTAssertNil(bfgFormula.installPath);
	XCTAssertNil(perconaFormula.installPath);
	XCTAssertNil(sbtenvFormula.installPath);
}

- (void)testFormulaInstallPathKegOnly
{
	XCTAssertEqualObjects(bisonFormula.installPath, @"This formula is keg-only.");
}

- (void)testFormulaLatestVersion
{
	XCTAssertEqualObjects(ffmpegFormula.latestVersion, @"stable 2.7.2, HEAD");
	XCTAssertEqualObjects(mysqlFormula.latestVersion, @"stable 5.6.26");
	XCTAssertEqualObjects(acmeFormula.latestVersion, @"stable 0.91, devel 0.93");
	XCTAssertEqualObjects(bfgFormula.latestVersion, @"stable 1.12.4");
	XCTAssertEqualObjects(perconaFormula.latestVersion, @"stable 5.6.25-73.1");
	XCTAssertEqualObjects(bisonFormula.latestVersion, @"stable 3.0.4");
	XCTAssertEqualObjects(sbtenvFormula.latestVersion, @"stable 0.0.8, HEAD");
}

- (void)testFormulaNumberOfOptions
{
	XCTAssertEqual([ffmpegFormula.options count], 33);
	XCTAssertEqual([mysqlFormula.options count], 8);
	XCTAssertEqual([acmeFormula.options count], 0);
	XCTAssertEqual([bfgFormula.options count], 0);
	XCTAssertEqual([perconaFormula.options count], 5);
	XCTAssertEqual([bisonFormula.options count], 0);
}

- (void)testFormulaOptions
{
	//testing boundaries only
	NSArray *options;
	options = perconaFormula.options;
	if ([options count] >= 5) {
		XCTAssertEqualObjects([(BPFormulaOption *)options[0] name], @"--universal");
		XCTAssertEqualObjects([(BPFormulaOption *)options[0] explanation], @"Build a universal binary");
		XCTAssertEqualObjects([(BPFormulaOption *)options[4] name], @"--with-tests");
		XCTAssertEqualObjects([(BPFormulaOption *)options[4] explanation], @"Build with unit tests");
	}
	options = ffmpegFormula.options;
	if ([options count] >= 33) {
		XCTAssertEqualObjects([(BPFormulaOption *)options[0] name], @"--with-faac");
		XCTAssertEqualObjects([(BPFormulaOption *)options[0] explanation], @"Build with faac support");
		XCTAssertEqualObjects([(BPFormulaOption *)options[32] name], @"--HEAD");
		XCTAssertEqualObjects([(BPFormulaOption *)options[32] explanation], @"Install HEAD version");
	}
	options = mysqlFormula.options;
	if ([options count] >= 8) {
		XCTAssertEqualObjects([(BPFormulaOption *)options[0] name], @"--universal");
		XCTAssertEqualObjects([(BPFormulaOption *)options[0] explanation], @"Build a universal binary");
		XCTAssertEqualObjects([(BPFormulaOption *)options[7] name], @"--with-tests");
		XCTAssertEqualObjects([(BPFormulaOption *)options[7] explanation], @"Build with unit tests");
	}
	
	
}

- (void)testFormulaObserverAddition
{
  BPCustomFormula *observerFormula = [BPCustomFormula formulaWithName:@"acme"];
  XCTAssertTrue(observerFormula->observerAdded);
  BPCustomFormula *formulaCopy = [observerFormula copy];
  XCTAssertTrue(formulaCopy->observerAdded);
}

- (void)testFormulaNotificationUpdate
{
  BPCustomFormula *customFormula = [BPCustomFormula formulaWithName:@"acme"];
  XCTestExpectation *expectation = [self expectationForNotification:BPFormulaDidUpdateNotification
															 object:customFormula
															handler:^BOOL(NSNotification *notification){
	  [expectation fulfill];
	  return YES;
  }];
  [customFormula setNeedsInformation:YES];
  [self waitForExpectationsWithTimeout:0.5 handler:nil];
}

@end
