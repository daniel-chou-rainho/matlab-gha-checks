% Define the OnOffSwitchState enumeration
OnOffSwitchState = struct('ON', 1, 'OFF', 0);

% Initialize empty struct
data = struct('name', {}, 'switchState', {}, 'city', {}, 'score', {}, 'active', {});

% Add 5 records
for i = 1:5
   data(i).name = ['Device' num2str(i)];
   data(i).switchState = OnOffSwitchState.ON;
   data(i).city = ['City' num2str(i)];
   data(i).score = rand() * 100;
   data(i).active = true;
end

disp(data)