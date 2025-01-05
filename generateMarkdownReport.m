function generateMarkdownReport(differencesPath)
    data = load(differencesPath);
    differences = data.allDifferences.differences;
   
    html = ['<table style="width:100%;table-layout:fixed;word-wrap:break-word;">\n', ...
            '<tr><th>Class</th><th>Parent</th><th>Field</th><th>Baseline</th><th>Test</th><th>Matches</th></tr>\n'];
            
    for i = 1:length(differences)
        diff = differences(i);
        html = [html, sprintf('<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>\n', ...
            diff.class, diff.parent, diff.field, ...
            convertToString(diff.baseline), convertToString(diff.test), ...
            string(diff.matches))];
    end
    
    html = [html, '</table>'];
    
    fid = fopen('output/differences.html', 'w');
    fprintf(fid, '%s', html);
    fclose(fid);
end

function str = convertToString(val)
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
end