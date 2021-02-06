//
//  BPUtilities.m
//  Cakebrew
//
//  Created by Marek Hrusovsky on 25/08/15.
//	Copyright (c) 2014 Bruno Philipe. All rights reserved.
//
//	This program is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.
//
//	This program is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with this program.	If not, see <http://www.gnu.org/licenses/>.
//

#import "BPUtilities.h"

NSInteger const OSX_YOSEMITE = 10;
NSInteger const MACOS_BIGSUR = 11;

@implementation BPUtilities

+ (BOOL)isRunningYosemiteOrLater
{
	if ([[NSProcessInfo processInfo] respondsToSelector:@selector(operatingSystemVersion)]) {
		NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
		if (version.minorVersion >= OSX_YOSEMITE || version.majorVersion >= MACOS_BIGSUR) {
			return YES;
		}
	}

	return NO;
}

@end
