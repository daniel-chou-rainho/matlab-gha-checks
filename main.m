function main()
    if ~exist('output', 'dir')
       mkdir('output');
    end
    
    baselinePath = fullfile('output', 'baseline_figure.mat');
    
    % If no baseline exists, create it and return
    if ~isfile(baselinePath)
       createAndSaveBaseline(baselinePath);
       return;
    end
    
    % Create and capture test figure
    fig = createFigure();
    info = captureInfo(fig);
    print(fig, fullfile('output', 'test_figure.jpg'), '-djpeg');
    
    % Compare figures and store differences
    baseline = load(baselinePath);
    differences = compareFigures(baseline.info, info, false);
    
    allDifferences = struct(...
        'differences', differences, ...
        'baseline_image', 'baseline_figure.jpg', ...
        'test_image', 'test_figure.jpg');
    
    save(fullfile('output', 'figure_differences.mat'), 'allDifferences');
    generateMarkdownReport(fullfile('output', 'figure_differences.mat'));
end

function createAndSaveBaseline(baselinePath)
   fig = createFigure();
   info = captureInfo(fig);
   save(baselinePath, 'info');
   print(fig, fullfile('output', 'baseline_figure.jpg'), '-djpeg');
end

function fig = createFigure()
    fig = figure('Visible','off');
    [X,Y] = meshgrid(-2:.2:2);
    Z = X.*exp(-X.^2-Y.^2);
    surf(X,Y,Z)
    colorbar
end

function info = captureInfo(fig)
    objs = findall(fig, '-not', 'Type', 'uimenu');
    
    info = struct();
    for i = 1:length(objs)
        info(i).class = class(objs(i));
        parent = get(objs(i), 'Parent');
        info(i).parent = getParentClass(parent);
        info(i).properties = captureProperties(objs(i));
    end
end

function parentClass = getParentClass(parent)
    if isempty(parent)
        parentClass = 'none';
    else
        parentClass = class(parent);
    end
end

function props = captureProperties(obj)
    props = struct();
    propNames = properties(obj);
    for i = 1:length(propNames)
        val = obj.(propNames{i});
        if ~isa(val, 'matlab.graphics.Graphics')
            props.(propNames{i}) = val;
        end
    end
end
