%init variables
rssi=double.empty(7,0);
snr=double.empty(7,0);
distance=double.empty(7,0);
n_list=double.empty(1,0);

%plot operations
files = dir('..\data\data_*.dat');
for i=1:length(files)
    current_file = load(strcat(files(i).folder,'\',files(i).name), '-ascii')
    longitude=current_file(:,1);
    latitude=current_file(:,2);
    initialx = longitude(1)
    initialy = latitude(1)
    distance = [distance,sqrt((longitude - initialx(1)).^2 + (latitude - initialy(1)).^2)]
    rssi=[rssi,current_file(:,3)];
    snr=[snr,current_file(:,4)];
end
rssi_avg= mean(rssi,2)
snr_avg= mean(snr,2)
hf_constant = -157
lf_constant = -164
rssi_dbm = hf_constant + rssi_avg
distance_avg = mean(distance,2)
packet_strength= rssi_dbm + snr_avg * 0.25

avg_power = packet_strength
xdata = distance_avg(:)
ydata = avg_power
plot(xdata,ydata,'-o')

cf = fit(xdata,ydata,'poly2'); 
hold on
plot(cf,'-')

Ldb = avg_power - avg_power(1)
plot(xdata,Ldb,'--')

legend('Power','Best Fit','Path Lost')
xlabel('Distance(Meters)'), ylabel('Power(dbm)')
title('Free Space Path Lost Against Distance')

out = gca;
exportgraphics(out,'result/graph/graph.png','Resolution',300)

%Equition Solver for N
%n = (20*log(f)-147.58 - Ldb)/10 /log(distance)
f = 868*10^6
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



