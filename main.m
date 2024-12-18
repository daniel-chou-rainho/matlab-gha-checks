figure('Units', 'pixels', 'Position', [100 100 560 420]);
ax = axes('Units', 'normalized');
x = rand(10);
surf(x)
c = colorbar;
disp('Screen DPI:')
disp(get(0,'ScreenPixelsPerInch'))
disp('Axes Position:')
disp(get(gca,'Position'))
disp('Colorbar Position:')
disp(get(c,'Position'))