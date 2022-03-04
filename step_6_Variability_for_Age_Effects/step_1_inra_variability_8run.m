clear;clc;
addpath(genpath('/GPFS/cuizaixu_lab_permanent/wuguowei/python_code/repeat_code/Single_parcellation_FC_Variability/Functions'))
root_dir = '/GPFS/cuizaixu_lab_permanent/wuguowei/python_code/project/SingleParcellation_Kong_HCPD_rp2/';
data_dir = '/GPFS/cuizaixu_lab_permanent/wuguowei/python_code/repeat_code/motion_data';
age_group = [8,10;14,16;19,21];
for age = 1:3
    age1 = age_group(age,1);
    age2 = age_group(age,2);
    file_name = [data_dir filesep 'task_and_rest_motion_valid_age_' num2str(age1) '_' num2str(age2) '.xlsx'];
    [~,~,sub_motion_valide_all]= xlsread(file_name);
    sub_motion_valide_all = sub_motion_valide_all(2:end,1);
    OUT_DIR = ['/GPFS/cuizaixu_lab_permanent/wuguowei/python_code/project/HCPD_single_parcel/' 'hcp_age_' num2str(age1) '_' num2str(age2)];
    if ~exist(OUT_DIR,'dir')
        mkdir(OUT_DIR)
    end
    data_all = size(sub_motion_valide_all,1);
    %% within subject variability based on 8 run dataset
    %Mypool = parpool('local',8);sub_std = zeros(data_all,400*399/2);
    for s=1:data_all  % for each subject
        sub = ['sub-' sub_motion_valide_all{s}];
        subname = [root_dir '/ind_parcel_400_8run/' sub filesep 'data_pacel.mat'];    
        subdata = load(subname);subdata = subdata.data_pacel;
        parfor run = 1:8
            ind_parcel_400 = squeeze(subdata(2:401,:,run));
            z_corr_data = atanh(corr(ind_parcel_400'));
            all_session(run,:) = convet_matrix_to_vector(z_corr_data);
        end
        sub_std(s,:) = std(all_session,1);
        subname
    end

    all_sub_std = mean(sub_std);
    intra_matrix = squareform(all_sub_std);
    plot_variability_matrix(intra_matrix,0.24,0.28);
    h = gcf;
    set(h,'PaperUnits','inches','PaperPosition',[0 0 50 50]);
    saveas(h, [OUT_DIR,'/intra_variability.jpg'],'jpg');
    close;
    if ~exist([OUT_DIR,'/intra_variability/'],'dir')
        mkdir([OUT_DIR,'/intra_variability/'])
    end
    save([OUT_DIR,'/intra_variability/intra_sub_std.mat'],'intra_matrix');
    cortex_visualize(intra_matrix,[OUT_DIR,'/intra_variability.dscalar.nii']);
end