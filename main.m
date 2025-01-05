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
    print(fig, fullfile('output', 'test_figure.jpg'), '-djpeg');
    info = captureInfo(fig);
    
    % Compare figures and store differences
    baseline = load(baselinePath);
    differences = compareFigures(baseline.info, info, false);
    
    allDifferences = struct(...
        'differences', differences, ...
        'baseline_image', 'baseline_figure.jpg', ...
        'test_image', 'test_figure.jpg');
    
    save(fullfile('output', 'figure_differences.mat'), 'allDifferences');
end

function createAndSaveBaseline(baselinePath)
   fig = createFigure();
   info = captureInfo(fig);
   save(baselinePath, 'info');
   print(fig, fullfile('output', 'baseline_figure.jpg'), '-djpeg');
end

function fig = createFigure()
    fig = figure('Visible', 'off');
    plot(1:10);
end

function info = captureInfo(fig)
    % Get all objects from hierarchy
    objs = findall(fig, '-not', 'Type', 'uimenu');
    
    % Add inner objects
    objs = addInnerObjects(objs);
    
    % Remove duplicates
    % Use stable flag to ensure deterministic ordering when removing duplicates
    objs = unique(objs, 'stable');
    
    % Capture properties
    info = struct();
    for i = 1:length(objs)
        info(i).class = class(objs(i));
        parent = get(objs(i), 'Parent');
        info(i).parent = getParentClass(parent);
        info(i).properties = captureProperties(objs(i));
    end
end

function objs = addInnerObjects(objs)
    newObjs = objs;
    for obj = objs'
        props = properties(obj);
        for i = 1:length(props)
            prop = obj.(props{i});
            if isa(prop, 'matlab.graphics.Graphics')
                newObjs = [newObjs; prop];
            end
        end
    end
    objs = newObjs;
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

function differences = compareFigures(info1, info2, debug)
    differences = struct('class', {}, 'parent', {}, 'field', {}, 'baseline', {}, 'test', {}, 'matches', {});
    
    % Check counts first
    if length(info1) ~= length(info2)
        differences(1).class = 'root';
        differences(1).parent = '';
        differences(1).field = 'object_count';
        differences(1).baseline = length(info1);
        differences(1).test = length(info2);
        differences(1).matches = false;
        return;
    end

    % Then check classes
    for i = 1:length(info1)
        if ~strcmp(info1(i).class, info2(i).class)
            differences(1).class = info1(i).class;
            differences(1).parent = '';
            differences(1).field = 'class_mismatch';
            differences(1).baseline = info1(i).class;
            differences(1).test = info2(i).class;
            differences(1).matches = false;
            return;
        end
    end
    
    % Finally do property comparisons
    for i = 1:length(info1)
        differences = compareProperties(differences, info1(i), info2(i), info1(i).parent, debug);
    end
end

function differences = compareProperties(differences, obj1, obj2, parent, debug)
    blacklist = getBlacklist();
    props1 = obj1.properties;
    props2 = obj2.properties;
    fields = intersect(fieldnames(props1), fieldnames(props2));
    
    for i = 1:length(fields)
        field = fields{i};
        
        key = [obj1.class ':' field];
        if blacklist.isKey(key) || blacklist.isKey(['*:' field])
            continue;
        end
        
        val1 = props1.(field);
        val2 = props2.(field);
        
        if isa(val1, 'matlab.lang.OnOffSwitchState') && isa(val2, 'matlab.lang.OnOffSwitchState')
            val1 = strcmp(string(val1), 'on');
            val2 = strcmp(string(val2), 'on');
            matches = val1 == val2;
        elseif isnumeric(val1) && isnumeric(val2)
            nan_matches = isnan(val1(:)) == isnan(val2(:));
            num_matches = abs(val1(:) - val2(:)) < 1e-10;
            matches = all(nan_matches & (num_matches | isnan(val1(:))));
        else
            matches = isequal(val1, val2);
        end
        
        if debug || ~matches
            nextIdx = length(differences) + 1;
            differences(nextIdx).class = obj1.class;
            differences(nextIdx).parent = parent;
            differences(nextIdx).field = field;
            differences(nextIdx).baseline = val1;
            differences(nextIdx).test = val2;
            differences(nextIdx).matches = matches;
        end
    end
end

function blacklist = getBlacklist()
    blacklist = containers.Map();
    
    % Object-specific properties
    blacklist('matlab.ui.Figure:Number') = [];
    blacklist('matlab.ui.Figure:OuterPosition') = [];
    blacklist('matlab.ui.Root:PointerLocation') = [];
    blacklist('matlab.ui.container.ContextMenu:ContextMenuOpeningFcn') = [];
    blacklist('matlab.graphics.axis.Axes:InteractionOptions') = [];
    blacklist('matlab.graphics.chart.primitive.Line:DataTipTemplate') = [];
    blacklist('matlab.graphics.chart.primitive.Surface:DataTipTemplate') = [];
    
    % Global properties to ignore for all objects
    blacklist('*:Children') = [];
end