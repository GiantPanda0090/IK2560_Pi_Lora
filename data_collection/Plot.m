
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
end
dist=data_table(:,1)
rssi=data_table(:,2)
packet_rssi = data_table(:,3)
snr = data_table(:,4)

%load expierment data
[ii,jj,kk]=unique(data_table(:,1))
distance_avg = ii
rssi_avg=[ii accumarray(kk,data_table(:,2),[],@mean)]
rssi_avg=rssi_avg(:,2)
packet_rssi_avg=[ii accumarray(kk,data_table(:,3),[],@mean)]
packet_rssi_avg=packet_rssi_avg(:,2)
snr_avg=[ii accumarray(kk,data_table(:,4),[],@mean)]
snr_avg=snr_avg(:,2)

%confidence interval
CI_rssi=double.empty(1,0);
CI_prssi=double.empty(1,0);
packet_count=double.empty(1,0);
for i=1:length(ii)
    section_ind = find(data_table(:,1)==ii(i))
    section = data_table(section_ind,:)
    packet_count = [packet_count,length(section)]
    N = size(section,1)
    ySEM = std(section)/sqrt(N); 
    CI95 = tinv([0.025 0.975], N-1); 
    yCI95 = bsxfun(@times, ySEM, CI95(:)); 
    CI_rssi = [CI_rssi,yCI95(:,2)]
    CI_prssi = [CI_prssi,yCI95(:,3)]
end
lowerthanzero = find(snr_avg<0);
upperthanzero = find(snr_avg>0);
CI95=double.empty(2,0);

for i=1:length(CI_rssi)
    if ismember(i,lowerthanzero)
        CI95 = [CI95,CI_rssi(:,i)]
    else
       CI95 = [CI95,CI_prssi(:,i)]
    end
end

% Put SNR into the consideration
packet_strength=double.empty(1,0);
for i=1:length(snr_avg)
    if snr_avg(i) < 0
        packet_strength= [packet_strength;packet_rssi_avg(i) + snr_avg(i) * 0.25]
    else 
        packet_strength= [packet_strength;rssi_avg(i)]
    end

end

%Graphing

%Power over Distance
figure(1);
avg_power = packet_strength
xdata = distance_avg(:)
ydata = avg_power
plot(xdata,ydata,'-o')

%set(gca,'YScale','log')
%set(gca,'XScale','log')
hold on
patch([xdata', fliplr(xdata')], [ydata'+CI95(1,:) fliplr(ydata'+CI95(2,:))], 'b', 'EdgeColor','none', 'FaceAlpha',0.25)

cf = fit(xdata,ydata,'poly2'); 
plot(cf,'--')

hold off
grid

legend('Power','Confidence Interval','Best Fit')
xlabel('Distance(m)'), ylabel('Power(dbm)')
title('Power Over Distance')
out = gca;
exportgraphics(out,'result/graph/distance_power.png','Resolution',500)

%Power Over Distance (Log)
figure(2);
avg_power = packet_strength
xdata = distance_avg(:)
ydata = avg_power
plot(xdata,ydata,'-o')

set(gca,'YScale','log')
set(gca,'XScale','log')

hold on
cf = fit(xdata,ydata,'poly2'); 
plot(cf,'--')

hold off
grid
legend('Power','Best Fit')
xlabel('Distance(m)'), ylabel('Power(dbm)')
title('Power Over Distance (Log Scale)')
out = gca;
exportgraphics(out,'result/graph/distance_power_log.png','Resolution',500)

%SNR over Distance
figure(3);
xdata = distance_avg(:)
ydata = snr_avg
plot(xdata,ydata,'-o')

%set(gca,'YScale','log')
%set(gca,'XScale','log')

hold on
cf = fit(xdata,ydata,'poly2'); 
plot(cf,'--')

hold off
grid
legend('SNR','Best Fit')
xlabel('Distance(m)'), ylabel('SNR(db)')
title('SNR Over Distance')
out = gca;
exportgraphics(out,'result/graph/distance_snr_log.png','Resolution',500)

%Path Lost Over Distance(Log Scale)
%RSSI(avg_power) = init_power +gain − Ldb +gain dBm.
%Ldb = init_power +gain -RSSI(avg_power)+gain 
figure(4);
init_power = 13
gain = 17
transmit_power = init_power+(gain+2.51)
Ldb = transmit_power - avg_power-(gain+2.51)
plot(xdata,Ldb)
set(gca,'YScale','log')
set(gca,'XScale','log')

myfittype = fittype('a +10*n*log10(d*10^3) -b',...
    'dependent',{'y'},'independent',{'d'},...
    'coefficients',{'a','n','b'})
cf = fit(xdata,Ldb,'poly2'); 
hold on
plot(cf,'--')
legend('Path Loss','Best Fit')
xlabel('Distance(m)'), ylabel('Power(dbm)')
title('Path Lost Over Distance(Log Scale)')

out = gca;
exportgraphics(out,'result/graph/distance_path_lost.png','Resolution',500)

%Equition Solver for N
%n = (20*log(f)-147.58 - Ldb)/10 /log(distance)
f =  868.1*10^6
syms n
for i=2:length(distance_avg)
    eqn = 20*log10(f)+10*n*log10(distance_avg(i)) + -147.58 == Ldb(i)
    N_division = solve(eqn,n)
    n_list = [n_list;N_division]
end
n_list=vpa(n_list,2)

n_avg= mean(n_list,1)
print_distance_avg=distance_avg
print_distance_avg(1)=[]
print_data=table(print_distance_avg,n_list)

%write result to file
fileID = fopen('result/output/n.txt','w');
fprintf(fileID,'%6s %6s\n','distance_avg','n_avg');
fprintf(fileID,'%d %10f\n',[print_data.print_distance_avg,print_data.n_list]);
fprintf(fileID,'\nn = %2.2f \n',n_avg)
fprintf(fileID,'Path Loss Model: Ldb = 20*log(f)+10*%0.2f*log(d) + -147.58   \n',n_avg);
fclose(fileID);

%Power Development
figure(5);
receive_power_lst = transmit_power-Ldb
rssi_lst = receive_power_lst+gain
antenna_gain = transmit_power+2.15 
for i=1:length(rssi_avg)
    cur_path=[init_power;transmit_power;antenna_gain;antenna_gain-22.85;receive_power_lst(i);receive_power_lst(i)+2.15;rssi_lst(i);rssi_lst(i)];
    path = [path,cur_path];
end
x_path = {'1 - TX Radio','2 - PA TX','3 - Antenna Gain RX','4 - Attenuation(Brick 267mm)','5 - Path Loss','6 - Antenna Gain RX','7 - PA RX','8 - RSSI'}
C = categorical(x_path)

plot(C,path)
legendCell = cellstr(num2str(xdata, '%0.1d'));
lgd = legend(legendCell)
lgd.NumColumns = 3;

xlabel('Stage of the Transmission'), ylabel('Power(dbm)')
title('Power Development Along the Radio Path Per Distance Unit')
out = gca;
exportgraphics(out,'result/graph/power_path.png','Resolution',700)


