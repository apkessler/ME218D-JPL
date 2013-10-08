#include <stdio.h>
#include "ES_Configure.h"
#include "ES_Framework.h"
#include "ES_Timers.h"

void main( void) {
ES_Return_t ErrorType;

// When doing testing, it is usefull to annouce just which program
// is running.
puts("Starting Remote Lock State Machine (2) \r");
puts("using the 2nd Generation Events & Services Framework\n\r");
puts(" Press 'u' to unlock or 'l' to locks\n\r");

// Your hardware initialization function calls go here

// now initialize the Events and Services Framework and start it running
ErrorType = ES_Initialize(ES_Timer_RATE_1MS);
if ( ErrorType == Success ) {

  ErrorType = ES_Run();

}
//if we got to here, there was an error
switch (ErrorType){
  case FailedPointer:
    puts("Failed on NULL pointer");
    break;
  case FailedInit:
    puts("Failed Initialization");
    break;
 default:
    puts("Other Failure");
    break;
}
for(;;)
  ;

};

/*------------------------------- Footnotes -------------------------------*/
/*------------------------------ End of file ------------------------------*/
