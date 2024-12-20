% main.m
fig = figure('Units', 'pixels', 'Position', [100 100 560 420], 'Renderer', 'painters');
axes('Units', 'normalized');
c = colorbar;

% Create file and redirect diary output
diary('figure_properties.txt');

% Log all properties
disp('=== FIGURE PROPERTIES ===');
disp(get(gcf));

disp('=== AXES PROPERTIES ===');
disp(get(gca));

disp('=== COLORBAR PROPERTIES ===');
disp(get(c));

diary off;