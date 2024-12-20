% main.m
fig = figure('Units', 'pixels', 'Position', [100 100 560 420], 'Renderer', 'painters');
axes('Units', 'normalized');
c = colorbar;
c.Label.Units = 'normalized';

% Clear file by opening in write mode
fid = fopen('figure_properties.txt', 'w');
fclose(fid);

diary('figure_properties.txt');

disp('=== SCREEN PROPERTIES ===');
disp('Screen DPI:');
disp(get(0,'ScreenPixelsPerInch'));
disp('Screen Size:');
disp(get(0,'ScreenSize'));
disp('Monitor Positions:');
disp(get(0,'MonitorPositions'));

disp('=== FIGURE PROPERTIES ===');
disp(get(gcf));

disp('=== AXES PROPERTIES ===');
disp(get(gca));

disp('=== COLORBAR PROPERTIES ===');
disp(get(c));

disp('=== COLORBAR LABEL PROPERTIES ===');
disp(get(c.Label));

diary off;