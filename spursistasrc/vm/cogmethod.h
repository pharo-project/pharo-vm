/* Automatically generated by
	CCodeGenerator VMMaker.oscog-eem.786 uuid: 425c25e8-f3f6-4f06-b2eb-392c5da0ed44
 */

typedef struct {
	unsigned short	homeOffset;
	unsigned short	startpc;
	unsigned int	padToWord;
	unsigned		cmNumArgs : 8;
	unsigned		cmType : 3;
	unsigned		cmRefersToYoung : 1;
	unsigned		cpicHasMNUCase : 1;
	unsigned		cmUsageCount : 3;
	unsigned		cmUsesPenultimateLit : 1;
	unsigned		cmUsesMethodClass : 1;
	unsigned		cmUnusedFlags : 2;
	unsigned		stackCheckOffset : 12;
 } CogBlockMethod;

typedef struct {
	sqLong	objectHeader;
	unsigned		cmNumArgs : 8;
	unsigned		cmType : 3;
	unsigned		cmRefersToYoung : 1;
	unsigned		cpicHasMNUCase : 1;
	unsigned		cmUsageCount : 3;
	unsigned		cmUsesPenultimateLit : 1;
	unsigned		cmUsesMethodClass : 1;
	unsigned		cmUnusedFlags : 2;
	unsigned		stackCheckOffset : 12;
	unsigned short	blockSize;
	unsigned short	blockEntryOffset;
	sqInt	methodObject;
	sqInt	methodHeader;
	sqInt	selector;
	sqInt	numCounters;
 } CogMethod;

#define SistaCogMethod CogMethod
