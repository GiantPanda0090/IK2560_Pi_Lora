
files = dir(['..' filesep 'data' filesep 'data_*.dat'])
%dir('..\data\data_*.dat');
demo_file = load(strcat(files(1).folder,'\',files(1).name), '-ascii')
row_length=length(demo_file(1,:))
%init variables
n_list=double.empty(1,0);
data_table =double.empty(0,row_length);
path = double.empty(0,row_length)
%plot operations
for i=1:length(files)
    current_file = load(strcat(files(i).folder,'\',files(i).name), '-ascii')
    data_table = [data_table;current_file]
    data_table=round(data_table,3)

    %longitude=current_file(:,3);
    %latitude=current_file(:,4);
    %initialx = current_file(:,1);
    %initialy = current_file(:,2);
    %dist =mean(current_file(:,1),1);
    %dist = [dist,distance(initialx,initialy,latitude,longitude)]
    %rssi=mean(current_file(:,2),1);
    %packet_rssi = mean(current_file(:,3),1);
    %snr= mean(current_file(:,4),1);
    %data_table = [data_table;[dist,rssi,packet_rssi,snr]]
end
dist=data_table(:,1)
rssi=data_table(:,2)
packet_rssi = data_table(:,3)
snr = data_table(:,4)
%A = unique(table(dist,rssi,packet_rssi,snr))
%uni_dist = unique(A.dist)

[ii,jj,kk]=unique(data_table(:,1))
distance_avg = ii
rssi_avg=[ii accumarray(kk,data_table(:,2),[],@mean)]
rssi_avg=rssi_avg(:,2)
packet_rssi_avg=[ii accumarray(kk,data_table(:,3),[],@mean)]
packet_rssi_avg=packet_rssi_avg(:,2)
snr_avg=[ii accumarray(kk,data_table(:,4),[],@mean)]
snr_avg=snr_avg(:,2)

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
plot(cf,'--')
legend('Power','Best Fit')
xlabel('Distance(km)'), ylabel('Power(dbm)')
title('Power Against Distance')

out = gca;
exportgraphics(out,'result/graph/distance_path_lost.png','Resolution',500)

figure(2);
%RSSI(avg_power) = init_power +gain − Ldb +gain dBm.
%Ldb = init_power +gain -RSSI(avg_power)+gain 
init_power = 13
gain = 17
transmit_power = init_power+gain
Ldb = transmit_power - avg_power -gain
plot(xdata,Ldb,'-')

myfittype = fittype('a +10*n*log10(d*10^3) -b',...
    'dependent',{'y'},'independent',{'d'},...
    'coefficients',{'a','n','b'})
cf = fit(xdata,Ldb,myfittype); 
hold on
plot(cf,'--')
legend('Path Lost','Best Fit')
xlabel('Distance(km)'), ylabel('Power(dbm)')
title('Path Lost Against Distance')


out = gca;
exportgraphics(out,'result/graph/distance_power.png','Resolution',500)

%Equition Solver for N
%n = (20*log(f)-147.58 - Ldb)/10 /log(distance)
f =  868.1*10^6
syms n
for i=1:length(distance_avg)
eqn = 20*log10(f)+10*n*log10(distance_avg(i)) + -147.58 == Ldb(i)
N_division = solve(eqn,n)
%N=vpa(N_division,2)
n_list = [n_list;N_division]
end
n_list=vpa(n_list,2)

n_avg= mean(n_list,1)

print_data=table(distance_avg,n_list)

%write result to file
fileID = fopen('result/output/n.txt','w');
fprintf(fileID,'%6s %6s\n','distance_avg','n_avg');
fprintf(fileID,'%d %10f\n',[print_data.distance_avg,print_data.n_list]);
fprintf(fileID,'\nn = %2.2f \n',n_avg)
fprintf(fileID,'Path Loss Model: Ldb = 20*log(f)+10*%0.2f*log(d) + -147.58   \n',n_avg);
fclose(fileID);

figure(3);
receive_power_lst = transmit_power-Ldb
rssi_lst = receive_power_lst+gain
for i=1:length(rssi_avg)
    cur_path=[init_power;transmit_power;receive_power_lst(i);rssi_lst(i);rssi_lst(i)];
    path = [path,cur_path];
end
x_path = {'1 - TX Radio','2 - PA TX','3 - Path Loss','4 - PA RX','5 - RSSI'}
C = categorical(x_path)

plot(C,path)
xlabel('Stage of the Transmission'), ylabel('Power(dbm)')
title('Power Development Along the Radio Path Per Distance Unit')
out = gca;
exportgraphics(out,'result/graph/power_path.png','Resolution',500)


