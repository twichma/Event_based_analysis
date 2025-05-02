% Define the Excel file name
file_name = 'Ulrik Results.xlsx';
output_file = 'FDR_corrected_results.xlsx'; % Define output file

% Define the sheets and corresponding p-value columns
%sheets = {'QuartzSMAL', 'UlrikSMA', 'UlrikM1'};
sheets = {'M1 target ON', 'M1 center leave','SMA target ON', 'SMA center leave'};
columns = {
%    {'p1', 'p2', 'p3'}, % Quartz SMAL
    {'p1', 'p2'},      
    {'p1', 'p2'},
    {'p1', 'p2'},
    {'p1', 'p2'}
};

for i = 1:length(sheets)
    sheet = sheets{i};
    col_names = columns{i};
    
    % Read the sheet data
    [~, txt, raw] = xlsread(file_name, sheet);
    
    % Display headers to verify
    disp(['Headers in ', sheet, ':']);
    disp(txt(1, :));

    % Convert column letters to indices
    col_indices = cellfun(@(x) find(strcmp(txt(1, :), x), 1), col_names, 'UniformOutput', false);
    col_indices = cell2mat(col_indices); % Convert cell array to numeric array
    
    % Check if column indices were found
    if isempty(col_indices)
        warning('Columns not found in sheet: %s', sheet);
        continue;
    end
    
    % Initialize corrected p-values storage
    corrected_p_values = nan(size(raw, 1) - 1, length(col_indices));

    for j = 1:length(col_indices)
        % Extract p-values from the column
        p_values = cell2mat(raw(2:end, col_indices(j))); % Convert data to numeric
        p_values = p_values(:); % Ensure it's a column vector
        p_values = p_values(~isnan(p_values)); % Remove NaNs

        % Ensure valid p-values exist
        if isempty(p_values)
            warning('No valid p-values found in column %s of sheet: %s', col_names{j}, sheet);
            continue;
        end

        % Apply FDR correction
        [h, p_corrected] = fdr_bh(p_values, 0.05);

        % Store corrected p-values
        corrected_p_values(1:length(p_corrected), j) = p_corrected;
    end
    
    % Prepare output data (including headers)
    output_data = [col_names; num2cell(corrected_p_values)];

    % Write results to a new Excel file (using writecell instead of writematrix)
    writecell(output_data, output_file, 'Sheet', sheet);
end

disp('FDR correction completed. Results saved in FDR_corrected_results.xlsx');

% Function to perform Benjamini-Hochberg FDR correction
function [h, p_fdr] = fdr_bh(pvals, q)
    % Remove NaN values
    pvals = pvals(:);  % Ensure column vector
    pvals = pvals(~isnan(pvals)); % Remove NaNs
    
    if isempty(pvals)
        h = [];
        p_fdr = [];
        return;
    end
    
    % Sort p-values and get their original indices
    [sorted_pvals, sort_idx] = sort(pvals);
    m = length(sorted_pvals);
    
    % Compute FDR threshold
    threshold = (1:m)' / m * q;
    
    % Find largest index where p-value is below threshold
    below_threshold = sorted_pvals <= threshold;
    max_idx = find(below_threshold, 1, 'last');
    
    % Reject null hypotheses up to max_idx
    h = false(size(pvals));
    if ~isempty(max_idx)
        h(sort_idx(1:max_idx)) = true;
    end
    
    % Adjusted p-values
    p_fdr = nan(size(pvals));
    p_fdr(sort_idx) = min(1, cummin(sorted_pvals .* m ./ (1:m)', 'reverse')); % Corrected p-values
end
