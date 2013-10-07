//  $Id$
//  Copyright (C) 2006 Paul Kunysch. GNU GPL v2.


#import <Cocoa/Cocoa.h>

#include <net-snmp/net-snmp-config.h>
#include <net-snmp/net-snmp-includes.h>

@interface SnmpSession : NSObject {
  struct snmp_session s, *session;
}

-(id) initWithHost:(NSString*) host community:(NSString*) community;

/** This returns a value for the specified id. */
-(id) stringForOid:(NSString *)objectIdString;
-(void) setOidIntValue:(NSString *)objectIdString value:(int)intVal;

@end
