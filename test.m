% Create sample data
[X,Y] = meshgrid(-2:0.2:2);
Z = X.*exp(-X.^2 - Y.^2);

% Create surface plot
figure
surf(X,Y,Z)
colorbar
title('Surface Plot')

% Get all graphics objects
allObjs = findall(gcf);

x = struct(gcf)