#if defined(__XC)
    #include <xc.h>         /* XC8 General Include File */
#elif defined(HI_TECH_C)
    #include <htc.h>        /* HiTech General Include File */
#endif

#include "AD.h"

static const unsigned char ADReadArray[10] = {0b00000001,
                                              0b00000101,
                                              0b00001001,
                                              0b00001101,
                                              0b00010001,

                                              0b00110101,
                                              0b00111001,
                                              0b00111101,
                                              0b01000001,
                                              0b01000101};

void AD_Init(void)
{
    // Set AN0-AN4, AN13-17 as analog inputs
    //ANSELA = 0x2f; // 0010 1111
    ANSELA |= (1 << _ANSELA_ANSA5_POSN |
               1 << _ANSELA_ANSA3_POSN |
               1 << _ANSELA_ANSA2_POSN |
               1 << _ANSELA_ANSA1_POSN |
               1 << _ANSELA_ANSA0_POSN);
    ANSELB = 0x20; // 0010 0000
    ANSELC = 0x7f; // 0111 1111
    
    // Set corresponding pins as inputs
    TRISA |= 0x2f; // 0010 1111
    TRISC |= 0xbc; // 1011 1100

    // Set AD conversion clock
    ADCON1 |= (1 << _ADCON1_ADCS2_POSN |
               0 << _ADCON1_ADCS1_POSN |
               1 << _ADCON1_ADCS0_POSN);
    ADCON1 &= (1 << _ADCON1_ADCS2_POSN |
               0 << _ADCON1_ADCS1_POSN |
               1 << _ADCON1_ADCS0_POSN);

    // Set left justification
    ADCON1 &= ~_ADCON1_ADFM_MASK;
}

unsigned short AD_Read(unsigned char channel)
{
    int i;
    unsigned long returnValue;

    // Select channel
    ADCON0 = ADReadArray[channel];

    // Wait acquisition time
    for (i = 0; i < 36; i++);

    // Set GO bit
    ADCON0 |= _ADCON0_ADGO_MASK;

    // Wait until conversion finishes
    while ((ADCON0 & _ADCON0_ADGO_MASK) != _ADCON0_ADGO_MASK);

    returnValue = (unsigned short)((unsigned int)ADRESH << 2 + ADRESL >> 6);

    return (unsigned short)returnValue;
}