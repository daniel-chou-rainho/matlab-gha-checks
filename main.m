figure('Units', 'pixels', 'Position', [100 100 560 420]);
axes('Units', 'normalized');
c = colorbar('Location', 'eastoutside');
set(c, 'FontName', 'Arial');
disp('Axes Position:')
disp(get(gca,'Position'))
disp('Colorbar Position:')
disp(get(c,'Position'))