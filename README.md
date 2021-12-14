# IK2560_Pi_Lora
## Golden Rules  
1. Make your own branch before make changes  
2. Pull daily before you make changes  
3. Before merge to the "Main" Branch, Pull request need to be issued. For each pull request, at least 2 team member need to review before the branch can be merge  
4. Main branch will be used to test on the hardware. Talk to William if you to test your branch individually.  

## How to Use
1. Install dependencies
```sh
sudo apt-get install libgps-dev wiringpi gpsd gpsd-clients python-gps
```
2. Follow [this guide](https://wiki.dragino.com/index.php?title=Getting_GPS_to_work_on_Raspberry_Pi_3_Model_B) for details regarding how to get the GPS to work on a Raspberry Pi 3
3. Build workbench
```sh
cd lora
make
```
4. Start gspd
```sh
sudo gpsd /dev/ttyS0 -F /var/run/gpsd.sock
```
5. Start testbench in sender or receiver mode
```sh
./lora_test sender
```
or
```sh
lora_test rec
```
