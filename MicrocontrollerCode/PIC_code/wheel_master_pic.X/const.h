/* 
 * File:   const.h
 * Author: David
 *
 * Created on October 13, 2013, 9:52 PM
 */

#ifndef CONST_H
#define	CONST_H

#define numberOfSensorsPerRow 8
#define numberOfRows 28
#define numberOfSensorsPerBoard 32
#define numberOfBoards 7
#define numberOfRowsPerBoard 4
// totalNumberOfSensors = numberOfSensorsPerRow * numberOfRows
#define totalNumberOfSensors 224

// Space = 0x20, comma = 0x2c, semicolon = 0x3b
#define SEPARATOR 0x20

// Number of ms between lines sent to PC
#define SEND_TIMEOUT_MS 1000

#endif	/* CONST_H */

