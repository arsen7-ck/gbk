#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/IOTypes.h>
#include <IOKit/IOReturn.h>
#include <IOKit/hid/IOHIDLib.h>
//#include <IOKit/hid/IOHIDManager.h>
#import <objc/runtime.h>

#include <stdio.h>
#include <unistd.h>
#include <dlfcn.h>

#include <string.h> 
#include <fcntl.h> 
#include <sys/stat.h> 
#include <sys/types.h> 


typedef struct {
	uint8_t id, 
	left_x, left_y, 
	right_x, right_y, 
	buttons1, buttons2, buttons3, 
	left_trigger, right_trigger, 
	unk1, unk2, unk3;
	int16_t gyro_x, gyro_y, gyro_z;
	int16_t accel_x, accel_y, accel_z;
	uint8_t unk4[39];
} PSReport;

IOHIDManagerRef IOHIDManagerCreate( CFAllocatorRef allocator, IOOptionBits options) {
	printf("IOHIDManagerCreate\n");
	return (IOHIDManagerRef) 0xDEADBEEF;
}

IOReturn IOHIDManagerOpen( IOHIDManagerRef manager, IOOptionBits options) {
	printf("IOHIDManagerOpen\n");
	return kIOReturnSuccess;
}

IOReturn IOHIDManagerClose( IOHIDManagerRef manager, IOOptionBits options) {
	printf("IOHIDManagerClose\n");
	return kIOReturnSuccess;
}

CFSetRef IOHIDManagerCopyDevices( IOHIDManagerRef manager) {
	IOHIDDeviceRef dev = (IOHIDDeviceRef) 0xDEADBEEF;
	IOHIDDeviceRef devs[1] = {dev};
	printf("IOHIDManagerCopyDevices\n");
	return CFSetCreate(NULL, (const void **) devs, 1, NULL);
}

void IOHIDManagerRegisterDeviceMatchingCallback( IOHIDManagerRef manager, IOHIDDeviceCallback callback, void *context) {
	printf("IOHIDManagerRegisterDeviceMatchingCallback\n");
}

void IOHIDManagerRegisterDeviceRemovalCallback( IOHIDManagerRef manager, IOHIDDeviceCallback callback, void *context) {
	printf("IOHIDManagerRegisterDeviceMatchingCallback\n");
}



void IOHIDManagerSetDeviceMatchingMultiple( IOHIDManagerRef manager, CFArrayRef multiple) {
	printf("IOHIDManagerSetDeviceMatchingMultiple\n");
}


void IOHIDManagerUnscheduleFromRunLoop( IOHIDManagerRef manager, CFRunLoopRef runLoop, CFStringRef runLoopMode) {
	printf("IOHIDManagerUnscheduleFromRunLoop\n");
}

IOReturn IOHIDDeviceOpen( IOHIDDeviceRef device, IOOptionBits options) {
	printf("IOHIDDeviceOpen %08x\n", (unsigned int) device);
	return kIOReturnSuccess;
}

CFNumberRef makeUShort(unsigned short value) {
	return CFNumberCreate(NULL, kCFNumberShortType, &value);
}

CFTypeRef IOHIDDeviceGetProperty( IOHIDDeviceRef device, CFStringRef key) {
	printf("IOHIDDeviceGetProperty('%s')\n", CFStringGetCStringPtr(key, kCFStringEncodingMacRoman));
	if(CFStringCompare(key, CFSTR("VendorID"), 0) == 0) {
		return makeUShort(0x54c);
	} else if(CFStringCompare(key, CFSTR("ProductID"), 0) == 0) {
		return makeUShort(0x5c4);
	} else if(CFStringCompare(key, CFSTR("Transport"), 0) == 0) {
		return CFSTR("USB");
	} else if(CFStringCompare(key, CFSTR("VersionNumber"), 0) == 0) {
		return makeUShort(0x100);
	}
	return NULL;
}

IOReturn IOHIDDeviceGetReport( IOHIDDeviceRef device, IOHIDReportType reportType, CFIndex reportID, uint8_t *report, CFIndex *pReportLength) {
	printf("IOHIDDeviceGetReport(0x%x, %i)\n", (int) reportID, pReportLength == NULL ? 0 : (int) *pReportLength);
	if(reportID == 0x12) {
		uint8_t report12[] = {0x12, 0x8B, 0x09, 0x07, 0x6D, 0x66, 0x1C, 0x08, 0x25, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
		assert(pReportLength != NULL && *pReportLength >= sizeof(report12));
		memcpy(report, report12, sizeof(report12));
	} else if(reportID == 0xa3) {
		uint8_t reporta3[] = {0xA3, 0x41, 0x75, 0x67, 0x20, 0x20, 0x33, 0x20, 0x32, 0x30, 0x31, 0x33, 0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x37, 0x3A, 0x30, 0x31, 0x3A, 0x31, 0x32, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x31, 0x03, 0x00, 0x00, 0x00, 0x49, 0x00, 0x05, 0x00, 0x00, 0x80, 0x03, 0x00};
		assert(pReportLength != NULL && *pReportLength >= sizeof(reporta3));
		memcpy(report, reporta3, sizeof(reporta3));
	} else if(reportID == 0x02) {
		uint8_t report02[] = {0x02, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x87, 0x22, 0x7B, 0xDD, 0xB2, 0x22, 0x47, 0xDD, 0xBD, 0x22, 0x43, 0xDD, 0x1C, 0x02, 0x1C, 0x02, 0x7F, 0x1E, 0x2E, 0xDF, 0x60, 0x1F, 0x4C, 0xE0, 0x3A, 0x1D, 0xC6, 0xDE, 0x08, 0x00};
		assert(pReportLength != NULL && *pReportLength >= sizeof(report02));
		memcpy(report, report02, sizeof(report02));
	}
	return kIOReturnSuccess;
}

IOReturn IOHIDDeviceSetReport( IOHIDDeviceRef device, IOHIDReportType reportType, CFIndex reportID, const uint8_t *report, CFIndex reportLength) {
	printf("IOHIDDeviceSetReport\n");
	return kIOReturnSuccess;
}



@interface HIDRunner:NSObject
{
	CFRunLoopRef runLoop;
	CFStringRef runLoopMode;

	IOHIDReportCallback callback;
	void *context;

	uint8_t *report;
	CFIndex reportLength;

	uint64_t ticks;

	bool X, O, square, triangle, PS, touchpad, options, share, 
	L1, L2, L3, R1, R2, R3, dpadUp, dpadDown, dpadLeft, dpadRight;
	float leftX, leftY, rightX, rightY; // -1 to 1
	uint8_t uleftX, uleftY, urightX, urightY;

	bool keys[256], leftMouse, rightMouse;
	bool kicked, decayKicked;

	bool mouseMoved;
	NSPoint lastMouse;
	CFAbsoluteTime lastMouseTime;
	float mouseAccelX, mouseAccelY, mouseVelX, mouseVelY;
}

// -(void)fakeDown:(int)code;
// -(void)fakeUp:(int)code;
-(void)tickpad:(int)code :(int)val;
@end



static HIDRunner *hid;

////
////
////
////
////
// 3/1/2020 Fetch by MiCkSoftware: Add gamepad wrapper



@interface GPadManager : NSObject 
+(void)gpadloop:(id)param;
-(void)start;
-(void)close;
@end

@implementation GPadManager

static int fd;

- (void) close {
	close(fd);
}

- (void) start {
		// char buf[10];
		// printf("GPAD Server: task launch\n");
		
		// sprintf(buf,"%d",getpid());
		// sprintf(buf,"%d",getpid());
		// if(mkfifo("/tmp/gpad-daemon-data",0660) == -1)
		// 		perror("mkfifo");
		// else 
		// 	printf("GPAD Server: pipe created : %s\n", buf);

		[NSThread detachNewThreadSelector:@selector(gpadloop:) toTarget:[GPadManager class] withObject:self];
}


+(void)gpadloop:(id)param{

	char rdbuf[50];
	int code,val;
	fd = open("/tmp/gpad-daemon-data",O_RDONLY);
	
	while (true) {

		while (read(fd, rdbuf, 50)) {

		if (strlen(rdbuf) > 0) {
			// printf("GPAD Server: has been entered : [%s] \n",rdbuf);
			int n = sscanf(rdbuf, "%d %d", &code, &val) ;
			if (n >0) {
				// printf("\t\t[%d][%d] \n",code, val);
				[hid tickpad:code :val];
			}
			sprintf(rdbuf, "%s", "\0");
			fflush(stdout);
		} 
		}
		
		usleep(10000);
	} 

	// printf("GPAD Server: task loop KILLED!\n");
}
@end





static GPadManager *gpadmanager;
////
////
////
////
////
////
////
////

#define MOUSESTEPS 10



#define SWAP(ocls, sel) do { \
	id rcls = NSClassFromString(@"_TtC10RemotePlay17RPWindowStreaming"); \
	SEL selector = @selector sel; \
	Method original = class_getInstanceMethod(rcls, selector); \
	Method new = class_getInstanceMethod(cls, selector); \
	method_exchangeImplementations(original, new); \
} while(0)

@implementation HIDRunner
+ (void)load {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		id cls = NSClassFromString(@"HIDRunner");
		SWAP(@"_TtC10RemotePlay17RPWindowStreaming", (keyDown:));
		SWAP(@"_TtC10RemotePlay17RPWindowStreaming", (keyUp:));
		SWAP(@"_TtC10RemotePlay17RPWindowStreaming", (mouseMoved:));
		SWAP(@"_TtC10RemotePlay17RPWindowStreaming", (mouseDown:));
		SWAP(@"_TtC10RemotePlay17RPWindowStreaming", (mouseUp:));
		SWAP(@"_TtC10RemotePlay17RPWindowStreaming", (rightMouseDown:));
		SWAP(@"_TtC10RemotePlay17RPWindowStreaming", (rightMouseUp:));
	});
	////

}



- (id)initWithRunLoop:(CFRunLoopRef)_runLoop andMode:(CFStringRef)_mode {
	hid = self = [super init];
	runLoop = _runLoop;
	runLoopMode = _mode;
	ticks = 0;

	for(int i = 0; i < 256; ++i)
		keys[i] = false;

	gpadmanager = [GPadManager new];
	[gpadmanager start];

	return self;
}

- (void)registerCallback:(IOHIDReportCallback)cb withContext:(void *)ctx andReport:(uint8_t *)rep withLength:(CFIndex) repLen {
	callback = cb;
	context = ctx;
	report = rep;
	reportLength = repLen;
}

////
////
////
////
////
// 3/1/2020 Fetch by MiCkSoftware: Add gamepad wrapper
- (void)tickpad: (int)code :(int)val {
	uint8_t brep[] = {0x01, 0x7f, 0x81, 0x82, 0x7d, 0x08, 0x00, 0xb4, 0x00, 0x00, 0xc8, 0xad, 0xf9, 0x04, 0x00, 0xfe, 0xff, 0xfc, 0xff, 0xe5, 0xfe, 0xcb, 0x1f, 0x69, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1b, 0x00, 0x00, 0x01, 0x63, 0x8b, 0x80, 0xc1, 0x2e, 0x80, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00};
	PSReport *prep = (PSReport *) report;
	uint8_t dpad = 8;
	
	memcpy(report, brep, sizeof(brep));

	// printf("\t\t[%d][%d] \n",code, val);
	

	if (code ==57)
		dpad = val;

	if (code == 2) { X = (val == 1);}
	else if (code == 3) { O = (val == 1);}
	else if (code == 1) { square = (val == 1);}
	else if (code == 4) { triangle = (val == 1);}
	else if (code == 5) { L1 = (val == 1);}
	else if (code == 6) { R1 = (val == 1);}
	else if (code == 7) { L2 = (val == 1);}
	else if (code == 8) { R2 = (val == 1);}
	else if (code == 9) { share = (val == 1);}
	else if (code == 10) { options = (val == 1);}
	else if (code == 11) { L3 = (val == 1);}
	else if (code == 12) { R3 = (val == 1);}
	else if (code == 13) { PS = (val == 1);}
	else if (code == 48) { 
		uleftX = (uint8_t) fmin(fmax(val, 0), 255);
	} else if (code == 49) { 
		uleftY = (uint8_t) fmin(fmax(val, 0), 255);
	} else if (code == 50) { 
		urightX = (uint8_t) fmin(fmax(val, 0), 255);
	} else if (code == 53) { 
		urightY = (uint8_t) fmin(fmax(val, 0), 255);
	} 

	// NSLog(@"\t\t [%d] [%d]", code, val);

	prep->buttons1 = (triangle ? (1 << 7) : 0) | (O ? (1 << 6) : 0) | (X ? (1 << 5) : 0) | (square ? (1 << 4) : 0) | dpad;
	prep->buttons2 = (R3 ? (1 << 7) : 0) | (L3 ? (1 << 6) : 0) | (options ? (1 << 5) : 0) | (share ? (1 << 4) : 0) | 
		(R2 ? (1 << 3) : 0) | (L2 ? (1 << 2) : 0) | (R1 ? (1 << 1) : 0) | (L1 ? (1 << 0) : 0);
	prep->buttons3 = ((ticks << 2) & 0xFF) | (touchpad ? 2 : 0) | (PS ? 1 : 0);
	prep->left_trigger = L2 ? 255 : 0;
	prep->right_trigger = R2 ? 255 : 0;
	prep->left_x = uleftX;
	prep->left_y = uleftY;
	prep->right_x = urightX;
	prep->right_y = urightY;
	callback(context, kIOReturnSuccess, (void *)0xDEADBEEF, kIOHIDReportTypeInput, 0x01, report, 64);

	ticks++;

}
////
////
////
////
////

- (void)tick {
	uint8_t brep[] = {0x01, 0x7f, 0x81, 0x82, 0x7d, 0x08, 0x00, 0xb4, 0x00, 0x00, 0xc8, 0xad, 0xf9, 0x04, 0x00, 0xfe, 0xff, 0xfc, 0xff, 0xe5, 0xfe, 0xcb, 0x1f, 0x69, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1b, 0x00, 0x00, 0x01, 0x63, 0x8b, 0x80, 0xc1, 0x2e, 0x80, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00};
	PSReport *prep = (PSReport *) report;

	memcpy(report, brep, sizeof(brep));

	[self mapKeys];
	
	// NSLog(@"leftX %f", leftX);

	uint8_t dpad = 8;
	if(dpadLeft) {
		if(dpadUp)
			dpad = 7;
		else if(dpadDown)
			dpad = 5;
		else
			dpad = 6;
	} else if(dpadRight) {
		if(dpadUp)
			dpad = 1;
		else if(dpadDown)
			dpad = 3;
		else
			dpad = 2;
	} else if(dpadUp)
		dpad = 0;
	else if(dpadDown)
		dpad = 4;
	prep->buttons1 = (triangle ? (1 << 7) : 0) | (O ? (1 << 6) : 0) | (X ? (1 << 5) : 0) | (square ? (1 << 4) : 0) | dpad;
	prep->buttons2 = (R3 ? (1 << 7) : 0) | (L3 ? (1 << 6) : 0) | (options ? (1 << 5) : 0) | (share ? (1 << 4) : 0) | 
		(R2 ? (1 << 3) : 0) | (L2 ? (1 << 2) : 0) | (R1 ? (1 << 1) : 0) | (L1 ? (1 << 0) : 0);
	prep->buttons3 = ((ticks << 2) & 0xFF) | (touchpad ? 2 : 0) | (PS ? 1 : 0);
	prep->left_trigger = L2 ? 255 : 0;
	prep->right_trigger = R2 ? 255 : 0;
	prep->left_x = (uint8_t) fmin(fmax(128 + leftX * 127, 0), 255);
	prep->left_y = (uint8_t) fmin(fmax(128 + leftY * 127, 0), 255);
	prep->right_x = (uint8_t) fmin(fmax(128 + rightX * 127, 0), 255);
	prep->right_y = (uint8_t) fmin(fmax(128 + rightY * 127, 0), 255);
	callback(context, kIOReturnSuccess, (void *)0xDEADBEEF, kIOHIDReportTypeInput, 0x01, report, 64);

	ticks++;
}

- (void)kick {
	
	if(kicked)
		return;
	kicked = true;
	CFRunLoopPerformBlock(runLoop, runLoopMode, ^void() {
		kicked = false;
		[self tick];
	});
}

- (void)decayKick {
	if(decayKicked)
		return;
	decayKicked = true;
	CFRunLoopPerformBlock(runLoop, runLoopMode, ^void() {
		decayKicked = false;
		[self tick];
	});
}

#define JOYDECAY 5
#define DEADZONE .1

#define DOWN(key) keys[key]
- (void)mapKeys {
#include "mapKeys.h"
}


- (void)keyDown:(NSEvent *)event {
	NSLog(@"down %i", [event keyCode]);
	hid->keys[[event keyCode]] = true;
	[hid kick];
}
- (void)keyUp:(NSEvent *)event {
	//NSLog(@"up %i", [event keyCode]);
	hid->keys[[event keyCode]] = false;
	[hid kick];
}

- (void)mouseMoved:(NSEvent *)event {
	//NSLog(@"mouseMoved");

	NSPoint mouse = [event locationInWindow];
	CFAbsoluteTime curtime = CFAbsoluteTimeGetCurrent();
	float velX = (mouse.x - hid->lastMouse.x) / (curtime - hid->lastMouseTime);
	float velY = (mouse.y - hid->lastMouse.y) / (curtime - hid->lastMouseTime);
	hid->mouseAccelX = (velX - hid->mouseVelX) / (curtime - hid->lastMouseTime);
	hid->mouseAccelY = (velY - hid->mouseVelY) / (curtime - hid->lastMouseTime);
	//NSLog(@"vel %f %f", velX, velY);
	//NSLog(@"accel %f %f", hid->mouseAccelX, hid->mouseAccelY);
	hid->mouseVelX = velX;
	hid->mouseVelY = velY;
	hid->lastMouseTime = curtime;
	hid->lastMouse = mouse;
	hid->mouseMoved = true;

	[hid kick];
	[hid decayKick];
}
- (void)mouseDown:(NSEvent *)event {
	hid->leftMouse = true;
	[hid kick];
}
- (void)mouseUp:(NSEvent *)event {
	hid->leftMouse = false;
	[hid kick];
}
- (void)rightMouseDown:(NSEvent *)event {
	hid->rightMouse = true;
	[hid kick];
}
- (void)rightMouseUp:(NSEvent *)event {
	hid->rightMouse = false;
	[hid kick];
}
@end

void IOHIDManagerScheduleWithRunLoop( IOHIDManagerRef manager, CFRunLoopRef runLoop, CFStringRef runLoopMode) {
	printf("IOHIDManagerScheduleWithRunLoop\n");
	[[HIDRunner alloc] initWithRunLoop:runLoop andMode:runLoopMode];
}

void IOHIDDeviceScheduleWithRunLoop( IOHIDDeviceRef device, CFRunLoopRef runLoop, CFStringRef runLoopMode) {
	printf("IOHIDDeviceScheduleWithRunLoop\n");
}

void IOHIDDeviceRegisterInputReportCallback( IOHIDDeviceRef device, uint8_t *report, CFIndex reportLength, IOHIDReportCallback callback, void *context) {
	printf("IOHIDDeviceRegisterInputReportCallback\n");
	[hid registerCallback:callback withContext:context andReport:report withLength:reportLength];
}


