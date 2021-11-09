//
//  BetterDummy
//
//  Created by @waydabber
//

#import <Foundation/Foundation.h>
#import <objc/NSObject.h>
#import <CoreGraphics/CoreGraphics.h>

extern CFDictionaryRef CoreDisplay_DisplayCreateInfoDictionary(CGDirectDisplayID);

@interface CGVirtualDisplay : NSObject
{
    unsigned int _vendorID;
    unsigned int _productID;
    unsigned int _serialNum;
    NSString *_name;
    struct CGSize _sizeInMillimeters;
    unsigned int _maxPixelsWide;
    unsigned int _maxPixelsHigh;
    struct CGPoint _redPrimary;
    struct CGPoint _greenPrimary;
    struct CGPoint _bluePrimary;
    struct CGPoint _whitePoint;
    id _queue;
    id _terminationHandler;
    void *_client;
    unsigned int _displayID;
    unsigned int _hiDPI;
    NSArray *_modes;
    unsigned int _serverRPC_port;
    unsigned int _proxyRPC_port;
    unsigned int _clientHandler_port;
}

@property(readonly, nonatomic) NSArray *modes; // @synthesize modes=_modes;
@property(readonly, nonatomic) unsigned int hiDPI; // @synthesize hiDPI=_hiDPI;
@property(readonly, nonatomic) unsigned int displayID; // @synthesize displayID=_displayID;
@property(readonly, nonatomic) id terminationHandler; // @synthesize terminationHandler=_terminationHandler;
@property(readonly, nonatomic) id queue; // @synthesize queue=_queue;
@property(readonly, nonatomic) struct CGPoint whitePoint; // @synthesize whitePoint=_whitePoint;
@property(readonly, nonatomic) struct CGPoint bluePrimary; // @synthesize bluePrimary=_bluePrimary;
@property(readonly, nonatomic) struct CGPoint greenPrimary; // @synthesize greenPrimary=_greenPrimary;
@property(readonly, nonatomic) struct CGPoint redPrimary; // @synthesize redPrimary=_redPrimary;
@property(readonly, nonatomic) unsigned int maxPixelsHigh; // @synthesize maxPixelsHigh=_maxPixelsHigh;
@property(readonly, nonatomic) unsigned int maxPixelsWide; // @synthesize maxPixelsWide=_maxPixelsWide;
@property(readonly, nonatomic) struct CGSize sizeInMillimeters; // @synthesize sizeInMillimeters=_sizeInMillimeters;
@property(readonly, nonatomic) NSString *name; // @synthesize name=_name;
@property(readonly, nonatomic) unsigned int serialNum; // @synthesize serialNum=_serialNum;
@property(readonly, nonatomic) unsigned int productID; // @synthesize productID=_productID;
@property(readonly, nonatomic) unsigned int vendorID; // @synthesize vendorID=_vendorID;
- (BOOL)applySettings:(id)arg1;
- (void)dealloc;
- (id)initWithDescriptor:(id)arg1;

@end

@interface CGVirtualDisplayDescriptor : NSObject
{
    unsigned int _vendorID;
    unsigned int _productID;
    unsigned int _serialNum;
    NSString *_name;
    struct CGSize _sizeInMillimeters;
    unsigned int _maxPixelsWide;
    unsigned int _maxPixelsHigh;
    struct CGPoint _redPrimary;
    struct CGPoint _greenPrimary;
    struct CGPoint _bluePrimary;
    struct CGPoint _whitePoint;
    id _queue;
    id _terminationHandler;
}

@property(retain, nonatomic) id queue; // @synthesize queue=_queue;
@property(retain, nonatomic) NSString *name; // @synthesize name=_name;
@property(nonatomic) struct CGPoint whitePoint; // @synthesize whitePoint=_whitePoint;
@property(nonatomic) struct CGPoint bluePrimary; // @synthesize bluePrimary=_bluePrimary;
@property(nonatomic) struct CGPoint greenPrimary; // @synthesize greenPrimary=_greenPrimary;
@property(nonatomic) struct CGPoint redPrimary; // @synthesize redPrimary=_redPrimary;
@property(nonatomic) unsigned int maxPixelsHigh; // @synthesize maxPixelsHigh=_maxPixelsHigh;
@property(nonatomic) unsigned int maxPixelsWide; // @synthesize maxPixelsWide=_maxPixelsWide;
@property(nonatomic) struct CGSize sizeInMillimeters; // @synthesize sizeInMillimeters=_sizeInMillimeters;
@property(nonatomic) unsigned int serialNum; // @synthesize serialNum=_serialNum;
@property(nonatomic) unsigned int productID; // @synthesize productID=_productID;
@property(nonatomic) unsigned int vendorID; // @synthesize vendorID=_vendorID;
- (void)dealloc;
- (id)init;
@property(copy, nonatomic) id terminationHandler;
- (id)dispatchQueue;
- (void)setDispatchQueue:(id)arg1;

@end

@interface CGVirtualDisplayMode : NSObject
{
    unsigned int _width;
    unsigned int _height;
    double _refreshRate;
}

@property(readonly, nonatomic) double refreshRate; // @synthesize refreshRate=_refreshRate;
@property(readonly, nonatomic) unsigned int height; // @synthesize height=_height;
@property(readonly, nonatomic) unsigned int width; // @synthesize width=_width;
- (id)initWithWidth:(unsigned int)arg1 height:(unsigned int)arg2 refreshRate:(double)arg3;

@end

@interface CGVirtualDisplaySettings : NSObject
{
    NSArray *_modes;
    unsigned int _hiDPI;
}

@property(nonatomic) unsigned int hiDPI; // @synthesize hiDPI=_hiDPI;
- (void)dealloc;
- (id)init;
@property(retain, nonatomic) NSArray *modes;

@end

id createVirtualDisplay(int width, int height, int ppi, BOOL hiDPI, NSString *name, int ref_rate);

typedef struct {
  uint32_t modeNumber;
  uint32_t flags;
  uint32_t width;
  uint32_t height;
  uint32_t depth;
  uint8_t unknown[170];
  uint16_t freq;
  uint8_t more_unknown[16];
  float density;
} CGSDisplayMode;

void CGSGetCurrentDisplayMode(CGDirectDisplayID display, int* modeNum);
void CGSConfigureDisplayMode(CGDisplayConfigRef config, CGDirectDisplayID display, int modeNum);
void CGSGetNumberOfDisplayModes(CGDirectDisplayID display, int* nModes);
void CGSGetDisplayModeDescriptionOfLength(CGDirectDisplayID display, int idx, CGSDisplayMode* mode, int length);
