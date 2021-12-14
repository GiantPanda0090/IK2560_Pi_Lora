
files = dir(['..' filesep 'data' filesep 'data_*.dat'])
%dir('..\data\data_*.dat');
data_length=length(load(strcat(files(1).folder,'\',files(1).name), '-ascii'))
%init variables
rssi=double.empty(data_length,0);
snr=double.empty(data_length,0);
dist=double.empty(data_length,0);
n_list=double.empty(1,0);
packet_rssi=double.empty(data_length,0);
path=double.empty(data_length,0);

%plot operations
for i=1:length(files)
    current_file = load(strcat(files(i).folder,'\',files(i).name), '-ascii')
    longitude=current_file(:,3);
    latitude=current_file(:,4);
    initialx = current_file(:,1);
    initialy = current_file(:,2);


    dist = [dist,distance(initialx,initialy,latitude,longitude)]
    rssi=[rssi,current_file(:,5)];
    packet_rssi = [packet_rssi,current_file(:,6)];
    snr=[snr,current_file(:,7)];
end
packet_rssi_avg= mean(packet_rssi,2)
rssi_avg= mean(rssi,2)
snr_avg= mean(snr,2)
distance_avg = mean(dist,2)
if snr_avg < 0
    packet_strength= packet_rssi_avg + snr_avg * 0.25
else 
    packet_strength= rssi_avg
end

figure(1);
avg_power = packet_strength
xdata = distance_avg(:)
ydata = avg_power
plot(xdata,ydata,'-o')

cf = fit(xdata,ydata,'poly2'); 
hold on
plot(cf,'-')

%RSSI(avg_power) = init_power +gain − Ldb +gain dBm.
%Ldb = init_power +gain -RSSI(avg_power)+gain 
init_power = 13
gain = 15
transmit_power = init_power+gain
Ldb = transmit_power - avg_power -gain
plot(xdata,Ldb,'--')

legend('Power','Best Fit','Path Lost')
xlabel('Distance(Meters)'), ylabel('Power(dbm)')
title('Free Space Path Lost Against Distance')

out = gca;
exportgraphics(out,'result/graph/distance_power.png','Resolution',300)

%Equition Solver for N
%n = (20*log(f)-147.58 - Ldb)/10 /log(distance)
f =  868.1*10^6
syms n
for i=2:length(distance_avg)
eqn = 20*log(f)+10*n*log(distance_avg(i)) + -147.58 == Ldb(i)
N_division = solve(eqn,n)
N=vpa(N_division)
n_list = [n_list;N]
end
n_avg= mean(n_list,1)
distance_avg(1) = [];
out=[distance_avg,n_list]

%write result to file
fileID = fopen('result/output/n.txt','w');
fprintf(fileID,'%6s %6s\n','distance_avg','n_avg');
fprintf(fileID,'%7.2f %10.2f\n',out);
fprintf(fileID,'\nn = %2.2f \n',n_avg)
fprintf(fileID,'Path Loss Model: Ldb = 20*log(f)+10*%0.2f*log(d) + -147.58   \n',n_avg);
fclose(fileID);

figure(2);
receive_power_lst = transmit_power-Ldb
rssi_lst = receive_power_lst+gain
for i=1:data_length
    cur_path=[init_power;transmit_power;receive_power_lst(i);rssi_lst(i)];
    path = [path,cur_path];
end
x_path = {'1 - TX Radio','2 - PA','3 - Path Lost','4 - RSSI'}
C = categorical(x_path)

plot(C,path)
xlabel('Stage of the Transmission'), ylabel('Power(dbm)')
title('Power Change Along the Radio Path Per Distance Unit')
out = gca;
exportgraphics(out,'result/graph/power_path.png','Resolution',500)


