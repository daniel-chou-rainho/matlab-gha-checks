function generateMarkdownReport(differencesPath)
    data = load(differencesPath);
    differences = data.allDifferences.differences;
    
    style = '<style>table{width:100%;table-layout:fixed;word-wrap:break-word;}</style>';
    header = '| Class | Parent | Field | Baseline | Test | Matches |';
    separator = '|-------|--------|--------|-----------|------|---------|';
    rows = strings(length(differences), 1);
    
    for i = 1:length(differences)
        diff = differences(i);
        rows(i) = sprintf('| %s | %s | %s | %s | %s | %s |', ...
            diff.class, diff.parent, diff.field, ...
            convertToString(diff.baseline), convertToString(diff.test), ...
            string(diff.matches));
    end
    
    fullText = strjoin([style; header; separator; rows], newline);
    
    fid = fopen('output/differences.md', 'w');
    fprintf(fid, '%s', fullText);
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