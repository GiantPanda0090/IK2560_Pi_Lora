#include <gps.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <math.h>
#include <errno.h>

static int started = 0;
static struct gps_data_t gps_data;

int gps_initialize(void)
{
	if (started)
		return GPS_ERR_INITIALIZATION;

	if ((gps_open("localhost", "2947", &gps_data)) == -1) {
	    printf("code: %d, reason: %s\n", errno, gps_errstr(errno));
	    return GPS_ERR_GPSD;
	}
	gps_stream(&gps_data, WATCH_ENABLE | WATCH_JSON, NULL);
	started = 1;

	return 0;
}

int gps_get_position(double *latitude, double *longitude)
{
	int i, attempts = 5;

	if (latitude == NULL || longitude == NULL)
		return GPS_ERR_NULL_ARGUMENT;
        if (!started)
                return GPS_ERR_INITIALIZATION;

	for (i = 0; i < attempts; i++) {
	    /* wait for 2 seconds to receive data */
	    if (gps_waiting (&gps_data, 2000000)) {
		/* read data */
		if ((gps_read(&gps_data,NULL,0)) == -1) {
		    printf("error occured reading gps data. code: %d, reason: %s\n", errno, gps_errstr(errno));
		} else {
		    /* Display data from the GPS receiver. */
		    if ((gps_data.status == STATUS_FIX) && 
		        (gps_data.fix.mode == MODE_2D || gps_data.fix.mode == MODE_3D) &&
		        !isnan(gps_data.fix.latitude) && 
		        !isnan(gps_data.fix.longitude)) {
		            *latitude = gps_data.fix.latitude;
	                    *longitude = gps_data.fix.longitude;
	                    return 0;
		            //printf("latitude: %f, longitude: %f, speed: %f, timestamp: %lf\n", gps_data.fix.latitude, gps_data.fix.longitude, gps_data.fix.speed, gps_data.fix.time); //EDIT: Replaced tv.tv_sec with gps_data.fix.time
		    } else {
		        printf("no GPS data available\n");
		    }
		}
	    }

	    sleep(3);
	}
	return GPS_ERR_NO_DATA;
}

int gps_stop(void)
{
	if (!started)
		return GPS_ERR_INITIALIZATION;

	gps_stream(&gps_data, WATCH_DISABLE, NULL);
	gps_close (&gps_data);
	started = 0;

	return 0;
}
