#ifndef _GPS_API
#define _GPS_API

#define GPS_ERR_NULL_ARGUMENT   -1
#define GPS_ERR_INITIALIZATION  -2
#define GPS_ERR_GPSD            -3
#define GPS_ERR_NO_DATA         -4

int gps_start(void);
int gps_stop(void);
int gps_get_position(double *latitude, double *longitude);

#endif /* _GPS_API */
