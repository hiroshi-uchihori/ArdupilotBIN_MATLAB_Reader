%%binファイルの読み込み

filename = '00000062.bin';
bin = ardupilotreader(filename);

%%binファイルに含まれるすべてのメッセージをmsgに抽出
msg = readMessages(bin);

%%読み込み時間帯の指定
d1 = duration([0 20 00],'Format','hh:mm:ss.SSSSSS');
d2 = duration([1 0 00],'Format','hh:mm:ss.SSSSSS');

%%gpsデータの読み込み
gpsMsg = readMessages(bin,'MessageName',{'GPS'},'Time',[d1 d2]);
gpsData = gpsMsg.MsgData{1,1};

gms = gpsData.GMS; %GPSミリ秒
gwk = gpsData.GWk; %GPS週
gtimeUS = gpsData.TimeUS; %GPSメッセージの起動からのデータ時刻

%%gpsデータからUTC時刻を生成
gpsEpoch = datetime(1980,1,6,0,0,0);
gpsseconds = gms + gwk*7*24*3600;
tgps=gpsEpoch+gpsseconds/(24*3600);
tgps.Format = 'yyyy-MM-dd HH:mm:ss.SSSSSS';

tGPS0 = tgps(1); %gps時刻の先頭時刻
gtimeUS0 = gtimeUS(1); %gpeメッセージtimeUSの先頭時間

%%姿勢データの読込み
attMsg = readMessages(bin,'MessageName',{'ATT'},'Time',[d1 d2]);
attData = attMsg.MsgData{1,1};

atttimeUS = attData.TimeUS; %ATTメッセージデータの起動からのデータ時刻
roll = attData.Roll; %ロールデータ
pitch = attData.Pitch; % ピッチデータ
yaw = attData.Yaw; %ヨーデータ

%姿勢データtimeUSに対応するgps時刻生成
attGPS = tGPS0 - gtimeUS0 + atttimeUS;

%生成したATTgps時刻＋ATT姿勢データをxlsxファイルとして書き込む
t = table(attGPS,roll,pitch,yaw,'VariableNames', {'GPSTime','Roll','Picth','Yaw'});

[filepath, name, ext] = fileparts(filename);
new_filename = fullfile(filepath, [name, '.xlsx']);
writetable(t,new_filename);
