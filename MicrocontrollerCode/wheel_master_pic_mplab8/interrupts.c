/******************************************************************************/
/*Files to Include                                                            */
/******************************************************************************/

#if defined(__XC)
    #include <xc.h>         /* XC8 General Include File */
#elif defined(HI_TECH_C)
    #include <htc.h>        /* HiTech General Include File */
#endif

#include <stdint.h>         /* For uint8_t definition */
#include <stdbool.h>        /* For true/false definition */

#include "const.h"
#include "readings.h"
#include "AD.h"

/******************************************************************************/
/* Interrupt Routines                                                         */
/******************************************************************************/

/* Baseline devices don't have interrupts. Note that some PIC16's 
 * are baseline devices.  Unfortunately the baseline detection macro is 
 * _PIC12 */
#ifndef _PIC12

void transmitValue(void);

void interrupt isr(void)
{
    /* This code stub shows general interrupt handling.  Note that these
    conditional statements are not handled within 3 seperate if blocks.
    Do not use a seperate if block for each interrupt flag to avoid run
    time errors. */

    // If AD conversion completion flag is set
    if ((PIR1 & _PIR1_ADIF_MASK) != 0)
    {
        // Clear interrupt flag
        PIR1 &= ~_PIR1_ADIF_MASK;

        // Start next AD conversion
    }
    // If timer 2 over flow flag is set
    else if ((PIR1 & _PIR1_TMR2IF_MASK) != 0)
    {
        static unsigned int count = 0;

        // Clear interrupt flag
        PIR1 &= ~_PIR1_TMR2IF_MASK;

        // Begin transmit of data to serial port (USART)
        if (++count >= SEND_TIMEOUT_MS)
        {
            count = 0;

            if ((PIR1 & _PIR1_TXIF_MASK) != 0)
            {
                // Enable transmit interrupt
                PIE1 |= _PIE1_TXIE_MASK;

                // Only send if transmit buffer is empty
                transmitValue();
            }
        }
    }
    // If USART transmit buffer is empty
    else if ((PIR1 & _PIR1_TXIF_MASK) != 0)
    {
        //PORTC |= 1;
        transmitValue();
        //PORTC &= ~1;
    }
}

void transmitValue()
{
    static unsigned char messageHeaderNumber = 0;
    static unsigned char byteNumber = 0;
    static unsigned char boardNumber = 0;
    static unsigned char rowNumber = 0;
    static unsigned char pinNumber = 0;
    
    // Slow down/wait some time to slow transmission to be able to print to screen fast enough
    //unsigned long i;
    //for (i = 0; i < 200; i++);

    // Clear interrupt flag
    // Cleared by hardware when buffer is full

    // Send next byte
    switch (messageHeaderNumber)
    {
        case 0:
            TXREG = boardNumber * numberOfRowsPerBoard + rowNumber;
            messageHeaderNumber++;
            return;
        case 1:
            // Don't send a separator after row number
            break;
            
            TXREG = SEPARATOR;
            messageHeaderNumber++;
            return;
        default:
        case 2:
            break;
    }
    
    switch (byteNumber)
    {
        case 0:
            // Send upper half of value
            TXREG = (unsigned char)(getValue(boardNumber, rowNumber, pinNumber) >> 8);
            //TXREG = (unsigned char)(getForce(boardNumber, rowNumber, pinNumber) >> 8);
            break;
        case 1:
            // Send lower half of value
            TXREG = (unsigned char)getValue(boardNumber, rowNumber, pinNumber);
            //TXREG = (unsigned char)getForce(boardNumber, rowNumber, pinNumber);
            break;
        default:
        case 2:
            // Send delimiter between sensor values
            if (pinNumber != numberOfSensorsPerRow - 1)
            {
                // Don't send separator between values
                //TXREG = SEPARATOR;
            }
            else
            {
                TXREG = '\n';
            }
            break;
    }

    // Move to next value
    byteNumber++;
    if (byteNumber % 3 == 0)
    {
        byteNumber = 0;
        pinNumber++;
        if (pinNumber % numberOfSensorsPerRow == 0)
        {
            pinNumber = 0;
            rowNumber++;
            if (rowNumber % numberOfRowsPerBoard == 0)
            {
                rowNumber = 0;
                boardNumber++;
                if (boardNumber % numberOfBoards == 0)
                {
                    boardNumber = 0;
                }
            }
        }
    }

    // If all values for the row have been sent
    if (pinNumber == 0 && byteNumber == 0)
    {
        // Disable transmit buffer empty interrupt
        PIE1 &= ~_PIE1_TXIE_MASK;
        
        // Reset flag to send message header
        messageHeaderNumber = 0;
    }
}

#endif


