test_data = load ('..\data\test_data.dat');
xdata = test_data(:,1)
ydata = test_data(:,2)
plot(xdata,ydata,'-o')
xlabel('Distance(Meters)'), ylabel('Path Lost(Watt)')
title('Free Space Path Lost Against Distance')


P = polyfit(xdata,ydata,1); 
xfit = xdata; 
yfit = polyval(P,xfit); 
hold on
plot(xfit,yfit,'-')
legend('Path Lost','Best Fit');
f = gca;
exportgraphics(f,'graph/graph.png','Resolution',300)
