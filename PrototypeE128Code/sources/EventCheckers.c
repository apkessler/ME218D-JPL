// Event Checking functions for sample

#include "ES_Configure.h"
#include "ES_General.h"
#include "ES_Events.h"
#include "ES_PostList.h"
#include "EventCheckers.h"
#include "ScanPortsFSM.h"

// This include will pull in all of the headers from the service modules
// providing the prototypes for all of the post functions
#include "ES_ServiceHeaders.h"

boolean Check4Lock(void)
{
  /*
  ES_Event event;
  
  PostScanPortsFSM(event);
  
  return True;
  */
  
  return False;
}

boolean Check4Unlock(void)
{
  return False;
}

