clear variables
path_directory=...
   ["W:\batPhys\scripts\battery-visualizer\battery data\IF8_EIS_rotation_new_charge_chariot"  ;...
    "W:\batPhys\scripts\battery-visualizer\battery data\IF7_EIS_rotation_new_charge_chariot"  ;...
    "W:\batPhys\scripts\battery-visualizer\battery data\BT20_EIS_rotation_new_charge_chariot" ;...
    "W:\batPhys\scripts\battery-visualizer\battery data\IF8_EIS_rotation_old_charge_chariot"  ;...
    "W:\batPhys\scripts\battery-visualizer\battery data\IF8_EIS_rotation_older_charge_chariot";...
    "W:\batPhys\scripts\battery-visualizer\battery data\IF7_EIS_wire_unplugging_new_charge_chariot";...
    "W:\batPhys\scripts\battery-visualizer\battery data\IF7_EIS_no_touching_new_charge_chariot"
    ];

label_vect = ["IF8 New CC","IF7 New CC", "BT20 New CC", "IF8 Old CC",...
    "IF8 Older CC", "IF7 wire unplugging new CC", "IF7 no touching new CC"];
weight_vect = ["o:","o:","o:","o--","o-.","o-","o-"];

figure(1)

hold on

for i=1:length(path_directory)
[std_real(:,i),mean_real(:,i),mean_imag(:,i),dataset] = process_EIS_data_rotation(char(path_directory(i)));



figure
RGB = parula(length(dataset));
hold on
for k=1:length(dataset)
    plot(dataset{k}.Re_Z_Ohm, dataset{k}.Im_Z_Ohm, 'o-', 'LineWidth', 1,'Color',RGB(k,:));
end
box on
pbaspect([1 1 1])
xlim([0.03 0.06])
axis equal
xlabel('Re(Z) [\Omega]');
ylabel('-Im(Z) [\Omega]');
title('Nyquist Plot');
grid on;


%calculate pseudo-frechet distance matrix

for k=2:length(dataset)    
    dist_r(k-1) = mean(dataset{k}.Re_Z_Ohm-dataset{k-1}.Re_Z_Ohm);
    for j=1:k-1
        dist = ((dataset{k}.Re_Z_Ohm-dataset{j}.Re_Z_Ohm).^2 +...
            (dataset{k}.Im_Z_Ohm - dataset{j}.Im_Z_Ohm).^2).^0.5;
        [pseudo_frechet(k,j),index] = max(dist);
        freq_maxdiff(k,j) = dataset{k}.freq_Hz(index);

    end
end

pseudo_frechet(pseudo_frechet>0);
freq_maxdiff(pseudo_frechet>0);

figure
plot(cumsum(dist_r))

figure(1)
errorbar(mean_real(:,i),mean_imag(:,i),std_real(:,i),'horizontal',...
    weight_vect(i), 'LineWidth', 1);
end

legend(label_vect)
box on
pbaspect([1 1 1])
xlim([0.03 0.06])
axis equal
xlabel('Re(Z) [\Omega]');
ylabel('-Im(Z) [\Omega]');
grid on;


function [std_real,mean_real,mean_imag,data] = process_EIS_data_rotation(path_directory)

original_files=dir([path_directory '/*.mpt']);
data = {};
for k=1:length(original_files)
    filename=[path_directory '/' original_files(k).name];
    data{k} = parse_mpt_file(filename);
    % Next do your operation and finding
end

for k=1:length(original_files) 
    data_cube(:,:,k) = [data{k}.Re_Z_Ohm data{k}.Im_Z_Ohm];
end

for j=1:size(data_cube(:,:,k),1) 
    std_real(j) = std(permute(data_cube(j,1,:),[3 2 1]));
    mean_real(j) = mean(permute(data_cube(j,1,:),[3 2 1]));
    mean_imag(j) = mean(permute(data_cube(j,2,:),[3 2 1]));
end

end