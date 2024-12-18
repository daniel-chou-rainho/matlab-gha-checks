figure('Units', 'pixels', 'Position', [100 100 560 420]);
axes('Units', 'normalized');
c = colorbar;

set(fig, 'PaperUnits', 'inches');
set(fig, 'PaperPosition', [0 0 560/96 420/96]);
set(fig, 'PaperSize', [560/96 420/96]);

print(fig, 'output', '-dpng', '-r96');
close(fig);

disp('MATLAB Version:')
disp(version)
disp('Screen DPI:')
disp(get(0,'ScreenPixelsPerInch'))
disp('Screen Size:')
disp(get(0,'ScreenSize'))
disp('Graphics Renderer:')
disp(get(gcf,'Renderer'))
disp('Axes Position:')
disp(get(gca,'Position'))
disp('Colorbar Position:')
disp(get(c,'Position'))