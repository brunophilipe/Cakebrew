#import <Foundation/Foundation.h>

@interface BPRepository : NSObject <NSCopying>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSURL *remote;
@property (nonatomic, getter=isPinned) BOOL pinned;
@property (nonatomic, strong) NSArray *formulae;

- (instancetype)initWithName:(NSString *)name;
+ (instancetype)repositoryWithName:(NSString *)name;

@end
