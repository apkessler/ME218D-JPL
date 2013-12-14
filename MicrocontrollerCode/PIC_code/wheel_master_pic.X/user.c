/******************************************************************************/
/* Files to Include                                                           */
/******************************************************************************/

#if defined(__XC)
    #include <xc.h>         /* XC8 General Include File */
#elif defined(HI_TECH_C)
    #include <htc.h>        /* HiTech General Include File */
#endif

#include <stdint.h>         /* For uint8_t definition */
#include <stdbool.h>        /* For true/false definition */

#include "user.h"
#include "AD.h"

/******************************************************************************/
/* User Functions                                                             */
/******************************************************************************/

/* <Initialize variables in user.h and insert code for user algorithms.> */

void InitApp(void)
{
    /* Initialize User Ports/Peripherals/Project here */

    /* Setup analog functionality and port direction */
    // Clear all analog functionality
    ANSELA = 0;
    ANSELB = 0;
    ANSELC = 0;

    // Set B0-B4 as outputs to control mux(s)
    TRISB = 0x1f; // 0001 1111

    // Enable only specific ports as analog
    AD_Init();

    /* Initialize peripherals */
    // Enable UART
    // Set baud rate to 115200
    BAUDCON |= _BAUDCON_BRG16_MASK;
    TXSTA |= _TXSTA_BRGH_MASK;
    SPBRGH = 0;
    SPBRGL = 34;
    TXSTA |= _TXSTA_TXEN_MASK;
    RCSTA |= _RCSTA_SPEN_MASK;

    /* Enable interrupts */
    PIE1 |= _PIE1_ADIE_MASK | _PIE1_TXIE_MASK | _PIE1_TMR2IE_MASK;
    INTCON |= _INTCON_PEIE_MASK;
    INTCON |= _INTCON_GIE_MASK;

    // Start timer 2
    // Prescale = 16
    T2CON |= _T2CON_T2CKPS1_MASK;
    T2CON &= _T2CON_T2CKPS0_MASK;
    PR2 = 250;
    T2CON |= _T2CON_TMR2ON_MASK;
}

