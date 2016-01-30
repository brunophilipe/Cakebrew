#import "BPRepository.h"

@implementation BPRepository

+ (instancetype)repositoryWithName:(NSString *)name
{
  return [[self alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name
{
  if (self) {
	_name = [name copy];
  }
  
  return self;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
  BPRepository *repository = [[[self class] allocWithZone:zone] init];
  if (repository)
  {
	repository->_name = [self->_name  copy];
  }
  return repository;
}

@end
