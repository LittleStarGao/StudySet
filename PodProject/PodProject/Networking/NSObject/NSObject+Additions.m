
//  NSObject+Additions.m


#import "NSObject+Additions.h"

@implementation NSObject (Additions)

// 
NSString* safeString(id obj) {
    return [obj isKindOfClass: [NSObject class]] ? [NSString stringWithFormat:@"%@",obj] : @"";
}

NSNumber* safeNumber(id obj) {
    NSNumber *result=[NSNumber numberWithInt:0];
    if([obj isKindOfClass:[NSNumber class]]) {
        result = obj;
    } else if ([obj isKindOfClass:[NSString class]]) {
        result = @(((NSString *)obj).doubleValue);
    }
    return result;
}




- (void)performBlock:(void (^)(void))block
          afterDelay:(NSTimeInterval)delay
{
    [self performSelector:@selector(fireBlockAfterDelay:)
               withObject:block
               afterDelay:delay];
}

- (void)fireBlockAfterDelay:(void (^)(void))block {
    block();
}

- (NSException *)tryCatch:(void (^)())block
{
    NSException *result = nil;
    
    @try
    {
        block();
    }
    @catch (NSException *e)
    {
        result = e;
    }
    
    return result;
}

- (NSException *)tryCatch:(void (^)())block finally:(void(^)())aFinisheBlock
{
    NSException *result = nil;
    
    @try
    {
        block();
    }
    @catch (NSException *e)
    {
        result = e;
    }
    @finally
    {
        aFinisheBlock();
    }
    
    return result;
}

- (void)performInMainThreadBlock:(void(^)())aInMainBlock
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        aInMainBlock();
        
    });
}

- (void)performInThreadBlock:(void(^)())aInThreadBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        aInThreadBlock();
        
    });
}

- (void)performInMainThreadBlock:(void(^)())aInMainBlock afterSecond:(NSTimeInterval)delay
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (delay * NSEC_PER_SEC));
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        aInMainBlock();
        
    });
}

- (void)performInThreadBlock:(void(^)())aInThreadBlock afterSecond:(NSTimeInterval)delay
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (delay * NSEC_PER_SEC));
    
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        aInThreadBlock();
        
    });
}

@end
