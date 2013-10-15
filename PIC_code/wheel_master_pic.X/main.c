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

/******************************************************************************/
/* Main Program                                                               */
/******************************************************************************/
void main(void)
{
    /* Configure the oscillator for the device */
    ConfigureOscillator();

    /* Initialize I/O and Peripherals for application */
    InitApp();


    while(1)
    {
        /* <INSERT USER APPLICATION CODE HERE> */
        static unsigned char boardNumber = 0;
        static unsigned char rowNumber = 0;
        static unsigned char pinNumber = 0;
        static unsigned short value = 0;

        static const unsigned char portMask = 0x1f;
        
        // Select proper row and pin on board
        // Ports B0-B4
        PORTB &= ~portMask;
        PORTB |= portMask & (rowNumber << 3 + pinNumber);

        for (boardNumber = 0; boardNumber < numberOfBoards; boardNumber++)
        {
            // Read AD value
            value = AD_Read(boardNumber);

            // Store value to array
            storeValue(boardNumber, rowNumber, pinNumber, value);
        }

        if (++pinNumber % numberOfSensorsPerRow == 0)
        {
            pinNumber = 0;
            if (++rowNumber % numberOfRowsPerBoard == 0)
            {
                rowNumber = 0;
            }
        }
    }

}

