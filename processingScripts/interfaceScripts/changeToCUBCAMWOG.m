function saveMat = changeToCUBCAMWOG(saveMat)
% changeToCUBCAM changes data format to a format acceptable to CUBAM
% Inputs:
%   saveMat -
%   goldMat -
% ******************************************************************
    actualQuestions = saveMat(:,1);
    actualWorkers = saveMat(:,2);
    actualResponses = saveMat(:,3);
    
    
    
    newQuestions = -1.*ones(length(actualQuestions),1);
    newWorkers = -1.*ones(length(actualWorkers),1);
    
    
    questions = unique(actualQuestions,'stable');
    workers = unique(actualWorkers);
    remapQuestions = (1:length(questions))'-1;
    remapWorkers = (1:length(workers))'-1;
    for i=1:length(questions)
        logical = actualQuestions == questions(i);
        newQuestions(logical) = remapQuestions(i);
    end
    actualQuestions = newQuestions;
    for i=1:length(workers)
        logical = actualWorkers == workers(i);
        newWorkers(logical) = remapWorkers(i);
    end
    actualWorkers = newWorkers;
    [temp idx] = sort(actualWorkers,1,'ascend');
    actualWorkers = actualWorkers(idx);
    actualResponses = actualResponses(idx);
    actualQuestions = actualQuestions(idx);
    saveMat = [actualQuestions actualWorkers actualResponses];
end