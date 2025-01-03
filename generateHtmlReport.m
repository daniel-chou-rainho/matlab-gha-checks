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
    
    fprintf(fid, '<!DOCTYPE html>\n');
    fprintf(fid, '<html>\n<head>\n');
    fprintf(fid, '<title>Figure Comparison Report</title>\n');
    fprintf(fid, '<style>\n');
    fprintf(fid, 'body { font-family: Arial, sans-serif; margin: 40px; }\n');
    fprintf(fid, 'h1 { color: #333; }\n');
    fprintf(fid, '.summary { background-color: #f5f5f5; padding: 20px; border-radius: 5px; }\n');
    fprintf(fid, '.figure-list { margin-top: 20px; }\n');
    fprintf(fid, '.failure-count { font-weight: bold; }\n');
    fprintf(fid, '.failure-count.error { color: #cc0000; }\n');
    fprintf(fid, '.failure-count.success { color: #00cc00; }\n');
    fprintf(fid, 'a { color: #0066cc; text-decoration: none; }\n');
    fprintf(fid, 'a:hover { text-decoration: underline; }\n');
    fprintf(fid, '</style>\n');
    fprintf(fid, '</head>\n<body>\n');

    fprintf(fid, '<h1>Figure Comparison Report</h1>\n');
    fprintf(fid, '<div class="summary">\n');
    fprintf(fid, '<h2>Summary</h2>\n');
    fprintf(fid, '<p>Total figures tested: %d</p>\n', length(figureNames));
    
    if totalFailures == 0
        statusClass = 'success';
    else
        statusClass = 'error';
    end
    fprintf(fid, '<p>Total differences found: <span class="failure-count %s">%d</span></p>\n', ...
        statusClass, totalFailures);
    fprintf(fid, '</div>\n');

    fprintf(fid, '<div class="figure-list">\n');
    fprintf(fid, '<h2>Figures</h2>\n');
    for i = 1:length(figureNames)
        if figureFailures(i) == 0
            statusClass = 'success';
        else
            statusClass = 'error';
        end
        fprintf(fid, '<p><a href="%s.html">%s</a> - <span class="failure-count %s">%d failures</span></p>\n', ...
            figureNames{i}, figureNames{i}, statusClass, figureFailures(i));
    end
    fprintf(fid, '</div>\n');

    fprintf(fid, '</body>\n</html>');
    fclose(fid);
end

function generateFigurePage(figureName, figureData, reportDir)
   % Create the figure specific HTML file
   fid = fopen(fullfile(reportDir, [figureName '.html']), 'w');
   
   % Write HTML header with styles
   fprintf(fid, '<!DOCTYPE html>\n');
   fprintf(fid, '<html>\n<head>\n');
   fprintf(fid, '<title>%s - Comparison</title>\n', figureName);
   fprintf(fid, '<style>\n');
   fprintf(fid, 'body { font-family: Arial, sans-serif; margin: 40px; }\n');
   fprintf(fid, '.image-container { display: flex; justify-content: space-between; margin: 20px 0; }\n');
   fprintf(fid, '.image-box { width: 48%%; }\n');
   fprintf(fid, '.image-box img { width: 100%%; }\n');
   fprintf(fid, 'table { width: 100%%; border-collapse: collapse; margin-top: 20px; }\n');
   fprintf(fid, 'th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }\n');
   fprintf(fid, 'th { background-color: #f5f5f5; }\n');
   fprintf(fid, '.fail { background-color: #ffe6e6; }\n');
   fprintf(fid, '.back-link { margin-bottom: 20px; }\n');
   fprintf(fid, '</style>\n');
   fprintf(fid, '</head>\n<body>\n');
   
   % Add back link
   fprintf(fid, '<div class="back-link"><a href="index.html">← Back to Index</a></div>\n');
   
   % Add title
   fprintf(fid, '<h1>%s Comparison</h1>\n', figureName);
   
   % Add images
   fprintf(fid, '<div class="image-container">\n');
   fprintf(fid, '  <div class="image-box">\n');
   fprintf(fid, '    <h2>Baseline Image</h2>\n');
   fprintf(fid, '    <img src="%s" alt="Baseline">\n', figureData.baseline_image);
   fprintf(fid, '  </div>\n');
   fprintf(fid, '  <div class="image-box">\n');
   fprintf(fid, '    <h2>Test Image</h2>\n');
   fprintf(fid, '    <img src="%s" alt="Test">\n', figureData.test_image);
   fprintf(fid, '  </div>\n');
   fprintf(fid, '</div>\n');
   
   % Add differences table
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
       
       % Convert values to strings safely
       baselineStr = convertToString(differences(i).baseline);
       testStr = convertToString(differences(i).test);
       
       fprintf(fid, '  <td>%s</td>\n', differences(i).class);
       fprintf(fid, '  <td>%s</td>\n', differences(i).parent);
       fprintf(fid, '  <td>%s</td>\n', differences(i).field);
       fprintf(fid, '  <td>%s</td>\n', baselineStr);
       fprintf(fid, '  <td>%s</td>\n', testStr);
       fprintf(fid, '</tr>\n');
   end
   
   fprintf(fid, '</table>\n');
   
   % Close HTML
   fprintf(fid, '</body>\n</html>');
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