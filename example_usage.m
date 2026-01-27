% Example script to demonstrate parsing and plotting GEIS data from .mpt files

% Parse the file
data = parse_mpt_file("W:\batPhys\scripts\battery-visualizer\battery data\IF8_EIS_new_charge_chariot\geis_20251216_174203_C01.mpt");

% Display some information
fprintf('\n=== File Information ===\n');
fprintf('Number of data points: %d\n', size(data.values, 1));
fprintf('Number of columns: %d\n', length(data.columns));
fprintf('\n=== Available Fields ===\n');
fields = fieldnames(data);
for i = 1:length(fields)
    if ~ismember(fields{i}, {'header', 'columns', 'values'})
        fprintf('  %s\n', fields{i});
    end
end

% Create Nyquist plot (imaginary vs real impedance)
figure('Position', [100, 100, 1200, 400]);

subplot(1, 3, 1);
plot(data.Re_Z_Ohm, data.Im_Z_Ohm, 'o-', 'LineWidth', 1.5);
xlabel('Re(Z) [\Omega]');
ylabel('-Im(Z) [\Omega]');
title('Nyquist Plot');
grid on;
axis equal;
xlim([0 max(data.Re_Z_Ohm)*1.1]);
%ylim([0 max(data.Im_Z_Ohm)*1.1]);

% Create Bode magnitude plot
subplot(1, 3, 2);
loglog(data.freq_Hz, data.Z_Ohm, 'o-', 'LineWidth', 1.5);
xlabel('Frequency [Hz]');
ylabel('|Z| [\Omega]');
title('Bode Magnitude Plot');
grid on;

% Create Bode phase plot
subplot(1, 3, 3);
semilogx(data.freq_Hz, data.Phase_Z_deg, 'o-', 'LineWidth', 1.5);
xlabel('Frequency [Hz]');
ylabel('Phase [deg]');
title('Bode Phase Plot');
grid on;

% Print some statistics
fprintf('\n=== Data Statistics ===\n');
fprintf('Frequency range: %.2e to %.2e Hz\n', min(data.freq_Hz), max(data.freq_Hz));
fprintf('Impedance range: %.4f to %.4f Ohm\n', min(data.Z_Ohm), max(data.Z_Ohm));
fprintf('Phase range: %.2f to %.2f deg\n', min(data.Phase_Z_deg), max(data.Phase_Z_deg));

% Example: Extract data at specific frequency
target_freq = 1000;  % Hz
[~, idx] = min(abs(data.freq_Hz - target_freq));
fprintf('\nData at ~%.1f Hz:\n', data.freq_Hz(idx));
fprintf('  Re(Z) = %.4f Ohm\n', data.Re_Z_Ohm(idx));
fprintf('  Im(Z) = %.4f Ohm\n', data.Im_Z_Ohm(idx));
fprintf('  |Z| = %.4f Ohm\n', data.Z_Ohm(idx));
fprintf('  Phase = %.2f deg\n', data.Phase_Z_deg(idx));
