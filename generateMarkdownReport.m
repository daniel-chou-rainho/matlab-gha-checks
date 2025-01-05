function generateMarkdownReport(differencesPath)
    data = load(differencesPath);
    differences = data.allDifferences.differences;
    
    header = string('| Class | Parent | Field | Baseline | Test | Matches |');
    separator = string('|-------|--------|--------|-----------|------|---------|');
    rows = strings(length(differences), 1);
    
    for i = 1:length(differences)
        diff = differences(i);
        baseline = convertToString(diff.baseline);
        test = convertToString(diff.test);
        rows(i) = sprintf('| %s | %s | %s | %s | %s | %s |', ...
            diff.class, diff.parent, diff.field, ...
            baseline, test, string(diff.matches));
    end
    
    fullText = strjoin([header; separator; rows], newline);
    
    fid = fopen('output/differences.md', 'w');
    fprintf(fid, '%s', char(fullText));
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