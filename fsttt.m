% Flower-shaped Trail-Tracing Task (fsttt)
%
%
% Output
%
%   ��������i�H�e�X��
%   �n�p��p�B�͵e�@�骺�y�ɶ��z
%   �y�W�X�d�򪺦��ơz
%
clear all;
close all;
format bank;

% �ثe�O�_�٦b�{���}�o���A
DEBUG = true;

% ���o���ժ̽s��
sn = int2str(getSubjectId);


%% �]�w���a��
%
% �]�w�`��
NORMAL = 0;                        % ���`�r�� ref:http://docs.psychtoolbox.org/TextStyle
BOLD   = 1;                        % ����
MINUTE = 60;                       % ����
RED    = [255, 0, 0];              % ����
GREEN  = [0, 255, 0];              % ���
BLUE   = [0, 0, 255];              % �Ŧ�
BLACK  = [0, 0, 0];                % �¦�
WHITE  = [255, 255, 255];          % �զ�
GARY   = [128, 128, 128];          % �Ǧ�

% �]�w�Ѽ�
fontName       = 'Arial';            % �r���W��
imageName      = 'flower.png';       % �Ϥ��ɦW
dataPrefix     = ['sbj', sn,'_'];    % ���G�ɫe�m�r��
dataFolder     = 'data';             % ���G���x�s��Ƨ��W��
textSize       = 36;                 % �@��T���r��j�p
textStyle      = BOLD;               % �@��T���r��˦�
infoTextSize   = 20;                 % ���U��T�r��j�p
infoTextStyle  = NORMAL;             % ���U�T���r��˦�
cursorShape    = 'Arrow';            % ��Ъ���
threshold      = 13;                 % �e�Խd��A�����O�u�_�ơv
nTrials        = 4;                  % ���ռƥ�
sampleTime     = 0.005;               % �����W�v (sec)
trialDuration  = 2 * MINUTE;         % �榸���ծɶ�
lineWidth      = 1;                  % ��и��|�e��
initMousePos   = [215, 310];         % ��Ъ�l��m
halfwayPos     = [228, 50; ...       % ���~�u�y��
                  228, 74];
destinationPos = [228, 286; ...      % ���I�u�y��
                  228, 304];

% ���G�ɪ��Y
dataHeader = 'SN Trial Trace IsCompleted TraceStartTime TraceEndTime TraceElapsedTime OB_Count OB_Point TracePath';
% �}���G��
fid = fopen(strcat(dataFolder, filesep, dataPrefix, 'result.txt'), 'wt');
% ���g�J���G�ɪ��Y
headerStr = textscan(dataHeader, '%s', 'delimiter', ' ');
for i = 1:length(headerStr{1})
    fprintf(fid, '%s\t', headerStr{1}{i});
end
fprintf(fid, '\n');

% �]�w�T��
welcomeMsg       = 'Let us draw something\n\nPress anykey to continue';
instructions     = 'Draw without touching the contour.\n\nPress anykey to continue';
startMsg         = '\n\nDrag to Start!';
breakMsg         = 'Take Break';
byeMsg           = 'Good Bye!';
outOfBoundaryMsg = 'Outside Warning!';
nextTraceMsg     = 'Release mouse to next trace!';

% �]�w�C��
msgColor     = WHITE;
insideColor  = GREEN;
outsideColor = RED;
infoColor    = BLUE;
maskColor    = GARY;
maskMsgColor = BLACK;


%% ���窺�a��
%

try
    % ��X�ù��s��
    whichScreen = max(Screen('Screens'));
    whichScreen = 0;    % �׶}�~���ù�
    % ���͹������
    [theWindow, theRect] = Screen(whichScreen, 'OpenWindow', GARY);

    % �]�w�r���B�r��j�p�B�˦�
    Screen(theWindow, 'TextFont', fontName);
    Screen('TextSize', theWindow, textSize);
    Screen('TextStyle', theWindow, textStyle);

    % �e���ܰT��
    DrawFormattedText(theWindow, welcomeMsg, 'center', 'center', msgColor);
    Screen('Flip', theWindow);
    % ���ݫ����N��H�\Ū���ɻy
    KbWait([], 3);
    
    % �e���ɻy
    DrawFormattedText(theWindow, instructions, 'center', 50, msgColor);
    % ��Ϥ�Ū�i��
    imagedata = imread(imageName);
    % ���o�Ϥ�������T
    imContour = im2bw(imagedata);
    % ���o�Ϥ��j�p
    [imageHeight, imageWidth] = size(imContour);

    % �p�G�Ϥ����O���ù��A�p�ⰾ���q�H�K����B�z
    if (theRect(RectRight) ~= imageWidth) && (theRect(RectRight) ~= imageHeight)
        xOffset = (theRect(RectRight )/2) - (imageWidth /2) - 1;
        yOffset = (theRect(RectBottom)/2) - (imageHeight/2) - 1;
    else
        xOffset = 0;
        yOffset = 0;
    end

    % �p��P�_�q�L�����u�ϰ�A���~�I
    halfwayPos(:, 1) = halfwayPos(:, 1) + xOffset;
    halfwayPos(:, 2) = halfwayPos(:, 2) + yOffset;
    halfwayPosCount = halfwayPos(2, 2) - halfwayPos(1, 2) + 1;
    halfwayRegion = [repmat(halfwayPos(1, 1), 1, halfwayPosCount); ...
                     halfwayPos(1, 2):halfwayPos(2, 2)]';

    % �p��P�_�q�L�����u�ϰ�A���I
    destinationPos(:, 1) = destinationPos(:, 1) + xOffset;
    destinationPos(:, 2) = destinationPos(:, 2) + yOffset;
    destinationPosCount = destinationPos(2, 2) - destinationPos(1, 2) + 1;
    destinationRegion = [repmat(destinationPos(1, 1), 1, destinationPosCount); ...
                         destinationPos(1, 2):destinationPos(2, 2)]';

    % �إ߽����x�}
    [r, c] = ind2sub(size(imContour), find(imContour == 1));
    imContourInd = [c'+xOffset-1; r'+yOffset-1]';
    % �b�����x�}�̡A���h�u�P�_�q�L�����u�ϰ�v
    for i = length(destinationRegion):-1:1
        di = find(imContourInd(:, 1) == destinationRegion(i, 1) & ...
                  imContourInd(:, 2) == destinationRegion(i, 2));
        imContourInd(di, :) = [];
    end

    % �����K�ϧ���
    texture = Screen('MakeTexture', theWindow, imagedata);
    % �e�Ϥ�
    Screen('DrawTexture', theWindow, texture);
    % �վ��Цܪ�l��m
    SetMouse(initMousePos(1)+xOffset, initMousePos(2)+yOffset);
    ShowCursor(cursorShape);
    % �e�{�e�������ժ�
    Screen('Flip', theWindow);
    % ���ݫ����N��H�}�l����
    KbWait([], 3);


    for iTrial = 1:nTrials
        % �M����L�ƹ��ƥ�
        FlushEvents;

        % �ǳƹ��ն}�l�e���G�q�X�ĴX�����աB�e�Ϥ�
        str = [int2str(iTrial), ' of ', int2str(nTrials), startMsg];
        DrawFormattedText(theWindow, str, 'center', 50, msgColor);
        Screen('DrawTexture', theWindow, texture);
        Screen('Flip', theWindow);

        % ���ƹ��ǳƦn
        while true
            [x, y, buttons] = GetMouse(theWindow);
            if buttons(1)
                break;
            end
        end

        % �վ��Цܪ�l��m
        SetMouse(initMousePos(1)+xOffset, initMousePos(2)+yOffset);
        ShowCursor(cursorShape);

        % �w�q�@�� trace �|�Ψ쪺�ܼ�
        insideContourNow     = true;    % �O�_�b������
        isPassedHalfway      = false;   % �O�_�g�L���~�I
        isPassedDestination  = false;   % �O�_�g�L���I
        points               = [];      % ���|���X
        outOfBoundaryPoints  = [];      % �X���I���X
        boundaryRegion       = [];      % ��ɰϰ�
        iTrace               = 1;       % �����ղĭ� trace
        completedTraceCount  = 0;       % �����է����e�骺 trace �ƥ�
        thisTraceIsCompleted = false;   % �� trace �O�_�����e��

        if DEBUG; infoStr = []; end

        [theX, theY] = GetMouse(theWindow);
        points = [theX, theY];
        previousX = theX;
        previousY = theY;

        % �� trial �}�l�ɶ�
        iTrialStartTime = GetSecs;
        % �� trial �����ɶ�
        iTrialEndTime = iTrialStartTime + trialDuration;
        % �� trace �}�l�ɶ�
        iTraceStartTime = GetSecs - iTrialStartTime;

        nextSampleTime = iTrialStartTime + sampleTime;

        % �ӹ��ն}�l�p��
        while GetSecs < iTrialEndTime

            % ���o�ƹ��ثe X, Y ����
            [currentX, currentY, buttons] = GetMouse(theWindow);
            % ������T����ǫץu���ơA�� GetMouse ����ǫצ���p���I�U 4 ��
            currentX = round(currentX);
            currentY = round(currentY);

            % �p�G�ƹ���}
            if ~buttons(1)

                %
                % �ƹ���}�N������ trace 
                % �o�ӳB�z�� trace �U�ظ�T
                %

                % ����� trace �p��
                iTraceEndTime = GetSecs - iTrialStartTime;
                
                % �O�_�������e��
                if (isPassedDestination == true)
                    thisTraceIsCompleted = true;
                    completedTraceCount = completedTraceCount + 1;
                end

                % �p��� trace �X�ɴX��
                if ~isempty(outOfBoundaryPoints)
                    outOfBoundaryCount = size(outOfBoundaryPoints, 1);
                else
                    outOfBoundaryCount = 0;
                end

                % �p�G���X�ɹL�A�h��X���I��T�s�_��
                if outOfBoundaryCount ~= 0
                    OBPointsFileName = strcat(dataPrefix, ...
                                              'trial', int2str(iTrial), '_', ...
                                              'trace', int2str(iTrace), '_obpoint.mat');
                    save(strcat(pwd, filesep, dataFolder, filesep, OBPointsFileName), 'outOfBoundaryPoints');
                else
                    OBPointsFileName = 'N/A';
                end

                % ��yø���|��T�s�_��
                if ~isempty(points)
                    pointsFileName = strcat(dataPrefix, ...
                                            'trial', int2str(iTrial), '_', ...
                                            'trace', int2str(iTrace), '_path.mat');
                    save(strcat(pwd, filesep, dataFolder, filesep, pointsFileName), 'points');
                else
                    pointsFileName = 'N/A';
                end

                % �g�J���G��
                fprintf(fid, '%s\t', sn);
                fprintf(fid, '%d\t', iTrial);
                fprintf(fid, '%d\t', iTrace);
                fprintf(fid, '%d\t', thisTraceIsCompleted);
                fprintf(fid, '%.4f\t', iTraceStartTime);
                fprintf(fid, '%.4f\t', iTraceEndTime);
                fprintf(fid, '%.4f\t', iTraceEndTime-iTraceStartTime);
                fprintf(fid, '%d\t', outOfBoundaryCount);
                fprintf(fid, '%s\t', OBPointsFileName);
                fprintf(fid, '%s\n', pointsFileName);

                %
                % �}�l�s�@�� trace
                %

                % �����ժ� trace �[ 1
                iTrace = iTrace + 1;

                Screen('DrawTexture', theWindow, texture);
                Screen('Flip', theWindow);

                % ���ƹ��ǳƦn
                while true
                    [x, y, buttons] = GetMouse(theWindow);
                    if buttons(1)
                        break;
                    end
                end

                % �վ��Цܪ�l��m
                SetMouse(initMousePos(1)+xOffset, initMousePos(2)+yOffset);
                ShowCursor(cursorShape);

                % ���s��l�ƩҦ��ܼ�
                insideContourNow = true;
                isPassedHalfway = false;
                isPassedDestination = false;
                points = [];
                outOfBoundaryPoints = [];
                boundaryRegion = [];
                thisTraceIsCompleted = false;

                if DEBUG; infoStr = []; end

                [theX, theY] = GetMouse(theWindow);
                points = [theX, theY];
                previousX = theX;
                previousY = theY;
                currentX  = theX;
                currentY  = theY;

                % trace ���s�}�l�p��
                iTraceStartTime = GetSecs - iTrialStartTime;
            end

            % �ƹ����ʮɡA���sø�s�e��
            if (currentX ~= previousX || currentY ~= previousY)
                % ���⩳�ϵe�X��
                Screen('DrawTexture', theWindow, texture);
                DrawFormattedText(theWindow, ['~ Trace: ', int2str(iTrace)], theRect(RectRight)-300, theRect(RectBottom)-150, msgColor);
                DrawFormattedText(theWindow, ['# Trace: ', int2str(completedTraceCount)], theRect(RectRight)-300, theRect(RectBottom)-100, msgColor);

                if DEBUG
                    Screen('TextSize', theWindow, infoTextSize);
                    Screen('TextStyle', theWindow, infoTextStyle);
                    DrawFormattedText(theWindow, infoStr, theRect(RectRight)-300, 50, infoColor);

                    if (insideContourNow == true)
                        xyStrColor = insideColor;
                    else
                        xyStrColor = outsideColor;
                    end

                    Screen('DrawText', theWindow, int2str([currentX, currentY]), currentX+50, currentY+50, xyStrColor);
                    Screen('TextSize', theWindow, textSize);
                    Screen('TextStyle', theWindow, textStyle);
                end

                if (insideContourNow == true)
                    pointColor = insideColor;
                else
                    pointColor = outsideColor;
                    DrawFormattedText(theWindow, outOfBoundaryMsg, theRect(RectRight)-400, theRect(RectBottom)-350, outsideColor);
                end

                if (isPassedDestination == true)
                    Screen('FillRect', theWindow, maskColor);
                    DrawFormattedText(theWindow, nextTraceMsg, 'center', 'center', maskMsgColor);
                else
                    [nPoints, ~] = size(points);
                    for iPoint = 1:nPoints-1
                        Screen(theWindow, 'DrawLine', pointColor, ...
                               points(iPoint, 1), points(iPoint, 2), ...
                               points(iPoint+1, 1), points(iPoint+1, 2), lineWidth);
                    end                    
                end
                
                if DEBUG
                    if ~isempty(boundaryRegion)
                        brRect = SetRect(min(boundaryRegion(:, 1))-0, min(boundaryRegion(:, 2))-0, ...
                                         max(boundaryRegion(:, 1))+0, max(boundaryRegion(:, 2))+0);
                        Screen('FrameRect', theWindow, infoColor, brRect, lineWidth);
                    end
                end
                
                Screen('Flip', theWindow);
                previousX = currentX;
                previousY = currentY;
            end

            % �C�g�L sampleTime �N���ˡ]sampleTime�^�A�O�� X, Y ����
            if (GetSecs > nextSampleTime)

                currentXy = [currentX, currentY];
                currentXyStr = int2str(currentXy);
                
                % �ثe��ЬO�_�I�����
                if ismember(currentXy, imContourInd, 'rows')

                    if isempty(boundaryRegion) 
                        % �S���X���I���X�A�άO�S���I��X���I���X
                        if isempty(outOfBoundaryPoints) || ...
                          ~ismember(currentXy, outOfBoundaryPoints, 'rows')

                            boundaryRegion = point2Region(currentXy, threshold);
                            outOfBoundaryPoints = [outOfBoundaryPoints; currentXy];
                            insideContourNow = false;
                            
                            if DEBUG; infoStr = [infoStr, 'Out:  ', currentXyStr, '\n']; end                            
                        end

                    else

                        % �S���I��X���I���X�A���O�I����ɰϰ�
                        if ~ismember(currentXy, outOfBoundaryPoints, 'rows') && ...
                            ismember(currentXy, boundaryRegion, 'rows')

                            boundaryRegion = [];
                            insideContourNow = true;

                            if DEBUG; infoStr = [infoStr, 'Back: ', currentXyStr, '\n']; end
                        end

                    end
                else
                    % �P�_�O�_�g�L���~�I
                    if (isPassedHalfway == false)
                        if ismember(currentXy, halfwayRegion, 'rows')
                            isPassedHalfway = true;
                            
                            if DEBUG; infoStr = [infoStr, 'Half:  ', currentXyStr, '\n']; end
                        end
                    end

                    % �P�_�O�_�g�L���I
                    if (isPassedHalfway == true && isPassedDestination == false)
                        if ismember(currentXy, destinationRegion, 'rows')
                            isPassedDestination = true;

                            if DEBUG; infoStr = [infoStr, 'Dest:  ', currentXyStr, '\n']; end
                        end
                    end
                    
                end

                points = [points; currentX, currentY];
                nextSampleTime = nextSampleTime + sampleTime;
            end

        end

        % �M����~�Ҧ��e��
        Screen('Flip', theWindow);

        % �b���դ����A�q�X�𮧰T��
        if (iTrial < nTrials)

            %
            % ���F�ƹ���}���~�A�ɶ���]�N���� trace 
            % �o�ӳB�z�� trace �U�ظ�T
            % 

            % ����� trace �p��
            iTraceEndTime = GetSecs - iTrialStartTime;

            % �O�_�������e��
            if (isPassedDestination == true)
                thisTraceIsCompleted = true;
                completedTraceCount = completedTraceCount + 1;
            end

            % �p��� trace �X�ɴX��
            if ~isempty(outOfBoundaryPoints)
                outOfBoundaryCount = size(outOfBoundaryPoints, 1);
            else
                outOfBoundaryCount = 0;
            end

            % �p�G���X�ɹL�A�h��X���I��T�s�_��
            if outOfBoundaryCount ~= 0
                OBPointsFileName = strcat(dataPrefix, ...
                                          'trial', int2str(iTrial), '_', ...
                                          'trace', int2str(iTrace), '_obpoint.mat');
                save(strcat(pwd, filesep, dataFolder, filesep, OBPointsFileName), 'outOfBoundaryPoints');
            else
                OBPointsFileName = 'N/A';
            end

            % ��yø���|��T�s�_��
            if ~isempty(points)
                pointsFileName = strcat(dataPrefix, ...
                                        'trial', int2str(iTrial), '_', ...
                                        'trace', int2str(iTrace), '_path.mat');
                save(strcat(pwd, filesep, dataFolder, filesep, pointsFileName), 'points');
            else
                pointsFileName = 'N/A';
            end

            % �g�J���G��
            fprintf(fid, '%s\t', sn);
            fprintf(fid, '%d\t', iTrial);
            fprintf(fid, '%d\t', iTrace);
            fprintf(fid, '%d\t', thisTraceIsCompleted);
            fprintf(fid, '%.4f\t', iTraceStartTime);
            fprintf(fid, '%.4f\t', iTraceEndTime);
            fprintf(fid, '%.4f\t', iTraceEndTime-iTraceStartTime);
            fprintf(fid, '%d\t', outOfBoundaryCount);
            fprintf(fid, '%s\t', OBPointsFileName);
            fprintf(fid, '%s\n', pointsFileName);

            DrawFormattedText(theWindow, breakMsg, 'center', 'center', msgColor);
            Screen('Flip', theWindow);
            KbWait([], 3);
        end
    end

    % �����G��
    fclose(fid);

    % �q�X�A���T��
    DrawFormattedText(theWindow, byeMsg, 'center', 'center', msgColor);
    Screen('Flip', theWindow);
    % ���ݫ����N��H��������
    KbWait([], 3);

    Screen('CloseAll');
    ShowCursor;
catch err
    Screen('CloseAll');
    ShowCursor;

    fclose('all');

    psychrethrow(psychlasterror);
end