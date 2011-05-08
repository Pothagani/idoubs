#import "NgnEngine.h"

#import "NgnSipService.h"
#import "NgnConfigurationService.h"

#undef TAG
#define kTAG @"NgnEngine///: "
#define TAG kTAG

static NgnEngine* sInstance = nil;

@implementation NgnEngine(Private)

-(void)dummyCoCoaThread {
	NgnNSLog(TAG, @"dummyCoCoaThread()");
}

@end

@implementation NgnEngine

-(NgnEngine*)init{
	if((self = [super init])){
	}
	return self;
}

-(void)dealloc{
	[self stop];
	
	[mSipService release];
	[mConfigurationService release];
	[super dealloc];
}

-(BOOL)start{
	if(mStarted){
		return TRUE;
	}
	BOOL bSuccess = TRUE;
	
	/* http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSAutoreleasePool_Class/Reference/Reference.html
	 Note: If you are creating secondary threads using the POSIX thread APIs instead of NSThread objects, you cannot use Cocoa, including NSAutoreleasePool, unless Cocoa is in multithreading mode.
	 Cocoa enters multithreading mode only after detaching its first NSThread object.
	 To use Cocoa on secondary POSIX threads, your application must first detach at least one NSThread object, which can immediately exit.
	 You can test whether Cocoa is in multithreading mode with the NSThread class method isMultiThreaded.
	 */
	[NSThread detachNewThreadSelector:@selector(dummyCoCoaThread) toTarget:self withObject:nil];
	if([NSThread isMultiThreaded]){
		NgnNSLog(TAG, @"Working in multithreaded mode :)");
	}
	else{
		NgnNSLog(TAG, @"NOT working in multithreaded mode :(");
	}
	
	bSuccess &= [[self getSipService] start];
	bSuccess &= [[self getConfigurationService] start];
	
	mStarted = TRUE;
	return bSuccess;
}

-(BOOL)stop{
	if(!mStarted){
		return TRUE;
	}
	
	BOOL bSuccess = TRUE;
	
	bSuccess &= [[self getSipService] stop];
	bSuccess &= [[self getConfigurationService] stop];
	
	mStarted = FALSE;
	return bSuccess;
}

-(NgnBaseService<INgnSipService>*) sipService{
	return [self getSipService];
}
-(NgnBaseService<INgnSipService>*)getSipService{
	if(mSipService == nil){
		mSipService = [[NgnSipService alloc] init];
	}
	return mSipService;
}

-(NgnBaseService<INgnConfigurationService>*) configurationService{
	return [self getConfigurationService];
}
-(NgnBaseService<INgnConfigurationService>*)getConfigurationService{
	if(mConfigurationService == nil){
		mConfigurationService = [[NgnConfigurationService alloc] init];
	}
	return mConfigurationService;
}

+(void)initialize{
}

+(NgnEngine*) getInstance{
	if(sInstance == nil){
		sInstance = [[NgnEngine alloc] init];
	}
	return sInstance;
}

@end
