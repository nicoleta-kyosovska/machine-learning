addpath '\\smbhome.uscs.susx.ac.uk\nk331\Documents\MATLAB\MACHINE LEARNING competition';

%import data
trdata = csvread('training.csv', 1,1);
trdata2 = csvread('additional_training.csv', 1,1);
testdata = csvread('testing.csv',1,1);
%concatenate all training data
traindata_nan = [trdata(:,1:4608); trdata2(:,1:4608)];
%take GIST
traindata = traindata_nan(:,4097:4608);
%substitute NaN values with mean for GIST
for feat=1:size(traindata,2)
    mean_feat = mean(traindata(find(~isnan(traindata(:,feat))), feat));
    traindata(find(isnan(traindata(:,feat))), feat) = mean(traindata(find(~isnan(traindata(:,feat))), feat));
end
%take CNN
traindataCNN = traindata_nan(:,1:4096);
%substitute NaN values with 0 for GIST
for feat=1:size(traindataCNN,2)
    traindataCNN(find(isnan(traindataCNN(:,feat))), feat) = 0;
end
traindata = [traindataCNN traindata];
%compute outputs for train
outputdata = [trdata(:,4609); trdata2(:,4609)];
%NORMALISE DATA
traindata_normed = normc(traindata);
%outputdata_normed = normc(outputdata);  
testdata_normed = normc(testdata);

%%%%%%%%%%%%%%pre-processing%%%%%%%%%%%%%%%%%%%%

%%%%feature selection with SU%%%%%

[reduced_traindata_normed, reduced_testdata_normed] = feature_selection_SU(traindata_normed, outputdata, testdata_normed);

%%%%update weights
weights = update_weights_using_annotation_confidence(reduced_traindata_normed, traindata_nan);

 %%%%do over-sampling%%%%% - not for the best submission
%[oversampled_traindata_exp_red, oversampled_outputdata_exp_red] = do_oversampling(expanded_traindata_red, expanded_outputdata_red);


%K-fold for PCA - not used at the end
% pca_params = [100 500 1000 1500 2000 3000 3500 4000];
% 
% errors = zeros(8,1);
% for par=1:length(pca_params)
%     disp(strcat('Running SVM No.', num2str(par)));
%     pca_param = pca_params(par)
%     [traindata_pca, testdata_pca] = do_pca(traindata_normed, testdata_normed, size(traindata_normed,2));
%     [model, labels, score, kfold_loss, confusion_matrices] = runSVM(new_traindata_normed, new_outputdata, testdata_normed);
%     errors(par) = cross_error;
% end



%%%%%%%%train svm and make predictions%%%%%%%%%%%

%fit svm
[model, labels, kfold_loss, confusion_matrices] = runSVM_post(reduced_traindata_normed, outputdata, reduced_testdata_normed, weights);


%bar graph in report
trains = [0.1303 0.2158; 0.1259 0.2150; 0.1259 0.2140; 0.1261 0.2140;];
bar(trains);
legend('Train error', 'Test error');
xlabel('Train and test set');
ylabel('Loss');
saveas(gcf, 'bar_pca_reduction_overfitting.jpeg');


