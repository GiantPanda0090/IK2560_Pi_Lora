test_data = load ('..\data\test_data.dat');
longitude = test_data(:,1)
latitude = test_data(:,2)
initialx = longitude(1)
initialy = latitude(1)
distance = sqrt((longitude - initialx(1)).^2 + (latitude - initialy(1)).^2)
avg_power = mean(test_data,2)

xdata = distance(:)
ydata = avg_power
plot(xdata,ydata,'-o')


cf = fit(xdata,ydata,'poly2'); 
hold on
plot(cf,'-')

f = 868*10^6
Ldb = avg_power - avg_power(1)

%n = (20*log(f)-147.58 - Ldb)/10 /log(distance)

plot(xdata,Ldb,'-o')

legend('Power','Best Fit','Path Lost')
xlabel('Distance(Meters)'), ylabel('Path Lost(Watt)')
title('Free Space Path Lost Against Distance')

out = gca;
exportgraphics(out,'graph/graph.png','Resolution',300)
