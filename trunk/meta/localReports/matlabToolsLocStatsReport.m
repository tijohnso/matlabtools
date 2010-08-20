function matlabToolsLocStatsReport()
%% Generate an html page showing PMTK3 statistics such as LOC by directory.
%
% PMTKneedsMatlab
%% Settings
excludeComments             = false;
directories                 = {'graph', 'graphics', 'util', 'stats', 'oop', 'metaTools'};
excludedAuthors             = {'Matt Dunham', 'Kevin Murphy'}; 
outputFile                  = fullfile(matlabToolsRoot, 'docs', 'matlabToolsStats.html');
recursive                   = true;
%%
colNames = {'directory', 'LOC matlab', 'LOC matlab (contrib)',...
    'LOC non-matlab', 'LOC non-matlab (contrib)', 'total LOC'};
mmask    = '*.m';
omask    = {'*.c', '*.cpp', '*.h', '*.py'};
pmtkRed  = '#990000';
%%
data      = zeros(numel(directories)+1, numel(colNames)-1); % +1 for totals
countd    = @(d, mask)countLinesOfCodeDir(d, excludeComments, recursive, mask);
fullDirs  = cellfuncell(@(d)fullfile(matlabToolsRoot(), d),  directories); 
for i=1:numel(fullDirs)
    d             = fullDirs{i}; 
    totalMatlab   = countd(d, mmask);
    totalOther    = countd(d, omask);
    
    % assume for now that all non-matlab files are written by other people
    contribOther  = totalOther; 
    m = filelist(d, '*.m', recursive);
    authors = getTagText(m, 'PMTKauthor');
    contribFiles = m(cellfun(@(c)~isempty(setdiff(c, excludedAuthors)), authors));
    contribMatlab = sum(cellfun(@(f)countLinesOfCode(f, excludeComments), contribFiles));
    data(i, 1) = totalMatlab - contribMatlab;
    data(i, 2) = contribMatlab;
    data(i, 3) = totalOther - contribOther;
    data(i, 4) = contribOther;
    data(i, 5) = totalMatlab + totalOther;
end

if excludeComments
    excludeCommentStr = 'excludes';
else
    excludeCommentStr = 'includes';
end
data(end, :) = sum(data(1:end-1, :), 1);

header = formatHtmlText({...
'<font align="left" style="color:%s"><h2>MatlabTools Statistics</h2></font>'
''
'Revision Date: %s'
''
'Auto-generated by %s'
''
'LOC (lines of code) %s comments.'
''
'Contrib means files contributed by other people (besides Dunham and Murphy).'
'Authorship is automatically inferred based on the presence of a PMTKauthor tag.'
'Most non-matlab files are in C.'
''
''
''
}, pmtkRed, date, mfilename, excludeCommentStr); 

colNameColors = repmat({pmtkRed}, 1, numel(colNames));
htmlTable('data'            , data, ...
    'colNames'         , upper(colNames), ...
    'rowNames'         , [fnameOnly(directories)'; 'total'], ...
    'colNameColors'    , colNameColors, ...
    'header'           , header, ...
    'doshow'           , false, ...
    'dosave'           , true, ...
    'filename'         , outputFile);
end