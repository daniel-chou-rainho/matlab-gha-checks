% Create sample data
[X,Y] = meshgrid(-2:0.2:2);
Z = X.*exp(-X.^2 - Y.^2);

% Create surface plot
figure
f = gcf;
ax = axes;
surf(X,Y,Z)
c = colorbar;
c.Label.String = 'Z Value';

xlabel('X axis');
ylabel('Y axis'); 
title('Surface Plot');

colorbarLabels = findall(groot, 'Type', 'text', 'Parent', c)