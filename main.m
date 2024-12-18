figure('Units', 'pixels', 'Position', [100 100 560 420]);
axes('Units', 'normalized');
c = colorbar;
disp('MATLAB Version:')
disp(version)
disp('Screen DPI:')
disp(get(0,'ScreenPixelsPerInch'))
disp('Screen Size:')
disp(get(0,'ScreenSize'))
disp('Default Font:')
disp(get(0,'DefaultFigureDefaultTextFontName'))
disp('Graphics Renderer:')
disp(get(gcf,'Renderer'))