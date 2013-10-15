/* 
 * File:   readings.h
 * Author: David
 *
 * Created on October 13, 2013, 9:31 PM
 */

#ifndef READINGS_H
#define	READINGS_H

#ifdef	__cplusplus
extern "C" {
#endif

    void storeValue(unsigned char boardNumber, unsigned char rowNumber, unsigned char pinNumber, unsigned short value);
    unsigned short getValue(unsigned char boardNumber, unsigned char rowNumber, unsigned char pinNumber);


#ifdef	__cplusplus
}
#endif

#endif	/* READINGS_H */

