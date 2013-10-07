//  $Id$
//  Copyright (C) 2006 Paul Kunysch. GNU GPL v2.

#import "SnmpSession.h"

char *errorString;
@implementation SnmpSession
-(id) initWithHost:(NSString*) host
		 community:(NSString*) community
{
	if (nil == host || nil == community) return nil;
	self = [super init];
	if (nil == self) return nil;
	init_snmp("SNMP-Test-Cocoa");
	snmp_sess_init(&s);
	s.version = SNMP_VERSION_2c;
	s.community = (u_char*)strdup([community UTF8String]);
	s.community_len = strlen((char*)s.community);
	s.peername = strdup([host UTF8String]);
    s.timeout = 40000;
	session = snmp_open(&s);
	if (NULL == session) {
		[self release];
		return nil;
	}
	return self;
}

-(void) dealloc
{
	snmp_close(session);
	[super dealloc];
}

-(id) stringForOid:(NSString *)oidStr
{
	if (NULL == session)
	{
		NSLog(@"NULL session");
		return nil;
	}
	id result = nil;
	size_t length = MAX_OID_LEN;
	oid objectid[MAX_OID_LEN];
	read_objid([oidStr UTF8String], objectid, &length);
	struct snmp_pdu *pdu = snmp_pdu_create(SNMP_MSG_GET);
	snmp_add_null_var(pdu, objectid, length);
	struct snmp_pdu *response;
	if (STAT_SUCCESS != snmp_synch_response(session, pdu, &response))
		return nil;
	struct variable_list *var = response->variables;
	switch (var->type) {
		case 2: // INTEGER
			result = [NSString stringWithFormat:@"%i",*(var->val.integer)];
			break;
		case 0x81: // HEX data
		case 4: // STRING
			result = [NSString stringWithCString:(char*)var->val.string length:var->val_len];
			break;
		default:
			NSLog(@"Unsupported datatype 0x%02x for \"%@\"", var->type, oidStr);
			break;
	}
	snmp_free_pdu(response);
	return result;
	//	snmp_close(session);
}

-(void) setOidIntValue:(NSString *)objectIdString value:(int)intVal
{
	char *errorString[100];
	size_t errorString_Length;
	netsnmp_variable_list *vars;
	if (NULL == session)
	{
		NSLog(@"NULL session");
		exit;
	}
	size_t length = MAX_OID_LEN;
	oid objectid[MAX_OID_LEN];
	read_objid([objectIdString UTF8String], objectid, &length);
	
	struct snmp_pdu *pdu = snmp_pdu_create(SNMP_MSG_SET);
	NSString * val = [NSString stringWithFormat:@"%i", intVal];
	int addVarResult = snmp_add_var(pdu, objectid, length, 'i', [val UTF8String]);
	if (addVarResult)
	{
		NSLog(@"snmp_add_var ERROR %s",snmp_api_errstring(addVarResult));
	}
	struct snmp_pdu *response = NULL;
	
	int status = snmp_synch_response(session, pdu, &response);
    if (status == STAT_SUCCESS)
	{
		if (response->errstat != SNMP_ERR_NOERROR)
		{
			NSLog(@"Error in packet.\nReason: %s\n",snmp_errstring(response->errstat));
			
            if (response->errindex != 0)
			{
				vars = response->variables;
                if (vars)
				{
					//fprint_objid(stderr, vars->name, vars->name_length);
					snprint_objid(errorString, errorString_Length, vars->name, vars->name_length);
					NSLog(@"Failed object: %@", [NSString stringWithFormat:@"%s",errorString]);
				}
            }
		}	
		
	}
	if (response)
	{
		snmp_free_pdu(response);
	}
}

@end
