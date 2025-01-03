function generateHtmlReport()
   % Load the comparison results
   load(fullfile('output', 'all_figure_differences.mat'), 'allDifferences');

   % Create output directory if it doesn't exist
   reportDir = fullfile('output', 'report');
   if ~exist(reportDir, 'dir')
       mkdir(reportDir);
   end

   % Get field names (figure names) and calculate total failures
   figureNames = fieldnames(allDifferences);
   totalFailures = 0;
   figureFailures = zeros(length(figureNames), 1);

   for i = 1:length(figureNames)
       differences = allDifferences.(figureNames{i}).differences;
       failures = sum([differences.matches] == false);
       figureFailures(i) = failures;
       totalFailures = totalFailures + failures;
   end

   % Generate index page
   generateIndexPage(figureNames, totalFailures, figureFailures, reportDir);

   % Generate individual figure pages
   for i = 1:length(figureNames)
       figureName = figureNames{i};
       figureData = allDifferences.(figureName);
       generateFigurePage(figureName, figureData, reportDir);
   end

   % Copy all PNG files to report directory
   copyfile(fullfile('output', '*.png'), reportDir);
end

function generateIndexPage(figureNames, totalFailures, figureFailures, reportDir)
    fid = fopen(fullfile(reportDir, 'index.html'), 'w');
    
    fprintf(fid, '<!DOCTYPE html>\n<html>\n<head>\n');
    fprintf(fid, '<meta charset="UTF-8">\n');
    fprintf(fid, '<meta name="viewport" content="width=device-width, initial-scale=1.0">\n');
    fprintf(fid, '<title>Figure Comparison Report</title>\n');
    fprintf(fid, '<style>\n');
    fprintf(fid, ['* { box-sizing: border-box; }\n' ...
                  'body { font-family: system-ui, -apple-system, sans-serif; line-height: 1.6; ' ...
                  'max-width: 1200px; margin: 0 auto; padding: 2rem; background: #f8f9fa; }\n' ...
                  '.container { background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }\n' ...
                  'h1, h2 { margin-top: 0; color: #2c3e50; }\n' ...
                  '.summary { background: #f1f3f5; padding: 1.5rem; border-radius: 6px; margin: 2rem 0; }\n' ...
                  '.figure-item { padding: 1rem; border-bottom: 1px solid #e9ecef; }\n' ...
                  '.figure-item:last-child { border: none; }\n' ...
                  '.status { font-weight: 500; border-radius: 4px; padding: 0.25rem 0.5rem; }\n' ...
                  '.success { background: #d3f9d8; color: #2b8a3e; }\n' ...
                  '.error { background: #ffe3e3; color: #c92a2a; }\n' ...
                  'a { color: #364fc7; text-decoration: none; }\n' ...
                  'a:hover { color: #5c7cfa; }\n']);
    fprintf(fid, '</style>\n</head>\n<body>\n');
    
    fprintf(fid, '<div class="container">\n');
    fprintf(fid, '<h1>Figure Comparison Report</h1>\n');
    
    fprintf(fid, '<div class="summary">\n');
    fprintf(fid, '<h2>Summary</h2>\n');
    fprintf(fid, '<p>Total figures tested: %d</p>\n', length(figureNames));
    
    if totalFailures == 0
        statusClass = 'success';
    else
        statusClass = 'error';
    end
    fprintf(fid, '<p>Total differences found: <span class="status %s">%d</span></p>\n', ...
            statusClass, totalFailures);
    fprintf(fid, '</div>\n');
    
    fprintf(fid, '<h2>Figures</h2>\n');
    for i = 1:length(figureNames)
        if figureFailures(i) == 0
            statusClass = 'success';
        else
            statusClass = 'error';
        end
        fprintf(fid, ['<div class="figure-item">\n' ...
                     '<a href="%s.html">%s</a> ' ...
                     '<span class="status %s">%d differences</span>\n' ...
                     '</div>\n'], ...
                     figureNames{i}, figureNames{i}, statusClass, figureFailures(i));
    end
    
    fprintf(fid, '</div>\n</body>\n</html>');
    fclose(fid);
end

function generateFigurePage(figureName, figureData, reportDir)
   fid = fopen(fullfile(reportDir, [figureName '.html']), 'w');
   
   fprintf(fid, '<!DOCTYPE html>\n<html>\n<head>\n');
   fprintf(fid, '<meta charset="UTF-8">\n');
   fprintf(fid, '<meta name="viewport" content="width=device-width, initial-scale=1.0">\n');
   fprintf(fid, '<title>%s - Comparison</title>\n', figureName);
   fprintf(fid, '<style>\n');
   fprintf(fid, ['* { box-sizing: border-box; }\n' ...
                 'body { font-family: system-ui, -apple-system, sans-serif; line-height: 1.6; ' ...
                 'max-width: 1200px; margin: 0 auto; padding: 2rem; background: #f8f9fa; }\n' ...
                 '.container { background: white; padding: 2rem; border-radius: 8px; ' ...
                 'box-shadow: 0 2px 4px rgba(0,0,0,0.1); }\n' ...
                 'h1, h2 { color: #2c3e50; margin-top: 0; }\n' ...
                 '.back-link { margin-bottom: 1.5rem; }\n' ...
                 '.back-link a { color: #364fc7; text-decoration: none; }\n' ...
                 '.back-link a:hover { color: #5c7cfa; }\n' ...
                 '.image-container { display: flex; gap: 2rem; margin: 2rem 0; }\n' ...
                 '.image-box { flex: 1; }\n' ...
                 '.image-box img { width: 100%%; border-radius: 4px; border: 1px solid #e9ecef; }\n' ...
                 'table { width: 100%%; border-collapse: collapse; margin: 2rem 0; }\n' ...
                 'th { background: #f1f3f5; padding: 0.75rem; text-align: left; }\n' ...
                 'td { padding: 0.75rem; border-bottom: 1px solid #e9ecef; }\n' ...
                 'tr.fail { background: #ffe3e3; }\n']);
   fprintf(fid, '</style>\n</head>\n<body>\n');
   
   fprintf(fid, '<div class="container">\n');
   fprintf(fid, '<div class="back-link"><a href="index.html">← Back to Index</a></div>\n');
   fprintf(fid, '<h1>%s Comparison</h1>\n', figureName);
   
   fprintf(fid, '<div class="image-container">\n');
   fprintf(fid, '<div class="image-box">\n');
   fprintf(fid, '<h2>Baseline Image</h2>\n');
   fprintf(fid, '<img src="%s" alt="Baseline">\n', figureData.baseline_image);
   fprintf(fid, '</div>\n');
   fprintf(fid, '<div class="image-box">\n');
   fprintf(fid, '<h2>Test Image</h2>\n');
   fprintf(fid, '<img src="%s" alt="Test">\n', figureData.test_image);
   fprintf(fid, '</div>\n</div>\n');
   
   fprintf(fid, '<h2>Differences</h2>\n');
   fprintf(fid, '<table>\n');
   fprintf(fid, '<tr><th>Class</th><th>Parent</th><th>Field</th><th>Baseline</th><th>Test</th></tr>\n');
   
   differences = figureData.differences;
   for i = 1:length(differences)
       if ~differences(i).matches
           fprintf(fid, '<tr class="fail">\n');
       else
           fprintf(fid, '<tr>\n');
       end
       
       baselineStr = convertToString(differences(i).baseline);
       testStr = convertToString(differences(i).test);
       
       fprintf(fid, '<td>%s</td>\n<td>%s</td>\n<td>%s</td>\n<td>%s</td>\n<td>%s</td>\n', ...
           differences(i).class, differences(i).parent, differences(i).field, ...
           baselineStr, testStr);
       fprintf(fid, '</tr>\n');
   end
   
   fprintf(fid, '</table>\n</div>\n</body>\n</html>');
   fclose(fid);
end

function str = convertToString(val)
   % Helper function to convert various data types to string representation
   if isnumeric(val)
       if isscalar(val)
           str = num2str(val);
       else
           str = ['[' num2str(size(val)) ' array]'];
       end
   elseif islogical(val)
       if val
           str = 'true';
       else
           str = 'false';
       end
   elseif ischar(val) || isstring(val)
       str = char(val);
   else
       str = class(val);
   end
end