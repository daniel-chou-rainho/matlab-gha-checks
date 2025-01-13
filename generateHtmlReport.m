function generateHtmlReport(differencesPath)
    data = load(differencesPath);
    differences = data.allDifferences.differences;
    maxLength = 50;
    
    % Get system info
    currentTime = datestr(now);
    screenSize = get(0, 'ScreenSize');
    screenDPI = get(0, 'ScreenPixelsPerInch');
    
    % Create header with system info
    header = ['<table>\n' ...
             sprintf('<tr><td colspan="6">Generated: %s</td></tr>\n', currentTime) ...
             sprintf('<tr><td colspan="6">Screen Size: %dx%d</td></tr>\n', screenSize(3), screenSize(4)) ...
             sprintf('<tr><td colspan="6">Screen DPI: %.0f</td></tr>\n', screenDPI) ...
             '<tr><th>Class</th><th>Parent</th><th>Field</th>' ...
             '<th>Baseline</th><th>Test</th><th>Matches</th></tr>'];
             
    rows = strings(length(differences), 1);
    for i = 1:length(differences)
        diff = differences(i);
        rows(i) = sprintf('<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>', ...
            diff.class, diff.parent, diff.field, ...
            convertToString(diff.baseline, maxLength), ...
            convertToString(diff.test, maxLength), ...
            string(diff.matches));
    end
    
    fullText = strjoin([header; rows; "</table>"], newline);
    fid = fopen('output/differences.html', 'w');
    fprintf(fid, '%s', char(fullText));
    fclose(fid);
end

function str = convertToString(val, maxLength)
    if isnumeric(val)
        str = num2str(val);
    elseif islogical(val)
        str = string(val);
    elseif ischar(val) || isstring(val)
        str = char(val);
    elseif iscell(val)
        str = strjoin(val, ', ');
    else
        str = '<complex value>';
    end

    if length(str) > maxLength
        str = [str(1:maxLength-3) '...'];
    end
end