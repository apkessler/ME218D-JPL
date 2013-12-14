/* 
 * File:   AD.h
 * Author: David
 *
 * Created on October 13, 2013, 8:41 PM
 */

#ifndef AD_H
#define	AD_H

#ifdef	__cplusplus
extern "C" {
#endif

void AD_Init(void);         /* AD converter initialization */
unsigned short AD_Read(unsigned char channel);


#ifdef	__cplusplus
}
#endif

#endif	/* AD_H */

