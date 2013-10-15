#include "const.h"
#include "readings.h"

unsigned short sensorValues[totalNumberOfSensors];

static void storeValueInternal(unsigned int sensorNumber, unsigned short value);
static unsigned short getValueInternal(unsigned int sensorNumber);

void storeValue(unsigned char boardNumber, unsigned char rowNumber, unsigned char pinNumber, unsigned short value)
{
    storeValueInternal((unsigned int)(boardNumber) * numberOfSensorsPerBoard + rowNumber * numberOfSensorsPerRow + pinNumber, value);
}

static void storeValueInternal(unsigned int sensorNumber, unsigned short value)
{
    sensorValues[sensorNumber] = value;
}

unsigned short getValue(unsigned char boardNumber, unsigned char rowNumber, unsigned char pinNumber)
{
    return getValueInternal((unsigned int)(boardNumber) * numberOfSensorsPerBoard + rowNumber * numberOfSensorsPerRow + pinNumber);
}

static unsigned short getValueInternal(unsigned int sensorNumber)
{
    return sensorValues[sensorNumber];
}
