figure('Units', 'pixels', 'Position', [100 100 560 420]);
ax = axes('Units', 'normalized');

[X,Y] = meshgrid(-2:0.25:2);
Z = X.*exp(-X.^2 - Y.^2);
surf(X,Y,Z)

c = colorbar;
c.Label.String = 'Temperature (K)';
c.Label.FontName = 'Arial';
c.Label.FontSize = 12;

% Get and display properties
disp('Figure Properties:')
disp(get(gcf))

disp('Axes Properties:')
disp(get(gca))

disp('Colorbar Properties:')
disp(get(c))
disp('Colorbar Label Properties:')
disp(get(c.Label))