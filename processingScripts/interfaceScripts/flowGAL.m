function resultVecGAL = flowGAL(nFoldDataEval,nFoldDataTune,hasSupervision,hasSemiSupervision)
% flowGAL creates temporary files required by the GetAnotherLabel implementation
% and makes a system call to the algorithm
% Inputs:
%   nFoldDataEval -
%   nFoldDataTune -
%   hasSupervision -
%   hasSemiSupervision -
% Outputs:
%   resultVec -
% ******************************************************************************

    tic;
    resultVecDS = []; 
    resultVecGAL = [];
    aggregatedLabelsDS = [];
    aggregatedLabelsGAL = [];
    bin = 'java -ea -cp /Users/aashish/dev/java/crwdQA/3rdParty/Get-Another-Label/target/dependency/args4j-2.0.16.jar:/Users/aashish/dev/java/crwdQA/3rdParty/Get-Another-Label/target/dependency/commons-beanutils-1.8.3.jar:/Users/aashish/dev/java/crwdQA/3rdParty/Get-Another-Label/target/dependency/commons-collections-3.2.1.jar:/Users/aashish/dev/java/crwdQA/3rdParty/Get-Another-Label/target/dependency/commons-lang3-3.1.jar:/Users/aashish/dev/java/crwdQA/3rdParty/Get-Another-Label/target/dependency/commons-logging-1.1.1.jar:/Users/aashish/dev/java/crwdQA/3rdParty/Get-Another-Label/target/dependency/commons-math3-3.0.jar:/Users/aashish/dev/java/crwdQA/3rdParty/Get-Another-Label/target/dependency/hamcrest-core-1.1.jar:/Users/aashish/dev/java/crwdQA/3rdParty/Get-Another-Label/target/dependency/junit-4.10.jar:/Users/aashish/dev/java/crwdQA/3rdParty/Get-Another-Label/target/dependency/opencsv-2.3.jar:/Users/aashish/dev/java/crwdQA/3rdParty/Get-Another-Label/target/dependency/slf4j-api-1.6.6.jar:/Users/aashish/dev/java/crwdQA/3rdParty/Get-Another-Label/target/dependency/junit-4.10.jar:/Users/aashish/dev/java/crwdQA/3rdParty/Get-Another-Label/target/get-another-label-2.2.0-SNAPSHOT.jar com.ipeirotis.gal.Main';
    filePathPrefix = '/Users/aashish/dev/java/crwdQA/crowdData/processingScripts/WVSCMScripts';
    resultFile = [filePathPrefix '/results/object-probabilities.txt'];
    for i = 1:length(nFoldDataEval)
        categories = unique([unique(nFoldDataEval(i).goldResponses);unique(nFoldDataTune(i).goldResponses)]);
        if(hasSupervision)
            writeTempFiles([nFoldDataEval(i).workerIds;nFoldDataTune(i).workerIds],[nFoldDataEval(i).workerQuestions;nFoldDataTune(i).workerQuestions],[nFoldDataEval(i).workerResponses;nFoldDataTune(i).workerResponses],nFoldDataTune(i).goldQuestions,nFoldDataTune(i).goldResponses,categories);
            system([bin ' --gold ' filePathPrefix '/gold.txt ' '--cost ' filePathPrefix '/cost.txt ' '--input ' filePathPrefix '/responses.txt ' '--categories ' filePathPrefix '/categoriesWP.txt']);
        elseif(hasSemiSupervision)
            writeTempFiles(nFoldDataEval(i).workerIds,nFoldDataEval(i).workerQuestions,nFoldDataEval(i).workerResponses,nFoldDataTune(i).goldQuestions,nFoldDataTune(i).goldResponses,categories);
            system([bin ' --cost ' filePathPrefix '/cost.txt ' '--input ' filePathPrefix '/responses.txt ' '--categories ' filePathPrefix '/categoriesWP.txt']);
        else
            writeTempFiles(nFoldDataEval(i).workerIds,nFoldDataEval(i).workerQuestions,nFoldDataEval(i).workerResponses,nFoldDataTune(i).goldQuestions,nFoldDataTune(i).goldResponses,categories);
            system([bin ' --cost ' filePathPrefix '/cost.txt ' '--input ' filePathPrefix '/responses.txt ' '--categories ' filePathPrefix '/categories.txt']);
        end
        fid = fopen(resultFile);
        inputDataStruct = textscan(fid,'%s%s%s%s%s%s%*[^\n]');
        fclose(fid);
        
        estQuestions = inputDataStruct{1};
        estResponsesDS = inputDataStruct{3};
        estResponsesGAL = inputDataStruct{5};
        
        estQuestions(1) = [];
        estResponsesDS(1) = [];
        estResponsesGAL(1) = [];
        
        estQuestions = cellfun(@str2num,estQuestions);
        estResponsesDS = cellfun(@str2num,estResponsesDS);
        estResponsesGAL = cellfun(@str2num,estResponsesGAL);
        
        [acc pr re fm categ] = getMetrics(estResponsesDS,estQuestions,nFoldDataEval(i).goldQuestions,nFoldDataEval(i).goldResponses,categories);
        resultVecDS = [resultVecDS;acc' pr' re' fm'];
        [acc pr re fm categ] = getMetrics(estResponsesGAL,estQuestions,nFoldDataEval(i).goldQuestions,nFoldDataEval(i).goldResponses,categories);
        resultVecGAL = [resultVecGAL;acc' pr' re' fm'];
        
        logicalEst = ismember(estQuestions,nFoldDataEval(i).goldQuestions);
        
        aggregatedLabelsDS = [aggregatedLabelsDS;[estQuestions(logicalEst) (estResponsesDS(logicalEst) + 1)]]; 
        aggregatedLabelsGAL = [aggregatedLabelsGAL;[estQuestions(logicalEst) (estResponsesGAL(logicalEst) + 1)]]; 
    end
    toc;
%     write to file
    [path name ext] = fileparts(nFoldDataEval(1).path);
    if(hasSupervision)
        nameGAL = 'GAL_supervised_results.txt';
        nameDS = 'DS_supervised_results.txt';
        aggLNameGAL = 'GAL_supervised_aggregated.txt';
        aggLNameDS = 'DS_supervised_aggregated.txt';
    elseif(hasSemiSupervision)
        nameGAL = 'GAL_semisupervised_results.txt';
        nameDS = 'DS_semisupervised_results.txt';
        aggLNameGAL = 'GAL_semisupervised_aggregated.txt';
        aggLNameDS = 'DS_semisupervised_aggregated.txt';
    else
        nameGAL = 'GAL_unsupervised_results.txt';
        nameDS = 'DS_unsupervised_results.txt';
        aggLNameGAL = 'GAL_unsupervised_aggregated.txt';
        aggLNameDS = 'DS_unsupervised_aggregated.txt';
    end
    fidGAL = fopen([path '/results/nFold/' nameGAL],'w');
    fidDS = fopen([path '/results/nFold/' nameDS],'w');
    fprintf(fidGAL,'%s\n','%Accuracy Precision Recall Fmeasure');
    fprintf(fidGAL,'%s\n',['% ' num2str(categ'+1)]);
    fprintf(fidDS,'%s\n','%Accuracy Precision Recall Fmeasure');
    fprintf(fidDS,'%s\n',['% ' num2str(categ'+1)]);
    for i = 1:size(resultVecDS,1)
        fprintf(fidGAL,'%s\n',num2str(resultVecGAL(i,:)));
        fprintf(fidDS,'%s\n',num2str(resultVecDS(i,:)));
    end
    fclose(fidGAL);
    fclose(fidDS);
    if(exist([path '/results/nFold/aggregated'],'dir'))
        fidDS = fopen([path '/results/nFold/aggregated/' aggLNameDS],'w');
        fidGAL = fopen([path '/results/nFold/aggregated/' aggLNameGAL],'w');
        for i = 1:size(aggregatedLabelsDS,1)
            fprintf(fidDS,'%s\n',num2str(aggregatedLabelsDS(i,:)));
            fprintf(fidGAL,'%s\n',num2str(aggregatedLabelsGAL(i,:)));
        end
        fclose(fidDS);
        fclose(fidGAL);
    end
end

function writeTempFiles(evalW,evalQ,evalR,tuneQ,tuneR,categories)
    fid = fopen('responses.txt','w');
    for i=1:length(evalW)
        fprintf(fid,'%s\t%s\t%s\n',num2str(evalW(i)),num2str(evalQ(i)),num2str(evalR(i)));
    end
    fclose(fid);
    
    fid = fopen('gold.txt','w');
    for i=1:length(tuneQ)
        fprintf(fid,'%s\t%s\n',num2str(tuneQ(i)),num2str(tuneR(i)));
    end
    fclose(fid);
    
    fid = fopen('categories.txt','w');
    for i=1:length(categories)
        fprintf(fid,'%s\n',num2str(categories(i)));
    end
    fclose(fid);
    
    fid = fopen('categoriesWP.txt','w');
    categoryCounts = ones(length(categories),1);
    for i=1:length(categories)
        tempCount = sum(tuneR == categories(i));
        categoryCounts(i) = categoryCounts(i) + tempCount;
    end
    categoryCounts = categoryCounts./sum(categoryCounts);
    for i=1:length(categories)
        fprintf(fid,'%s\t%s\n',num2str(categories(i)),num2str(categoryCounts(i)));
    end
    fclose(fid);
    
    fid = fopen('cost.txt','w');
    costMat = perms(categories);
    costMat = costMat(:,1:2);
    costMat = unique(costMat,'rows');
    costs = ones(size(costMat,1),1);
    costMat = [costMat costs];
    addOn = [categories categories];
    addOnCost = zeros(length(categories),1);
    addOn = [addOn addOnCost];
    costMat = [costMat;addOn];
    for i=1:size(costMat,1)
        fprintf(fid,'%s\t%s\t%s\n',num2str(costMat(i,1)),num2str(costMat(i,2)),num2str(costMat(i,3)));
    end
    fclose(fid);
end