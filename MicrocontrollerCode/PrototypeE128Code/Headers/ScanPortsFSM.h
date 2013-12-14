/****************************************************************************
 
  Header file for reading AD ports and sending over serial
  based on the Gen2 Events and Services Framework

 ****************************************************************************/

#ifndef ScanPortsFSM_H
#define ScanPortsFSM_H

// Event Definitions
#include "ES_Configure.h"
#include "ES_Types.h"

// typedefs for the states
// State definitions for use with the query function
typedef enum { InitPState, Scanning } ScanPortsState_t;


// Public Function Prototypes

boolean InitScanPortsFSM ( uint8_t Priority );
boolean PostScanPortsFSM( ES_Event ThisEvent );
ES_Event RunScanPortsFSM( ES_Event ThisEvent );
ScanPortsState_t QueryScanPortsFSM ( void );


#endif /* ScanPortsFSM_H */

