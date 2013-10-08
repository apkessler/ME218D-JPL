/****************************************************************************
 
  Header file for template Flat Sate Machine 
  based on the Gen2 Events and Services Framework

 ****************************************************************************/

#ifndef FSMTemplate_H
#define FSMTemplate_H

// Event Definitions
#include "ES_Configure.h"
#include "ES_Types.h"

// typedefs for the states
// State definitions for use with the query function
typedef enum { InitPState, UnlockWaiting, _1UnlockPress, 
               _2UnlockPresses, Locked } TemplateState_t ;


// Public Function Prototypes

boolean InitTemplateFSM ( uint8_t Priority );
boolean PostTemplateFSM( ES_Event ThisEvent );
ES_Event RunTemplateFSM( ES_Event ThisEvent );
TemplateState_t QueryTemplateSM ( void );


#endif /* FSMTemplate_H */

