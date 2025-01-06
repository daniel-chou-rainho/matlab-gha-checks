function generateHtmlReport(differencesPath)
   data = load(differencesPath);
   differences = data.allDifferences.differences;
   maxLength = 50;
   
   htmlParts = {};
   htmlParts{end+1} = '<html><body>';
   htmlParts{end+1} = ['<div style="display: flex; justify-content: center; margin-bottom: 20px;">' ...
            '<div style="margin: 10px;"><h3>Baseline</h3><img src="baseline_figure.jpg" width="600"></div>' ...
            '<div style="margin: 10px;"><h3>Test</h3><img src="test_figure.jpg" width="600"></div>' ...
            '</div>'];
   htmlParts{end+1} = ['<table>\n<tr><th>Class</th><th>Parent</th><th>Field</th>' ...
             '<th>Baseline</th><th>Test</th><th>Matches</th></tr>'];
             
   for i = 1:length(differences)
       diff = differences(i);
       htmlParts{end+1} = sprintf('<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>', ...
           diff.class, diff.parent, diff.field, ...
           convertToString(diff.baseline, maxLength), ...
           convertToString(diff.test, maxLength), ...
           string(diff.matches));
   end
   
   htmlParts{end+1} = '</table></body></html>';
   
   fid = fopen('output/differences.html', 'w');
   fprintf(fid, '%s\n', htmlParts{:});
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