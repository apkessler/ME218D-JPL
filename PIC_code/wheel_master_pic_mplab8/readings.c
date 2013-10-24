#include "const.h"
#include "readings.h"

unsigned short sensorValues[totalNumberOfSensors];

void storeValueInternal(unsigned int sensorNumber, unsigned short value);
unsigned short getValueInternal(unsigned int sensorNumber);

void storeValue(unsigned char boardNumber, unsigned char rowNumber, unsigned char pinNumber, unsigned short value)
{
    storeValueInternal((unsigned int)(boardNumber) * numberOfSensorsPerBoard + rowNumber * numberOfSensorsPerRow + pinNumber, value);
}

void storeValueInternal(unsigned int sensorNumber, unsigned short value)
{
    sensorValues[sensorNumber] = value;
}

unsigned short getValue(unsigned char boardNumber, unsigned char rowNumber, unsigned char pinNumber)
{
    return getValueInternal((unsigned int)(boardNumber) * numberOfSensorsPerBoard + rowNumber * numberOfSensorsPerRow + pinNumber);
}

unsigned short getValueInternal(unsigned int sensorNumber)
{
    return sensorValues[sensorNumber];
}
