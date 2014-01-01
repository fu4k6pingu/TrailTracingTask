% Flower-shaped Trail-Tracing Task (fsttt)
%
%
% Output
%
%   兩分鐘內可以畫幾圈
%   要計算小朋友畫一圈的『時間』
%   『超出範圍的次數』
%
clear all;
close all;
format bank;

% 目前是否還在程式開發狀態
DEBUG = true;

% 取得受試者編號
sn = int2str(getSubjectId);


%% 設定的地方
%
% 設定常數
NORMAL = 0;                        % 正常字體 ref:http://docs.psychtoolbox.org/TextStyle
BOLD   = 1;                        % 粗體
MINUTE = 60;                       % 分鐘
RED    = [255, 0, 0];              % 紅色
GREEN  = [0, 255, 0];              % 綠色
BLUE   = [0, 0, 255];              % 藍色
BLACK  = [0, 0, 0];                % 黑色
WHITE  = [255, 255, 255];          % 白色
GARY   = [128, 128, 128];          % 灰色

% 設定參數
fontName       = 'Arial';            % 字型名稱
imageName      = 'flower.png';       % 圖片檔名
dataPrefix     = ['sbj', sn,'_'];    % 結果檔前置字串
dataFolder     = 'data';             % 結果檔儲存資料夾名稱
textSize       = 36;                 % 一般訊息字體大小
textStyle      = BOLD;               % 一般訊息字體樣式
infoTextSize   = 20;                 % 輔助資訊字體大小
infoTextStyle  = NORMAL;             % 輔助訊息字體樣式
cursorShape    = 'Arrow';            % 游標長相
threshold      = 13;                 % 容忍範圍，必須是「奇數」
nTrials        = 4;                  % 嘗試數目
sampleTime     = 0.005;               % 取樣頻率 (sec)
trialDuration  = 2 * MINUTE;         % 單次嘗試時間
lineWidth      = 1;                  % 游標路徑寬度
initMousePos   = [215, 310];         % 游標初始位置
halfwayPos     = [228, 50; ...       % 中途線座標
                  228, 74];
destinationPos = [228, 286; ...      % 終點線座標
                  228, 304];

% 結果檔表頭
dataHeader = 'SN Trial Trace IsCompleted TraceStartTime TraceEndTime TraceElapsedTime OB_Count OB_Point TracePath';
% 開結果檔
fid = fopen(strcat(dataFolder, filesep, dataPrefix, 'result.txt'), 'wt');
% 先寫入結果檔表頭
headerStr = textscan(dataHeader, '%s', 'delimiter', ' ');
for i = 1:length(headerStr{1})
    fprintf(fid, '%s\t', headerStr{1}{i});
end
fprintf(fid, '\n');

% 設定訊息
welcomeMsg       = 'Let us draw something\n\nPress anykey to continue';
instructions     = 'Draw without touching the contour.\n\nPress anykey to continue';
startMsg         = '\n\nDrag to Start!';
breakMsg         = 'Take Break';
byeMsg           = 'Good Bye!';
outOfBoundaryMsg = 'Outside Warning!';
nextTraceMsg     = 'Release mouse to next trace!';

% 設定顏色
msgColor     = WHITE;
insideColor  = GREEN;
outsideColor = RED;
infoColor    = BLUE;
maskColor    = GARY;
maskMsgColor = BLACK;


%% 實驗的地方
%

try
    % 找出螢幕編號
    whichScreen = max(Screen('Screens'));
    whichScreen = 0;    % 避開外接螢幕
    % 產生實驗視窗
    [theWindow, theRect] = Screen(whichScreen, 'OpenWindow', GARY);

    % 設定字型、字體大小、樣式
    Screen(theWindow, 'TextFont', fontName);
    Screen('TextSize', theWindow, textSize);
    Screen('TextStyle', theWindow, textStyle);

    % 畫提示訊息
    DrawFormattedText(theWindow, welcomeMsg, 'center', 'center', msgColor);
    Screen('Flip', theWindow);
    % 等待按任意鍵以閱讀指導語
    KbWait([], 3);
    
    % 畫指導語
    DrawFormattedText(theWindow, instructions, 'center', 50, msgColor);
    % 把圖片讀進來
    imagedata = imread(imageName);
    % 取得圖片輪廓資訊
    imContour = im2bw(imagedata);
    % 取得圖片大小
    [imageHeight, imageWidth] = size(imContour);

    % 如果圖片不是全螢幕，計算偏移量以便後續處理
    if (theRect(RectRight) ~= imageWidth) && (theRect(RectRight) ~= imageHeight)
        xOffset = (theRect(RectRight )/2) - (imageWidth /2) - 1;
        yOffset = (theRect(RectBottom)/2) - (imageHeight/2) - 1;
    else
        xOffset = 0;
        yOffset = 0;
    end

    % 計算判斷通過的直線區域，中途點
    halfwayPos(:, 1) = halfwayPos(:, 1) + xOffset;
    halfwayPos(:, 2) = halfwayPos(:, 2) + yOffset;
    halfwayPosCount = halfwayPos(2, 2) - halfwayPos(1, 2) + 1;
    halfwayRegion = [repmat(halfwayPos(1, 1), 1, halfwayPosCount); ...
                     halfwayPos(1, 2):halfwayPos(2, 2)]';

    % 計算判斷通過的直線區域，終點
    destinationPos(:, 1) = destinationPos(:, 1) + xOffset;
    destinationPos(:, 2) = destinationPos(:, 2) + yOffset;
    destinationPosCount = destinationPos(2, 2) - destinationPos(1, 2) + 1;
    destinationRegion = [repmat(destinationPos(1, 1), 1, destinationPosCount); ...
                         destinationPos(1, 2):destinationPos(2, 2)]';

    % 建立輪廓矩陣
    [r, c] = ind2sub(size(imContour), find(imContour == 1));
    imContourInd = [c'+xOffset-1; r'+yOffset-1]';
    % 在輪廓矩陣裡，除去「判斷通過的直線區域」
    for i = length(destinationRegion):-1:1
        di = find(imContourInd(:, 1) == destinationRegion(i, 1) & ...
                  imContourInd(:, 2) == destinationRegion(i, 2));
        imContourInd(di, :) = [];
    end

    % 做成貼圖材質
    texture = Screen('MakeTexture', theWindow, imagedata);
    % 畫圖片
    Screen('DrawTexture', theWindow, texture);
    % 調整游標至初始位置
    SetMouse(initMousePos(1)+xOffset, initMousePos(2)+yOffset);
    ShowCursor(cursorShape);
    % 呈現畫面給受試者
    Screen('Flip', theWindow);
    % 等待按任意鍵以開始實驗
    KbWait([], 3);


    for iTrial = 1:nTrials
        % 清掉鍵盤滑鼠事件
        FlushEvents;

        % 準備嘗試開始畫面：秀出第幾次嘗試、畫圖片
        str = [int2str(iTrial), ' of ', int2str(nTrials), startMsg];
        DrawFormattedText(theWindow, str, 'center', 50, msgColor);
        Screen('DrawTexture', theWindow, texture);
        Screen('Flip', theWindow);

        % 讓滑鼠準備好
        while true
            [x, y, buttons] = GetMouse(theWindow);
            if buttons(1)
                break;
            end
        end

        % 調整游標至初始位置
        SetMouse(initMousePos(1)+xOffset, initMousePos(2)+yOffset);
        ShowCursor(cursorShape);

        % 定義一個 trace 會用到的變數
        insideContourNow     = true;    % 是否在輪廓內
        isPassedHalfway      = false;   % 是否經過中途點
        isPassedDestination  = false;   % 是否經過終點
        points               = [];      % 路徑集合
        outOfBoundaryPoints  = [];      % 出界點集合
        boundaryRegion       = [];      % 邊界區域
        iTrace               = 1;       % 此嘗試第個 trace
        completedTraceCount  = 0;       % 此嘗試完成畫圈的 trace 數目
        thisTraceIsCompleted = false;   % 此 trace 是否完成畫圈

        if DEBUG; infoStr = []; end

        [theX, theY] = GetMouse(theWindow);
        points = [theX, theY];
        previousX = theX;
        previousY = theY;

        % 該 trial 開始時間
        iTrialStartTime = GetSecs;
        % 該 trial 結束時間
        iTrialEndTime = iTrialStartTime + trialDuration;
        % 該 trace 開始時間
        iTraceStartTime = GetSecs - iTrialStartTime;

        nextSampleTime = iTrialStartTime + sampleTime;

        % 該嘗試開始計時
        while GetSecs < iTrialEndTime

            % 取得滑鼠目前 X, Y 坐標
            [currentX, currentY, buttons] = GetMouse(theWindow);
            % 輪廓資訊的精準度只到整數，而 GetMouse 的精準度有到小數點下 4 位
            currentX = round(currentX);
            currentY = round(currentY);

            % 如果滑鼠放開
            if ~buttons(1)

                %
                % 滑鼠放開代表結束該 trace 
                % 得來處理該 trace 各種資訊
                %

                % 停止該 trace 計時
                iTraceEndTime = GetSecs - iTrialStartTime;
                
                % 是否有完成畫圈
                if (isPassedDestination == true)
                    thisTraceIsCompleted = true;
                    completedTraceCount = completedTraceCount + 1;
                end

                % 計算該 trace 出界幾次
                if ~isempty(outOfBoundaryPoints)
                    outOfBoundaryCount = size(outOfBoundaryPoints, 1);
                else
                    outOfBoundaryCount = 0;
                end

                % 如果有出界過，則把出界點資訊存起來
                if outOfBoundaryCount ~= 0
                    OBPointsFileName = strcat(dataPrefix, ...
                                              'trial', int2str(iTrial), '_', ...
                                              'trace', int2str(iTrace), '_obpoint.mat');
                    save(strcat(pwd, filesep, dataFolder, filesep, OBPointsFileName), 'outOfBoundaryPoints');
                else
                    OBPointsFileName = 'N/A';
                end

                % 把描繪路徑資訊存起來
                if ~isempty(points)
                    pointsFileName = strcat(dataPrefix, ...
                                            'trial', int2str(iTrial), '_', ...
                                            'trace', int2str(iTrace), '_path.mat');
                    save(strcat(pwd, filesep, dataFolder, filesep, pointsFileName), 'points');
                else
                    pointsFileName = 'N/A';
                end

                % 寫入結果檔
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
                % 開始新一個 trace
                %

                % 此嘗試的 trace 加 1
                iTrace = iTrace + 1;

                Screen('DrawTexture', theWindow, texture);
                Screen('Flip', theWindow);

                % 讓滑鼠準備好
                while true
                    [x, y, buttons] = GetMouse(theWindow);
                    if buttons(1)
                        break;
                    end
                end

                % 調整游標至初始位置
                SetMouse(initMousePos(1)+xOffset, initMousePos(2)+yOffset);
                ShowCursor(cursorShape);

                % 重新初始化所有變數
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

                % trace 重新開始計時
                iTraceStartTime = GetSecs - iTrialStartTime;
            end

            % 滑鼠移動時，重新繪製畫面
            if (currentX ~= previousX || currentY ~= previousY)
                % 先把底圖畫出來
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

            % 每經過 sampleTime 就取樣（sampleTime），記錄 X, Y 坐標
            if (GetSecs > nextSampleTime)

                currentXy = [currentX, currentY];
                currentXyStr = int2str(currentXy);
                
                % 目前游標是否碰到輪廓
                if ismember(currentXy, imContourInd, 'rows')

                    if isempty(boundaryRegion) 
                        % 沒有出界點集合，或是沒有碰到出界點集合
                        if isempty(outOfBoundaryPoints) || ...
                          ~ismember(currentXy, outOfBoundaryPoints, 'rows')

                            boundaryRegion = point2Region(currentXy, threshold);
                            outOfBoundaryPoints = [outOfBoundaryPoints; currentXy];
                            insideContourNow = false;
                            
                            if DEBUG; infoStr = [infoStr, 'Out:  ', currentXyStr, '\n']; end                            
                        end

                    else

                        % 沒有碰到出界點集合，但是碰到邊界區域
                        if ~ismember(currentXy, outOfBoundaryPoints, 'rows') && ...
                            ismember(currentXy, boundaryRegion, 'rows')

                            boundaryRegion = [];
                            insideContourNow = true;

                            if DEBUG; infoStr = [infoStr, 'Back: ', currentXyStr, '\n']; end
                        end

                    end
                else
                    % 判斷是否經過中途點
                    if (isPassedHalfway == false)
                        if ismember(currentXy, halfwayRegion, 'rows')
                            isPassedHalfway = true;
                            
                            if DEBUG; infoStr = [infoStr, 'Half:  ', currentXyStr, '\n']; end
                        end
                    end

                    % 判斷是否經過終點
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

        % 清掉剛才所有畫面
        Screen('Flip', theWindow);

        % 在嘗試之間，秀出休息訊息
        if (iTrial < nTrials)

            %
            % 除了滑鼠放開之外，時間到也代表結束 trace 
            % 得來處理該 trace 各種資訊
            % 

            % 停止該 trace 計時
            iTraceEndTime = GetSecs - iTrialStartTime;

            % 是否有完成畫圈
            if (isPassedDestination == true)
                thisTraceIsCompleted = true;
                completedTraceCount = completedTraceCount + 1;
            end

            % 計算該 trace 出界幾次
            if ~isempty(outOfBoundaryPoints)
                outOfBoundaryCount = size(outOfBoundaryPoints, 1);
            else
                outOfBoundaryCount = 0;
            end

            % 如果有出界過，則把出界點資訊存起來
            if outOfBoundaryCount ~= 0
                OBPointsFileName = strcat(dataPrefix, ...
                                          'trial', int2str(iTrial), '_', ...
                                          'trace', int2str(iTrace), '_obpoint.mat');
                save(strcat(pwd, filesep, dataFolder, filesep, OBPointsFileName), 'outOfBoundaryPoints');
            else
                OBPointsFileName = 'N/A';
            end

            % 把描繪路徑資訊存起來
            if ~isempty(points)
                pointsFileName = strcat(dataPrefix, ...
                                        'trial', int2str(iTrial), '_', ...
                                        'trace', int2str(iTrace), '_path.mat');
                save(strcat(pwd, filesep, dataFolder, filesep, pointsFileName), 'points');
            else
                pointsFileName = 'N/A';
            end

            % 寫入結果檔
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

    % 關結果檔
    fclose(fid);

    % 秀出再見訊息
    DrawFormattedText(theWindow, byeMsg, 'center', 'center', msgColor);
    Screen('Flip', theWindow);
    % 等待按任意鍵以結束實驗
    KbWait([], 3);

    Screen('CloseAll');
    ShowCursor;
catch err
    Screen('CloseAll');
    ShowCursor;

    fclose('all');

    psychrethrow(psychlasterror);
end