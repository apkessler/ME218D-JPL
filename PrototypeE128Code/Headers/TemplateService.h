/****************************************************************************
 
  Header file for template service 
  based on the Gen 2 Events and Services Framework

 ****************************************************************************/

#ifndef ServTemplate_H
#define ServTemplate_H

#include "ES_Types.h"

// Public Function Prototypes

boolean InitTemplateService ( uint8_t Priority );
boolean PostTemplateService( ES_Event ThisEvent );
ES_Event RunTemplateService( ES_Event ThisEvent );


#endif /* ServTemplate_H */

