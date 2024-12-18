figure('Units', 'pixels', 'Position', [100 100 560 420], 'Renderer', 'painters');
ax = axes('Units', 'normalized');
[X,Y] = meshgrid(-2:0.25:2);
Z = X.*exp(-X.^2 - Y.^2);
surf(X,Y,Z)
c = colorbar;
c.Label.String = 'Temperature (K)';
c.Label.FontName = 'Arial';
c.Label.FontSize = 12;

disp('Axes Position:')
disp(get(gca,'Position'))
disp('Colorbar Position:')
disp(get(c,'Position'))
disp('Colorbar Label Extent:')
disp(get(c.Label,'Extent'))