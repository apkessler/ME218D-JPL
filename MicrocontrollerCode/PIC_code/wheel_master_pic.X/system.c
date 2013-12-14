/******************************************************************************/
/*Files to Include                                                            */
/******************************************************************************/

#if defined(__XC)
    #include <xc.h>         /* XC8 General Include File */
#elif defined(HI_TECH_C)
    #include <htc.h>        /* HiTech General Include File */
#endif

#include <stdint.h>        /* For uint8_t definition */
#include <stdbool.h>       /* For true/false definition */

#include "system.h"

/* Refer to the device datasheet for information about available
oscillator configurations. */
void ConfigureOscillator(void)
{
    /* Add clock switching code. */
    // Using internal oscillator
    // at 16 MHz
    OSCCON |= (1 << _OSCCON_IRCF3_POSN |
               1 << _OSCCON_IRCF2_POSN |
               1 << _OSCCON_IRCF1_POSN |
               1 << _OSCCON_IRCF0_POSN);

    /* Typical actions in this function are to tweak the oscillator tuning
    register, select new clock sources, and to wait until new clock sources
    are stable before resuming execution of the main project. */
}
