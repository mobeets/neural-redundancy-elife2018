function dts = getDatesInDir(baseDir)
    if nargin < 1
        baseDir = fullfile('data', 'sessions');
    end
    ds = dir(fullfile(baseDir, '*.mat'));
    ds = {ds.name};
    dts = cellfun(@(d) strrep(d, '.mat', ''), ds, 'uni', 0);
end
