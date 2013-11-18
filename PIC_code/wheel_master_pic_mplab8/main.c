/******************************************************************************/
/* Files to Include                                                           */
/******************************************************************************/

#if defined(__XC)
    #include <xc.h>         /* XC8 General Include File */
#elif defined(HI_TECH_C)
    #include <htc.h>        /* HiTech General Include File */
#endif

#include <stdint.h>        /* For uint8_t definition */
#include <stdbool.h>       /* For true/false definition */

#include "system.h"        /* System funct/params, like osc/peripheral config */
#include "user.h"          /* User funct/params, such as InitApp */
#include "const.h"
#include "readings.h"
#include "AD.h"

/******************************************************************************/
/* User Global Variable Declaration                                           */
/******************************************************************************/

/* i.e. uint8_t <variable_name>; */

static unsigned char controlLines[32] =
{
     7, 5, 3, 1, 8,10,12,14,
     6, 4, 2, 0, 9,11,13,15,
    22,20,18,16,25,27,29,31,
    23,21,19,17,24,26,28,30
};

/******************************************************************************/
/* Main Program                                                               */
/******************************************************************************/
void main(void)
{
    /* Configure the oscillator for the device */
    ConfigureOscillator();

    /* Initialize I/O and Peripherals for application */
    InitApp();

    // Make C0 an output for debugging
    ANSELC &= ~1;
    TRISC &= ~1;

    while(1)
    {
        /* <INSERT USER APPLICATION CODE HERE> */
        static unsigned char boardNumber = 0;
        static unsigned char rowNumber = 0;
        static unsigned char pinNumber = 0;
        static unsigned short value = 0;
        static unsigned char i = 0;

        static const unsigned char portMask = 0x1f;
        static unsigned char outputValue = 0;
        
        // Select proper row and pin on board
        // Ports B0-B4
        //PORTB &= ~portMask
        //PORTB &= (~portMask | (rowNumber << 3 | pinNumber));
        //PORTB |= (portMask & (rowNumber << 3 | pinNumber));

        //if (pinNumber % 2 != 0) {PORTB |= 1;} else {PORTB &= ~1;}
        //if (pinNumber/2 % 2 != 0) {PORTB |= 2;} else {PORTB &= ~2;}
        //if (pinNumber/4 % 2 != 0) {PORTB |= 4;} else {PORTB &= ~4;}
        //if (rowNumber % 2 != 0) {PORTB |= 8;} else {PORTB &= ~8;}
        //if (rowNumber/2 % 2 != 0) {PORTB |= 16;} else {PORTB &= ~16;}

        // For actual PCB, due to sequential headers instead of alternating rows
        outputValue = controlLines[8*rowNumber + pinNumber];
        if (outputValue % 2 != 0)    {PORTB |= 1;}  else {PORTB &= ~1;}
        if (outputValue/2 % 2 != 0)  {PORTB |= 2;}  else {PORTB &= ~2;}
        if (outputValue/4 % 2 != 0)  {PORTB |= 4;}  else {PORTB &= ~4;}
        if (outputValue/8 % 2 != 0)  {PORTB |= 8;}  else {PORTB &= ~8;}
        if (outputValue/16 % 2 != 0) {PORTB |= 16;} else {PORTB &= ~16;}

        for (boardNumber = 0; boardNumber < numberOfBoards; boardNumber++)
        {
            // Read AD value
            value = AD_Read(boardNumber);

            // Store value to array
            storeValue(boardNumber, rowNumber, pinNumber, 1023 - value);
        }

        if (++pinNumber % numberOfSensorsPerRow == 0)
        {
            pinNumber = 0;
            if (++rowNumber % numberOfRowsPerBoard == 0)
            {
                rowNumber = 0;
            }
        }
        
        //if (i++ % 2 == 0) {PORTC |= 1;} else {PORTC &= ~1;i = 0;}
        /*
        if (i++ % 2 == 0)
        {
            PORTC |= 1;
        }
        else
        {
            PORTC &= ~1;
            i = 0;
        }
        */
    }

}

