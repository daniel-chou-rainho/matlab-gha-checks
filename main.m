function main()
% Create and capture figure info
fig = createFigure();
info = captureInfo(fig);

% Load or create baseline
baselinePath = 'baseline_figure.mat';
if ~isfile(baselinePath)
    save(baselinePath, 'info');
    return;
end

% Load baseline and compare
baseline = load(baselinePath);
differences = compareFigures(baseline.info, info, false);

% Save differences
saveDifferences(differences);
end

function fig = createFigure()
fig = figure('Units', 'pixels', ...
    'Position', [100 100 560 420], ...
    'Renderer', 'painters', ...
    'Visible', 'off');  % Add this line to prevent window from showing
axes('Units', 'normalized');
c = colorbar;
c.Label.Units = 'normalized';
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
differences = struct('class', {}, 'parent', {}, 'field', {}, 'baseline', {}, 'current', {}, 'matches', {});

% Check counts first
if length(info1) ~= length(info2)
    differences(1).class = 'root';
    differences(1).parent = '';
    differences(1).field = 'object_count';
    differences(1).baseline = length(info1);
    differences(1).current = length(info2);
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
        differences(1).current = info2(i).class;
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
        differences(nextIdx).current = val2;
        differences(nextIdx).matches = matches;
    end
end
end

function saveDifferences(differences)
    save('figure_properties.mat', 'differences');
end

function blacklist = getBlacklist()
blacklist = containers.Map();

% Object-specific properties
blacklist('matlab.ui.Figure:Number') = [];
blacklist('matlab.ui.Root:PointerLocation') = [];
blacklist('matlab.ui.container.ContextMenu:ContextMenuOpeningFcn') = [];
blacklist('matlab.graphics.axis.Axes:InteractionOptions') = [];

% Global properties to ignore for all objects
blacklist('*:Children') = [];
end