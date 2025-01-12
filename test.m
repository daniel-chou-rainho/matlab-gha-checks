current_dpi = get(0, 'ScreenPixelsPerInch');
disp(['Current DPI: ', num2str(current_dpi)]);

set(0, 'ScreenPixelsPerInch', 150);
new_dpi = get(0, 'ScreenPixelsPerInch');
disp(['New DPI: ', num2str(new_dpi)]);