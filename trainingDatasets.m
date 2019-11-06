echo on
%**************************************************************************
%       trainingDatasets.m       
%      ====================
% CREATED: OCTOBER, 2019
% MODIFIED: NOVEMBER 6, 2019
% EDITOR: X.Y. ZHUANG
%
% DESCRITION:  
%   SPLIT AND BUILD TRAINING IMAGE DATASETS
%
% NOTES:
%   - RESCALE IMAGE SIZE
%   - AUGMENTATION (ROTATION)
%   - FIXED INTENSITY RANGE
%
% COMPILE:
%   - WIN10 (64-bit)
%   - MATLAB R2019b (VER.9.7)
%**************************************************************************
echo off
close all, clear all

%% 
if ~exist('testImages\Flagellated', 'dir')
    mkdir('testImages\Flagellated')
end
if ~exist('trainingImages\Flagellated', 'dir')
    mkdir('trainingImages\Flagellated')
end
if ~exist('testImages\nonFlagellated', 'dir')
    mkdir('testImages\nonFlagellated')
end
if ~exist('trainingImages\nonFlagellated', 'dir')
    mkdir('trainingImages\nonFlagellated')
end

%% Count the total number of flagellated and non-flagellated cell
inputfolder= 'E:\Experiments\Deep learning\FlaNet\raw datasets\';

listing = dir(inputfolder);
for nDir = 3:length(listing)
    inputdir = [inputfolder,listing(nDir).name,'\'];
    for nCase = 1:2
        switch nCase
            case 1 % flagllated cell
                sublisting = dir([inputdir,'*_flagellated.tif']);
            case 2 % non-flagellated cell
                sublisting = dir([inputdir,'*_nonflagellated.tif']);
        end
        
        nCount = 0;
        for nFile = 1:length(sublisting)
            inputfile = [inputdir,sublisting(nFile).name];
            info = imfinfo(inputfile);
            for nFrmae = 1:numel(info)
                nCount = nCount+1;
            end
        end
        
        switch nCase
            case 1
                nCounts_Fla(nDir-2) = nCount*4;
            case 2
                nCounts_noFla(nDir-2) = nCount*4;
        end
    end
end

%% split and write datasets into training and test folder
rescale = 0.5;
split_frac = 0.8; % Split image datasets by proportions

listing = dir(inputfolder);
for nDir = 3:length(listing)
    inputdir = [inputfolder,listing(nDir).name,'\']
    for nCase = 1:2
        switch nCase
            case 1
                sublisting = dir([inputdir,'*_flagellated.tif']);
            case 2
                sublisting = dir([inputdir,'*_nonflagellated.tif']);
        end
        
        nCount = 0;
        for nFile = 1:length(sublisting)
            inputfile = [inputdir,sublisting(nFile).name];
            info = imfinfo(inputfile);
            for nFrmae = 1:numel(info)
                origina = imread(inputfile,nFrmae);
                neworigina = imresize(origina,rescale,'method','bicubic'); % rescale image
                neworigina2 = imadjust(neworigina,[400,5000]/(2^16-1)); % unify the same intensity range
                neworigina3 = uint8(255*double(neworigina2)./max(double(neworigina2(:))));
                
                for nAng = 0:3 % augmentation
                    nCount = nCount+1;
                    neworigina3 = imrotate(neworigina3,90*nAng);
                    
                    switch nCase
                        case 1
                            if (nCount<=round(nCounts_Fla(nDir-2)*split_frac))
                                outputdir = 'E:\Experiments\Deep learning\FlaNet\trainingDatasets\trainingImages\';
                                outputfile = [outputdir,'Flagellated\',listing(nDir).name,'-flagellated',num2str(nCount),'.tif'];
                            else
                                outputdir = 'E:\Experiments\Deep learning\FlaNet\trainingDatasets\testImages\';
                                outputfile = [outputdir,'Flagellated\',listing(nDir).name,'-flagellated',num2str(nCount),'.tif'];
                            end
                        case 2
                            if (nCount<=round(nCounts_noFla(nDir-2)*split_frac))
                                outputdir = 'E:\Experiments\Deep learning\FlaNet\trainingDatasets\trainingImages\';
                                outputfile = [outputdir,'nonFlagellated\',listing(nDir).name,'-nonflagellated',num2str(nCount),'.tif'];
                            else
                                outputdir = 'E:\Experiments\Deep learning\FlaNet\trainingDatasets\testImages\';
                                outputfile = [outputdir,'nonFlagellated\',listing(nDir).name,'-nonflagellated',num2str(nCount),'.tif'];
                            end
                    end
                    imwrite(neworigina3,outputfile,'Compression','none');
                end
            end
        end
    end
end

