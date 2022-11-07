import processing.serial.*;
import java.io.FileWriter;

//########## クリップボード ##########
import java.awt.datatransfer.StringSelection;
import java.awt.Toolkit;
import java.awt.datatransfer.Clipboard;
//########## クリップボード ##########

String string="";

Serial port;
PrintWriter output;///File操作宣言



//########## 計測設定 ##########
String COM="COM16";
long endcyc=600000;//終了する時間（秒）
int delaytime=5;//delayタイム（ms）
int Max_val = 2000;//最大値設定
int Min_val = 0;//最小値設定
String savefile = "/data/save.csv";
int Plot_num=1200;//グラフのプロット数
int Sikiichi=150;//peak検出の閾値
int hekin=100;//加工データの平均回数
//########## 計測設定 ##########






int[] graph_color = new int[16];
//int graph_color[] = {#FF0000,#FF8000,#FFFF00,#80FF00,#00FF00,#00FFFF,#00FF80,#0000FF,#7F00FF,#FF00FF};//こっちでもいい
int[] data_table1 = new int[Plot_num];//生データグラフ用
int[] data_table2 = new int[Plot_num];//加工データグラフ用
float Angle2[]={-29.2,-25.6,-21.8,-17.7,-13.5,-9.1,-4.6,0,4.6,9.1,13.5,17.7,21.8,25.6,29.2};

int t = 0;
int i = 0;
int ii = 0;
int time0=0;
int time1=0;
float time2=0;


int screen_w = 1200;  //グラフの表示サイズ　横
int screen_h = 500;  //グラフの表示サイズ　縦
int sc_off=110;        //グラフの画面上のオフセット
String mystr1;      //CSV保存用の変数
//int read_flag=0;
int kazu=0;//シリアル通信のデータ受信　バイト数
int stop_flag=0;//start/stopの切り替え
int Angle=1;
int Gamen=0;


long[][] kando_max2 = new long[15][10];
long[][] kando_time2 = new long[15][10];

PFont myFont;
PFont myFont2;






void setup() {
  //外枠
  size(1450, 700);//ソフトの表示サイズ　　　リテラルのみ
  
  myFont = createFont("Dialog.bold", 40);
  myFont2 = createFont("Dialog.bold", 20);
 
  //########## Graphカラーの設定 ##########
  graph_color[0]=#0000FF;//blue
  graph_color[1]=#000080;//navy
  graph_color[2]=#008080;//teal
  graph_color[3]=#008000;//green
  graph_color[4]=#00FF00;//lime
  graph_color[5]=#00FFFF;//aqua
  graph_color[6]=#FFFF00;//yellow
  graph_color[7]=#FF0000;//red
  graph_color[8]=#FF00FF;//fuchsia
  graph_color[9]=#808000;//olive
  graph_color[10]=#800080;//purple
  graph_color[11]=#800000;//maroon
  graph_color[12]=#808080;//gray
  graph_color[13]=#C0C0C0;//silver
  graph_color[14]=#FFFFFF;//while
  graph_color[15]=#000000;//black
  
  //########## Graphカラーの設定 ##########



  //port = new Serial(this, Serial.list()[1], 115200);//ポートリストの何個目か？
  port = new Serial(this, COM, 115200);//シリアル通信設定
  
  background(200, 255, 255);//light blue　　背景色
  
  textSize(height*0.02);
  textAlign(LEFT);
  
  //########### グラフプロットデータの初期化 ###########
  for(i=0;i<Plot_num;i++){
    data_table1[i] = 0;
  }
  //########### グラフプロットデータの初期化 ###########
  
  
  //########## データの保存ファイル　##########
  output = createWriter(savefile);//データの保存ファイルを開く
  
  String memo = "time";
  memo=memo+",CH1";
  output.println(memo);
  //########## データの保存ファイル　##########
  
  
  time0= millis();//開始時間計測
  delay(1000);          //Arduinoが立ち上がるまで待つ（これがないと通信に失敗する）
  
  //########## シリアルポートのクリア　##########
  while(port.available()>0){
    int R=port.read();
  }
  //########## シリアルポートのクリア　##########
  
}









void draw(){
  int i=0;
  int graph_offset=0;
  

  if(Angle==16){//##########フェーズドアレイ結果を表示する##########
    delay(500);
    
    draw_1(graph_offset);
    
    output.flush();
    output.close();
    
    //########## CSVファイルの読み出し ##########
    String csvDataLine[] = loadStrings(savefile);
    for(i=1;i<=csvDataLine.length-1;i++){
      string=string +csvDataLine[i]+"\r\n";
    }
    //########## CSVファイルの読み出し ##########
    
    
    //########## クリップボードに入れる ##########
    Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
    StringSelection selection = new StringSelection(string);
    clipboard.setContents(selection, null);
    //########## クリップボードに入れる ##########
    Angle++;
    
  }else if(Angle>=47){
    Angle=1;
    Gamen=0;
    //exit();   
  }else if(Angle>=17){
     Gamen=1;
    //########## 表示させる時間を設定 ##########
     delay(100);
    //########## 表示させる時間を設定 ##########
    
    
    //########## ピーク検出の初期化 ##########
    int h=0;
    int hh=0;
    
    for(h=0;h<15;h++){
      for(hh=0;hh<10;hh++){
        kando_max2[h][hh]=0;
        kando_time2[h][hh]=0;
      }
    }
    //########## ピーク検出の初期化 ##########
    
    
    Angle++;
  }else{
    Gamen=0;
    background(150, 255, 255);//light blue　　背景色
  //background(#00FF80);
  
  
    //########### グラフプロット枠 ###########
    fill(255,255,255);//white
    //fill(255,255,230);//white
    strokeWeight(3);//線の太さ
    stroke(0, 0, 0);//線の色　white
    rect(sc_off,sc_off,screen_w,screen_h);//グラフ枠を作成
    
    stroke(160,160,160);//線色　gray
    strokeWeight(1);//線太さ
    
    //横の目盛り線
    for(i=1;i<=9;i++){
      line(sc_off,screen_h/10*i+sc_off,screen_w+sc_off,screen_h/10*i+sc_off);
    }
    
    
    //縦の目盛り線
    for(i=1;i<=9;i++){
      line(screen_w/10*i+sc_off,0+sc_off,screen_w/10*i+sc_off,screen_h+sc_off);
    }
  
  
    textSize(20);
    fill(0);//black
    textAlign(CENTER);
    for(i=1;i<=10;i++){
      text(100*i,screen_w/10*i+sc_off,screen_h+sc_off+20);
    }
    
    
    //縦の目盛り
    textSize(20);
    fill(0);//black
    textAlign(RIGHT); 
    for(i=0;i<=10;i++){
      text(Max_val/10*i,sc_off-10,screen_h/10*(10-i)+sc_off+5);
    }
      
    //########### グラフプロット枠 ###########
    
    
     //##########　タイトルの表示　##########
    fill(#ff0000);//red
    textAlign(LEFT);
    textSize(40);
    text("ULTRASONIC Sensor DEMO", 50, 35);
    //##########　タイトルの表示　##########
    
    //##########　スィープ角度の表示　##########
    fill(#ff0000);//red
    textAlign(LEFT);
    textSize(40);
    text(nf(Angle2[Angle-1],2, 1)+"°", 750, 35);//nf(Kyori2, 2, 1);
    //##########　スィープ角度の表示　##########
  
    //##########　X軸のタイトル表示　##########
    fill(0);//black
    textAlign(CENTER);
    textSize(20);
    text("Distance(mm)", screen_w/10*5+sc_off,screen_h+sc_off+50);
    //##########　X軸のタイトル表示　##########
    
    //##########　Y軸のタイトル表示　##########
    translate(38,320);//########## 軸の移動（相対座標）
    float rad = radians(-90);
    rotate(rad);//########## 軸の回転
    
    fill(0);//black
    textAlign(CENTER);
    textSize(20);
    text("Output(Count value)", 0,0); 
    
    rad = radians(90);
    rotate(rad);//########## 軸の回転
    translate(-38,-320);//########## 軸の移動（相対座標）
    //##########　Y軸のタイトル表示　##########
    
    
    
    
    //##########　STOP / START ボタンを表示する　##########
    if(stop_flag==0){
      fill(#FF8000);//white
      strokeWeight(1);//線の太さ
      stroke(#FF8000);//線の色　white
      rect(1200,640,50,30);//ボタンを作成
      fill(0);//black
      textAlign(CENTER);
      textSize(15);
      text("STOP", 1225, 660);
    }else{
      fill(#FFFF00);//yellow
      strokeWeight(1);//線の太さ
      stroke(#FFFF00);//線の色　yellow
      rect(1200,640,50,30);//ボタンを作成
      fill(0);//black
      textAlign(CENTER);
      textSize(15);
      text("START", 1225, 660);
    }
    
      fill(#7F00FF);//white
      strokeWeight(1);//線の太さ
      stroke(#7F00FF);//線の色　white
      rect(1000,640,50,30);//ボタンを作成
      fill(0);//black
      textAlign(CENTER);
      textSize(15);
      text("end", 1025, 660);
      
    //##########　STOP / START ボタンを表示する　##########
    
    
    
    
    //########### データを受け取る ##########
    //Angle=8;
    port.write(Angle); //マイコンにデータを送る
    delay(1);
    
    
    
    //########## 2400個分のデータが来るまで待つ ##########
    while(true){
      kazu = port.available();
      if(kazu==2400) break;
      delay(0);
    }
    //########## 2400個分のデータが来るまで待つ ##########
    
    //########## 1200個分のデータを受け取る ##########
    for(i=0;i<1200;i++){
      int highread= port.read();//データを取り込む
      int lowread= port.read();//データを取り込む
      data_table1[i]=highread<<8;
      data_table1[i]|=lowread;
    }
    //########## 1200個分のデータを受け取る ##########
  
  
    
    
    //########## 最初の50個のデータの平均値を出す ##########
    int avedata=0;
    
    for(i=1150;i<1200;i++){
      avedata+=data_table1[i];
    }
    avedata/=50;
    //########## 最初の50個のデータの平均値を出す ##########
    
    //########## 平均値に対する増減を絶対値にする ##########
    int getdata;
    for(i=0;i<Plot_num;i++){
      getdata=data_table1[i];
      getdata = abs(avedata-getdata);
      data_table2[i]=getdata;
    }
    //########## 平均値に対する増減を絶対値にする ##########
    
    //########## 平均化する ##########
    for(i=0;i<Plot_num-hekin;i++){
      avedata=0;
      for(t=0;t<hekin;t++){
        avedata+=data_table2[i+t];
      }
      avedata/=hekin;
      data_table2[i]=avedata;
    }
    //########## 平均化する ##########
  
  
    //########## ピークを検出する ##########
    int kando_max[]={0,0,0,0,0,0,0,0,0,0};
    int max_time[]={0,0,0,0,0,0,0,0,0,0};
    
    int kando=Sikiichi;
    int kando_time=0;
    int kando_num1=0;
    int kando_num2=0;
    int kando_flag=0;
    int p=0;
    
    for(i=0;i<Plot_num-hekin;i++){
      if(data_table2[i]<data_table2[i+10] && data_table2[i]>Sikiichi){//10個先のデータと比較して上に上がっている　かつ　閾値以上の場合
        kando_num1++;
        if(kando_num1==10){//連続で10回上に上がっている場合
          kando_flag=1;
          kando=data_table2[i];
        }
      }else{
        kando_num1=0;
      }
      
      if(kando_flag==1){//上に上がっているモードの時
        if(data_table2[i]>kando){
          kando=data_table2[i];
          kando_time=i;
          kando_num2=0;
        }else{
          kando_num2++;
          if(kando_num2==20){//20回連続でmax値より低い場合
            kando_max[p]=kando;
            max_time[p]=kando_time;      //peakを格納する
            
            p++;
            if(p==10) break;    //10個検出でやめる
            
            kando=Sikiichi;
            kando_num1=0;
            kando_flag=0;
            kando_num2=0;
          }
        }
      }
    }
    //########## ピークを検出する ##########
    
    
    graph_offset=hekin/2;      //50回平均の半分をずらして表示する
    
    
    //########## 各角度でのピーク強度と距離を配列にとる　##########
    int peak_strong=0;
    int peak_strong_pos=0;
    float peak_strong_pos2=0;
    int mm=0;
    
    for(i=0;i<10;i++){
      peak_strong_pos=max_time[i];
      if(peak_strong_pos==0) break;
      if(peak_strong_pos<=50) continue;
      
      //print(peak_strong_pos+",");
      
      peak_strong=0;
      for(p=0;p<100;p++){
        peak_strong+=data_table2[((peak_strong_pos-50)+p)];
      }
      
      kando_max2[(Angle-1)][mm]=peak_strong; 
      peak_strong_pos+=graph_offset;
      peak_strong_pos2=map(peak_strong_pos,0,1200,0,1000);//1200ピクセルは1000mm
      kando_time2[(Angle-1)][mm]=int(peak_strong_pos2);
       
      mm++;
      //print(Angle+",");
      //println(peak_strong);
      
    }
    //########## 各角度でのピーク強度と距離を配列にとる　##########
    
    
    
    
    
    
    
    
    //########## 距離を表示する ##########
    
    
    fill(0);//black
    textAlign(LEFT);
    textSize(30);
  
    stroke(#FFFF00);
    strokeWeight(2);
    
    float Kyori2=0;
    String Kyori="0";
    for(i=0;i<10;i++){
      Kyori2=max_time[i];
      if(Kyori2==0) break;
      
      line(Kyori2+sc_off+graph_offset,sc_off,Kyori2+sc_off+graph_offset,sc_off+screen_h);//peak位置に線を引く
      
      
      Kyori2+=graph_offset;
      Kyori2=map(Kyori2,0,1200,0,1000);//1200ピクセルは1000mm
      //kando_time2[(Angle-1)][i]=int(Kyori2);
      
      Kyori2/=10;
      //Kyori2+=20;
      //Kyori2*=5;
      //Kyori2*=340;
      //Kyori2/=10000;
      //Kyori2/=2;
      //Kyori2+=1;
      Kyori=nf(Kyori2, 2, 1);//format 2桁　＆　小数点1桁
      
      Kyori+="cm";
      text(Kyori, screen_w/20*2+i*120, screen_h/20*3);//距離を表示する
    }
    //########## 距離を表示する ##########
    
    
    
    
      
      
    //###########データの保存##########
    time1= millis();
    time1=(time1-time0);
    time2=time1;
    time2/=1000;
  
    mystr1 = str(time2);//保存データ
    for(i=1;i<Plot_num;i++){
      mystr1+=",";
      mystr1+=str(data_table1[i]);
    } 
    output.println(mystr1);//ファイルにデータを保存する 
    //########### データの保存 ##########
  
  
    //########## 生データの値を半分にする ##########
    for(i=0;i<Plot_num;i++){
      getdata=data_table1[i];
      getdata /= 2;
      data_table1[i]=getdata;
    }
    //########## 生データの値を半分にする ##########
    
    
    
    int x1=0;
    int x2=0;
    int y1=0;
    int y2=0;
    
    //########### 生データのグラフ表示 ##########
    x1=0;
    x2=0;
    y1=0;
    y2=0;
    
    stroke(#0000FF);
    strokeWeight(1);
    for(i=0;i<(Plot_num-1);i++){
      x2 = x1 + screen_w / Plot_num;
      y1 = data_table1[i];
      y1 = y1 - Min_val;
      y1 = y1 * screen_h;
      y1 = y1 / (Max_val - Min_val);
      y1 = screen_h - y1;
      
      if(y1>(screen_h)) y1= screen_h;
      if(y1<0) y1=0;
      
      y2 = data_table1[i + 1];
      y2 = y2 - Min_val;
      y2 = y2 * screen_h;
      y2 = y2 / (Max_val - Min_val);
      y2 = screen_h - y2;
      
      if(y2>(screen_h)) y2= screen_h;
      if(y2<0) y2=0;
      
      line(x1+sc_off,y1+sc_off,x2+sc_off,y2+sc_off);
      x1 = x1 + screen_w / Plot_num;
    }
    //########### 生データのグラフ表示 ##########
    
  
    
    //########### 加工後のグラフ表示 ########## 
    x1=graph_offset;
    x2=0;
    y1=0;
    y2=0;
    
    stroke(#FF0000);
    strokeWeight(1);
  
    for(i=0;i<(Plot_num-(hekin+1));i++){
      x2 = x1 + screen_w / Plot_num;
      y1 = data_table2[i];
      y1 = y1 - Min_val;
      y1 = y1 * screen_h;
      y1 = y1 / (Max_val - Min_val);
      y1 = screen_h - y1;
      
      if(y1>(screen_h)) y1= screen_h;
      if(y1<0) y1=0;
      
      y2 = data_table2[i + 1];
      y2 = y2 - Min_val;
      y2 = y2 * screen_h;
      y2 = y2 / (Max_val - Min_val);
      y2 = screen_h - y2;
      
      if(y2>(screen_h)) y2= screen_h;
      if(y2<0) y2=0;
      
      line(x1+sc_off,y1+sc_off,x2+sc_off,y2+sc_off);
      x1 = x1 + screen_w / Plot_num;
    }
    //########### 加工後のグラフ表示 ##########
    
    //##########　グラフを表示する　##########
    
    
  
      
    Angle++;
  
    
    
    //########## 終了　&　データの保存 ##########
    if(time2>endcyc){
      output.flush();
      output.close();
      exit();
    }
    //########## 終了　&　データの保存 ##########
    
    delay(delaytime);//休む
  }
}






boolean overRect(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) { 
      return true;
  } else {
    return false;
  }
}



void mouseClicked(){
  if(overRect(1200,630,50,30)){
    if(stop_flag==0){
      stop_flag=1;

      fill(#FFFF00);//yellow
      strokeWeight(1);//線の太さ
      stroke(#FFFF00);//線の色　yellow
      rect(1200,640,50,30);//ボタンを作成
      fill(0);//black
      textAlign(CENTER);
      textSize(15);
      text("START", 1225, 660);
      
      if(Gamen==1) Angle=1;
      noLoop();
    }else if(stop_flag==1){
      stop_flag=0;

      fill(#FF8000);//white
      strokeWeight(1);//線の太さ
      stroke(#FF8000);//線の色　white
      rect(1200,640,50,30);//ボタンを作成
      fill(0);//black
      textAlign(CENTER);
      textSize(15);
      text("STOP", 1225, 660);
    
      loop();
    }
  }else if(overRect(1000,640,50,30)){
    exit(); 
  }
}  



void draw_1(int graph_offset){//フェーズドアレイ結果の表示
  Gamen=1;///stopボタン用
  
  //##########　背景色 ##########
  background(#FFFFFF);//　　背景色
  //background(#00FF80);
  //##########　背景色 ##########
  
  //##########　タイトル ##########
  textAlign(LEFT);
  textFont(myFont);
  text("フェーズドアレイ結果", 60, 35);
  //##########　タイトル ##########
  

  //##########　STOP / START ボタンを表示する　##########
  if(stop_flag==0){
    fill(#FF8000);//white
    strokeWeight(1);//線の太さ
    stroke(#FF8000);//線の色　white
    rect(1200,640,50,30);//ボタンを作成
    fill(0);//black
    textAlign(CENTER);
    textSize(15);
    text("STOP", 1225, 660);
  }else{
    fill(#FFFF00);//yellow
    strokeWeight(1);//線の太さ
    stroke(#FFFF00);//線の色　yellow
    rect(1200,640,50,30);//ボタンを作成
    fill(0);//black
    textAlign(CENTER);
    textSize(15);
    text("START", 1225, 660);
  }
  
  fill(#7F00FF);//white
  strokeWeight(1);//線の太さ
  stroke(#7F00FF);//線の色　white
  rect(1000,640,50,30);//ボタンを作成
  fill(0);//black
  textAlign(CENTER);
  textSize(15);
  text("end", 1025, 660);
  //##########　STOP / START ボタンを表示する　##########
    
  
  
  int m=0;
  int n=0;
  
  float angle2[]={60.8,64.4,68.2,72.3,76.5,80.9,85.5,90,94.6,99.1,103.5,107.7,111.8,115.6,119.2};////sweep角度
  translate(sc_off+screen_w/2,50);//########## 軸の移動（相対座標）　　中心位置へ移動
  //ellipse(0,0,5,5);
  
  stroke(160,160,160);//線色　gray
  strokeWeight(1);//線太さ
  
  float[] kyori4 = new float[30];  //########## 同じ距離くらいのピークの最大強度を入れる
  String[] kyori5 = new String[30];//########## 同じ距離くらいのピークの角度と順番を入れる　　[角度‗順番]
  
  for(m=0;m<30;m++){//配列の初期化
    kyori4[m]=0;
    kyori5[m]="";
  }
  
  //########### 円弧で距離の目盛りを作る ##########
  for(m=1;m<=10;m++){
    noFill();
    arc(0, 0, map(100*m*2,0,1000,0,600), map(100*m*2,0,1000,0,600), radians(55), radians(125));////円弧を描く
    fill(1);
    
    rotate(radians(55));
    textAlign(CENTER);
    textSize(15);
    text(m*100,map(100*m,0,1000,0,600),-20);//距離のメーターを書く
    rotate(radians(-55));
  } 
  fill(1);
  //########### 円弧で距離の目盛りを作る ##########
  
  
  
  float[] kyori3 = new float[30];
  float rad =0;
  int kyori_cnt=0;
 

  
  for(m=0;m<15;m++){
    
    //########## 角度の目盛りを作る ##########
    rotate(radians(55+5*m));//角度
    fill(1);
    line(0,0,map(1200,0,1200,0,600),0);

    textAlign(CENTER);
    textSize(15);
    text((-35+5*m),map(1200,0,1200,0,600)+10,0);
    rotate(radians(-55-5*m));
    
    
    rad = radians(angle2[m]);
    rotate(rad);//########## 軸の回転
    //########## 角度の目盛りを作る ##########
    
    
    
    //########## プロットする ##########
    for(i=0;i<10;i++){
      long getx = kando_time2[m][i];
      long getB = kando_max2[m][i];
      if(getx==0) break;
      
      //getx+=graph_offset;
      
      float getxx=map(getx,0,1000,0,600);
      float getBB=map(getB,0,20000,0,10);
      
      if(getxx<100) continue;
      
      //println(getxx);
      
      if(kyori_cnt==0){ //<>//
        kyori3[0]=getxx;
        kyori4[0]=getBB;
        kyori5[0]=m+"_"+i;
        println(m+"_"+i);
        fill(graph_color[0]);
        kyori_cnt++;
      }else{
        int A_flag=0;
        for(n=0;n<kyori_cnt;n++){
          if(abs(kyori3[n]-getxx)<25){
            fill(graph_color[n]);
            A_flag=1;
            
            kyori3[n]=getxx;
            if(kyori4[n]<getBB){
              kyori4[n]=getBB;
              kyori5[n]=m+"_"+i;
              println(m+"_"+i);
            }
            break;
          }
        }
        if(A_flag==0){
          kyori3[kyori_cnt]=getxx;
          kyori4[kyori_cnt]=getBB;
          kyori5[kyori_cnt]=m+"_"+i;
          println(m+"_"+i);
        
          fill(graph_color[kyori_cnt]);
          kyori_cnt++;
        }
      }
      
      ellipse(getxx,0,getBB,getBB);//////プロット
    }
    delay(1);
    
    rotate(rad*-1);//########## 軸の回転
  }
  //########## プロットする ##########
  
  
  //##########　最大位置に丸をつける ##########
  int s=0;
  float maxpos=0; //<>//
  
  
  for(s=0;s<30;s++){
    maxpos=kyori4[s];
    
    if(maxpos==0) break;
    
    String getdata=kyori5[s];
    int[] maxpos3 = int(getdata.split("_"));
    
    m=maxpos3[0];
    i=maxpos3[1];
    
    rad = radians(angle2[m]);
    rotate(rad);//########## 軸の回転

    long getx1 = kando_time2[m][i];
    long getB1 = kando_max2[m][i];
    
    float getxx1=map(getx1,0,1000,0,600);
    float getBB1=map(getB1,0,20000,0,10);
    
    noFill();
    stroke(255,0,0);
    strokeWeight(2);//線の太さ
    ellipse(getxx1,0,getBB1+2,getBB1+2);
    //rect(getxx1-5, -5, 10, 10);
    fill(1);
    
    rotate(rad*-1);//########## 軸の回転
    
  }
  //##########　最大位置に丸をつける ##########
  
  translate((sc_off+screen_w/2)*-1,sc_off*-1);//########## 軸の移動（相対座標）
}





//void serialEvent(Serial port)
//{
//  // シリアルポートからデータを受け取ったら
//  if (port.available()==CH*2){
//    for(int i=0;i<CH;i++){
//      int highread= port.read();//データを取り込む
//      int lowread= port.read();//データを取り込む
//      data1[i]=highread<<8;
//      data1[i]|=lowread;
//    }
//    read_flag=1;
//  }
//}
