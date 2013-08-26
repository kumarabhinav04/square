function allData = loadNFold(nFoldEvalDir)
% loadNFold loads data from nFold Evaluation directory
% Inputs: 
%   nFoldEvalDir -
% Outputs:
%   allData -
% ****************************************************

    %Params
    allData = struct();
    allDir = dir(nFoldEvalDir);
    allDataIdx = 1;
    for i=1:length(allDir)
        nFoldDataTune = struct();
        nFoldDataEval = struct();
        nFoldDataBoth = struct();
        if(strcmp(allDir(i).name(1),'.'))
            continue;
        end
        filesInDir = dir([nFoldEvalDir '/' allDir(i).name]); 
        for k=1:length(filesInDir)
            [path name ext] = fileparts(filesInDir(k).name);
            if(~strcmp(ext,'.txt'))
                continue;
            end
            partsIdx = strfind(name,'_');
            if(length(partsIdx)<3)
                continue;
            end
                
            type = name(1:partsIdx(1)-1);
            num = str2num(name(partsIdx(3)+1:length(name)));
            splitType = name(partsIdx(2)+1:partsIdx(3)-1);
            
            if(strcmp(type,'responses'))
                responses = load([nFoldEvalDir '/' allDir(i).name '/' filesInDir(k).name]);
                workerIds = responses(:,2);
                workerQuestions = responses(:,1);
                workerResponses = responses(:,3) - 1;
                numWorkers = length(unique(workerIds));
                numQuestions = length(unique(workerQuestions));
                disp(['Read Inputs from ' allDir(i).name '/' name ext]);
                disp(['Number of workers: ' num2str(numWorkers)]);
                disp(['Number of questions: ' num2str(numQuestions)]);
                disp(['Number of responses: ' num2str(length(workerResponses))]);
                
                if(strcmp(splitType,'tune'))
                    nFoldDataTune(num).workerIds = workerIds;
                    nFoldDataTune(num).workerQuestions = workerQuestions;
                    nFoldDataTune(num).workerResponses = workerResponses;
                    nFoldDataTune(num).numWorkers = numWorkers;
                    nFoldDataTune(num).numQuestions = numQuestions;
                    nFoldDataTune(num).path = [nFoldEvalDir '/' allDir(i).name '/' filesInDir(k).name];
                end
                
                if(strcmp(splitType,'eval'))
                    nFoldDataEval(num).workerIds = workerIds;
                    nFoldDataEval(num).workerQuestions = workerQuestions;
                    nFoldDataEval(num).workerResponses = workerResponses;
                    nFoldDataEval(num).numWorkers = numWorkers;
                    nFoldDataEval(num).numQuestions = numQuestions;
                    nFoldDataEval(num).path = [nFoldEvalDir '/' allDir(i).name '/' filesInDir(k).name];
                end
                
                if(strcmp(splitType,'tuneEval'))
                    nFoldDataBoth(num).workerIds = workerIds;
                    nFoldDataBoth(num).workerQuestions = workerQuestions;
                    nFoldDataBoth(num).workerResponses = workerResponses;
                    nFoldDataBoth(num).numWorkers = numWorkers;
                    nFoldDataBoth(num).numQuestions = numQuestions;
                    nFoldDataBoth(num).path = [nFoldEvalDir '/' allDir(i).name '/' filesInDir(k).name];
                end
                
            elseif(strcmp(type,'gt'))
                gold = load([nFoldEvalDir '/' allDir(i).name '/' filesInDir(k).name]);
                goldQuestions = gold(:,1);
                goldResponses = gold(:,2) - 1;
                numGold = length(goldQuestions);
                disp(['Read gold responses from ' allDir(i).name '/' name ext]);
                disp(['Number of gold responses: ' num2str(numGold)]);
                
                if(strcmp(splitType,'tune'))
                    nFoldDataTune(num).goldQuestions = goldQuestions;
                    nFoldDataTune(num).goldResponses = goldResponses;
                    nFoldDataTune(num).path = [nFoldEvalDir '/' allDir(i).name '/' filesInDir(k).name];
                end
                
                if(strcmp(splitType,'eval'))
                    nFoldDataEval(num).goldQuestions = goldQuestions;
                    nFoldDataEval(num).goldResponses = goldResponses;
                    nFoldDataEval(num).path = [nFoldEvalDir '/' allDir(i).name '/' filesInDir(k).name];
                end
            end
        end
        allData(allDataIdx).tune = nFoldDataTune;
        allData(allDataIdx).eval = nFoldDataEval;
        allData(allDataIdx).both = nFoldDataBoth;
        allData(allDataIdx).name = allDir(i).name;
        allDataIdx = allDataIdx + 1;
    end
end