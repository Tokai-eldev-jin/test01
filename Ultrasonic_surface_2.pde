import processing.serial.*;
import java.io.FileWriter;
import controlP5.*;

ControlP5 cp5;

//########## クリップボード ##########
//import java.awt.datatransfer.StringSelection;
//import java.awt.Toolkit;
//import java.awt.datatransfer.Clipboard;
//########## クリップボード ##########

String string="";

Serial port;
PrintWriter output;///File操作宣言



//########## 計測設定 ##########
String COM="COM17";
long endcyc=600000;//終了する時間（秒）
int delaytime=1;//delayタイム（ms）
int Max_val = 2000;//最大値設定
int Min_val = 0;//最小値設定
String savefile = "data/save.csv";
int Plot_num=735*5;//グラフのプロット数
int Sikiichi=100;//peak検出の閾値
//########## 計測設定 ##########






int[] graph_color = new int[21];
//int graph_color[] = {#FF0000,#FF8000,#FFFF00,#80FF00,#00FF00,#00FFFF,#00FF80,#0000FF,#7F00FF,#FF00FF};//こっちでもいい

int[] data_table1 = new int[Plot_num];//生データグラフ用
int[] data_table2 = new int[Plot_num];//加工データグラフ用


int t = 0;
int i = 0;
int ii = 0;
int time0=0;
int time1=0;
float time2=0;


int screen_w = 735;  //グラフの表示サイズ　横
int screen_h = 420;  //グラフの表示サイズ　縦
int sc_offx=120;        //グラフの画面上のオフセット
int sc_offy=120;        //グラフの画面上のオフセット


String mystr1;      //CSV保存用の変数
int kazu=0;//シリアル通信のデータ受信　バイト数
int stop_flag=0;//start/stopの切り替え

PFont myFont;
PFont myFont2;
PFont myFont3;
PFont myFont4;
PFont myFont5;

byte focus_flag=0;

int end_button_X=830;
int stop_button_X=900;
int page_button_X=600;
int mode_button_X=400;
int button_Y=10;
int buttom_w=50;
int buttom_h=25;

int page=0;
int mode=0;



void setup() {
  //外枠
  //size(displayWidth, displayHeight,JAVA2D);//ソフトの表示サイズ　　　リテラルのみ
  size(960,640,JAVA2D);//ソフトの表示サイズ　　　リテラルのみ
  //fullScreen();
  
 
  //########## Graphカラーの設定 ##########
  graph_color[0]=#FF0000;//red
  graph_color[1]=#FF8000;//orange
  graph_color[2]=#FFFF00;//yellow
  graph_color[3]=#80FF00;//light green
  graph_color[4]=#00FF00;//green
  graph_color[5]=#00FFFF;//light blue
  graph_color[6]=#00FF80;//dark blue
  graph_color[7]=#0000FF;//blue
  graph_color[8]=#7F00FF;//purple
  graph_color[9]=#FF00FF;//pink
  graph_color[10]=#000080;//navy
  graph_color[11]=#008080;//teal
  graph_color[12]=#00FF00;//lime
  graph_color[13]=#00FFFF;//aqua
  graph_color[14]=#FF00FF;//fuchsia
  graph_color[15]=#808000;//olive
  graph_color[16]=#800000;//maroon
  graph_color[17]=#808080;//gray
  graph_color[18]=#C0C0C0;//silver
  graph_color[19]=#FFFFFF;//while
  graph_color[20]=#000000;//black 
  //########## Graphカラーの設定 ##########
  
  
  //########## フォント設定 ##########
  myFont = createFont("Dialog.bold", 40);
  myFont2 = createFont("Dialog.bold", 20);
  myFont3 = createFont("Dialog.bold", 12);
  myFont4 = createFont("Dialog.bold", 30);
  myFont5 = createFont("Dialog.bold", 16);
  //########## フォント設定 ##########
  
  
  //##########　感度入力BOX ##########
  cp5 = new ControlP5(this);
  
  cp5.addTextfield("Kando")
   .setFont(myFont3)
   .setColorBackground(#FFFFFF) 
   .setColorCaptionLabel(#000000) 
   .setPosition(700,5)
   .setSize(50,25)
   .setCaptionLabel("感度")
   .setFocus(false)
   .setColor(color(255,0,0))
   .setText(str(Sikiichi))
   .setColorActive(color(255,0,255)) 
   ;
   //##########　感度入力BOX ##########
  
  
  
  //font = createFont("游ゴジック", 24);
  //port = new Serial(this, Serial.list()[1], 115200);//ポートリストの何個目か？
  port = new Serial(this, COM, 115200);//シリアル通信設定
  
  
  background(200, 255, 255);//light blue　　背景色
  
  
  //########### グラフプロットデータの初期化 ###########
  for(i=0;i<Plot_num;i++){
    data_table1[i] = 0;
  }
  //########### グラフプロットデータの初期化 ###########
  
  
  //########## データの保存ファイル　##########
  //output = createWriter(savefile);//データの保存ファイルを開く
  //String memo = "time";
  //memo=memo+",CH1";
  //output.println(memo);
  //########## データの保存ファイル　##########
  
  
  time0= millis();//開始時間計測
  delay(1000);          //Arduinoが立ち上がるまで待つ（これがないと通信に失敗する）
  
  //########## シリアルポートのクリア　##########
  while(port.available()>0){
    int R=port.read();
  }
  //########## シリアルポートのクリア　##########
  
}









void draw() {
  int i=0;
  int m=0;
  int n=0;
  
  textFont(myFont2);
  background(150, 255, 255);//light blue　　背景色
  //background(#00FF80);

  
   //##########　感度のBOX値を読む ##########
   if(cp5.get(Textfield.class,"Kando").isFocus()){
     focus_flag=1;
   }else{
     focus_flag=0;
   }

   if(focus_flag==0){
     Sikiichi=int(cp5.get(Textfield.class,"Kando").getText()); 
     println(Sikiichi);
   }
   //##########　感度のBOX値を読む ##########
   
   
   
  if(mode==0){    //########## 1m表示の時 ##########
    sc_offy=120;
    screen_h=420;
    //########### グラフプロット枠 ###########
    fill(255,255,255);//white
    //fill(255,255,230);//white
    strokeWeight(3);//線の太さ
    stroke(0, 0, 0);//線の色　white
    rect(sc_offx,sc_offy,screen_w,screen_h);//グラフ枠を作成
  
    stroke(160,160,160);//線色　gray
    strokeWeight(1);//線太さ
    
    //横の目盛り線
    for(i=1;i<=9;i++){
      line(sc_offx,screen_h/10*i+sc_offy,screen_w+sc_offx,screen_h/10*i+sc_offy);
    }
    
    //縦の目盛り線
    for(i=1;i<10;i++){
      line(screen_w/10*i+sc_offx,0+sc_offy,screen_w/10*i+sc_offx,screen_h+sc_offy);
    }
   
    
    //横の目盛り
    textFont(myFont2);
    fill(0);//black
    textAlign(CENTER);
    
    for(i=0;i<=10;i++){
      text(1000*page+100*i,screen_w/10*i+sc_offx,screen_h+sc_offy+20);
    }
     
    //縦の目盛り
    textFont(myFont2);
    fill(0);//black
    textAlign(RIGHT); 
    for(i=0;i<=10;i++){
      text(Max_val/10*i,sc_offx-10,screen_h/10*(10-i)+sc_offy+5);
    }
    //########### グラフプロット枠 ###########
    
    
    
     //##########　タイトルの表示　##########
    fill(#ff0000);//red
    textAlign(LEFT);
    textFont(myFont);//サイズ40
    text("超音波センサデモ", 10, 40);
    //text("Ultrasonic Sensor DEMO", 50, 30);
    //##########　タイトルの表示　##########
  
    //##########　X軸のタイトル表示　##########
    fill(0);//black
    textAlign(CENTER);
    textSize(20);
    text("Distance(mm)", screen_w/10*5+sc_offx,screen_h+sc_offy+50);
    //##########　X軸のタイトル表示　##########
    
    //##########　Y軸のタイトル表示　##########
    translate(40,300);//########## 軸の移動（相対座標）
    float rad = radians(-90);
    rotate(rad);//########## 軸の回転  
    fill(0);//black
    textAlign(CENTER);
    textFont(myFont2);
    text("Output (カウント値)", 0,0);
    
    rad = radians(90);
    rotate(rad);//########## 軸の回転
    translate(-40,-300);//########## 軸の移動（相対座標）
    //##########　Y軸のタイトル表示　##########
  




  }else{    //########## 3m表示の時 ##########
    sc_offy=80;
    screen_h=170;
    
    //########### グラフプロット枠 ###########
    fill(255,255,255);//white
    strokeWeight(3);//線の太さ
    stroke(0, 0, 0);//線の色　white
    
    rect(sc_offx,sc_offy+screen_h*0,screen_w,screen_h);//グラフ枠を作成
    rect(sc_offx,sc_offy+screen_h*1,screen_w,screen_h);//グラフ枠を作成
    rect(sc_offx,sc_offy+screen_h*2,screen_w,screen_h);//グラフ枠を作成
  
    stroke(160,160,160);//線色　gray
    strokeWeight(1);//線太さ
    
    //横の目盛り線
    for(i=1;i<=9;i++){
      line(sc_offx,screen_h/10*i+sc_offy,screen_w+sc_offx,screen_h/10*i+sc_offy);
    }
    
    //縦の目盛り線
    for(i=1;i<10;i++){
      line(screen_w/10*i+sc_offx,0+sc_offy,screen_w/10*i+sc_offx,screen_h+sc_offy);
    }
   
    
    //横の目盛り
    textFont(myFont5);
    fill(0);//black
    textAlign(CENTER);
    
    for(i=1;i<=10;i++){
      text(1000*0+100*i,screen_w/10*i+sc_offx,screen_h+sc_offy+15);
    }
     
    //縦の目盛り
    textFont(myFont5);
    fill(0);//black
    textAlign(RIGHT); 
    for(i=0;i<=10;i++){
      text(Max_val/10*i,sc_offx-10,screen_h/10*(10-i)+sc_offy+5);
    }


    //##########2段目##########
    //横の目盛り線
    for(i=1;i<=9;i++){
      line(sc_offx,screen_h/10*i+sc_offy+screen_h,screen_w+sc_offx,screen_h/10*i+sc_offy+screen_h);
    }
    
    //縦の目盛り線
    for(i=1;i<10;i++){
      line(screen_w/10*i+sc_offx,sc_offy+screen_h,screen_w/10*i+sc_offx,screen_h+sc_offy+screen_h);
    }
   
    
    //横の目盛り
    textFont(myFont5);
    fill(0);//black
    textAlign(CENTER);
    
    for(i=1;i<=10;i++){
      text(1000*1+100*i,screen_w/10*i+sc_offx,screen_h+sc_offy+screen_h+15);
    }
     
    //縦の目盛り
    textFont(myFont5);
    fill(0);//black
    textAlign(RIGHT); 
    for(i=0;i<=10;i++){
      text(Max_val/10*i,sc_offx-10,screen_h/10*(10-i)+sc_offy+screen_h+5);
    }

   

    //##########3段目##########
    //横の目盛り線
    for(i=1;i<=9;i++){
      line(sc_offx,screen_h/10*i+sc_offy+screen_h*2,screen_w+sc_offx,screen_h/10*i+sc_offy+screen_h*2);
    }
    
    //縦の目盛り線
    for(i=1;i<10;i++){
      line(screen_w/10*i+sc_offx,sc_offy+screen_h*2,screen_w/10*i+sc_offx,screen_h+sc_offy+screen_h*2);
    }
   
    
    //横の目盛り
    textFont(myFont5);
    fill(0);//black
    textAlign(CENTER);
    
    for(i=0;i<=10;i++){
      text(1000*2+100*i,screen_w/10*i+sc_offx,screen_h+sc_offy+screen_h*2+15);
    }
     
    //縦の目盛り
    textFont(myFont5);
    fill(0);//black
    textAlign(RIGHT); 
    for(i=0;i<=10;i++){
      text(Max_val/10*i,sc_offx-10,screen_h/10*(10-i)+sc_offy+screen_h*2+5);
    }
    //########### グラフプロット枠 ###########
    
    
    
     //##########　タイトルの表示　##########
    fill(#ff0000);//red
    textAlign(LEFT);
    textFont(myFont4);//サイズ30
    text("超音波センサデモ", 10, 30);
    //text("Ultrasonic Sensor DEMO", 50, 30);
    //##########　タイトルの表示　##########
  
    //##########　X軸のタイトル表示　##########
    fill(0);//black
    textAlign(CENTER);
    textSize(20);
    text("Distance(mm)", screen_w/10*5+sc_offx,screen_h*3+sc_offy+40);
    //##########　X軸のタイトル表示　##########
    
    //##########　Y軸のタイトル表示　##########
    translate(40,300);//########## 軸の移動（相対座標）
    float rad = radians(-90);
    rotate(rad);//########## 軸の回転  
    fill(0);//black
    textAlign(CENTER);
    textFont(myFont2);
    text("Output (カウント値)", 0,0);
    
    rad = radians(90);
    rotate(rad);//########## 軸の回転
    translate(-40,-300);//########## 軸の移動（相対座標）
    //##########　Y軸のタイトル表示　##########    
    
  }
  
  


  //##########　STOP / START ボタンを表示する　##########
  if(stop_flag==0){
    fill(#FF8000);//white
    strokeWeight(1);//線の太さ
    stroke(#FF8000);//線の色　white
    rect(stop_button_X,button_Y,buttom_w,buttom_h);//ボタンを作成
    fill(0);//black
    textAlign(CENTER);
    textSize(15);
    text("STOP",stop_button_X+25, button_Y+18);
  }else{
    fill(#FFFF00);//yellow
    strokeWeight(1);//線の太さ
    stroke(#FFFF00);//線の色　yellow
    rect(stop_button_X,button_Y,buttom_w,buttom_h);//ボタンを作成
    fill(0);//black
    textAlign(CENTER);
    textSize(15);
    text("START",stop_button_X+25, button_Y+18);
  }



  //########## mode切り替えボタンの作成 ##########
  if(mode==0){//########## 1m表示の時 ##########
    fill(graph_color[14]);//white
    strokeWeight(1);//線の太さ
    stroke(graph_color[14]);//線の色　white
    rect(mode_button_X,button_Y,buttom_w,buttom_h);//ボタンを作成
    fill(0);//black
    textAlign(CENTER);
    textFont(myFont3);
    text("mode1",mode_button_X+25, button_Y+17);
  }else{//########## 3m表示の時 ##########
    fill(graph_color[14]);//yellow
    strokeWeight(1);//線の太さ
    stroke(graph_color[14]);//線の色　yellow
    rect(mode_button_X,button_Y,buttom_w,buttom_h);//ボタンを作成
    fill(0);//black
    textAlign(CENTER);
    textFont(myFont3);
    text("mode2",mode_button_X+25, button_Y+17);
  }
  //########## mode切り替えボタンの作成 ##########
  
  
  //########## ENDボタンの作成 ##########
  fill(#00FF00);//yellow
  strokeWeight(1);//線の太さ
  stroke(#00FF00);//線の色　yellow
  rect(end_button_X,button_Y,buttom_w,buttom_h);//ボタンを作成
  fill(0);//black
  textAlign(CENTER);
  textSize(15);
  text("END",end_button_X+25,button_Y+18);
  //########## ENDボタンの作成 ##########

  
  if(mode==0){    //########## 1m表示の時 ##########
    //########## pageボタンの作成 ##########
    fill(graph_color[2]);//yellow
    strokeWeight(1);//線の太さ
    stroke(graph_color[8]);//線の色　yellow
    rect(page_button_X,button_Y,20,22);//ボタンを作成
    fill(0);//black
    textAlign(CENTER);
    textSize(30);
    text("◀",page_button_X+10, button_Y+22);
  
    fill(graph_color[2]);//yellow
    strokeWeight(1);//線の太さ
    stroke(graph_color[8]);//線の色　yellow
    rect(page_button_X+30,button_Y,20,22);//ボタンを作成
    fill(0);//black
    textAlign(CENTER);
    textSize(30);
    text("▶",page_button_X+30+10, button_Y+22);
    //########## pageボタンの作成 ##########
  }
  //##########　STOP / START ボタンを表示する　##########
  
  
  
  
  //########### 閾値をを送る ##########
  int Sikiichi2=Sikiichi>>>8;
  port.write((byte)Sikiichi2); //マイコンにデータを送る
  port.write((byte)Sikiichi); //マイコンにデータを送る
  //########### 閾値をを送る ##########
 
  
  //##########マイコンから計測完了を受け取る ##########
  while(true){
      delay(1);
      if(port.available()==1){
        int rrr=port.read();
        break;
      }
  }
  //##########マイコンから計測完了を受け取る ##########
  
  
  //########## データを受け取る ##########
  n=0;
  for(m=0;m<5;m++){
    port.write(1); 
    delay(1);
    
    //########## データが来るまで待つ ##########
    while(true){
      delay(1);
      kazu = port.available();
      if(kazu==Plot_num*2/5) break; //<>//
    }
    //########## データが来るまで待つ ##########
    
    //########## データを受け取る ##########
    for(i=0;i<Plot_num/5;i++){
      int highread= port.read();//データを取り込む
      int lowread= port.read();//データを取り込む
      data_table1[n]=highread<<8;
      data_table1[n]|=lowread;
      
      n++;
    }
    //########## データを受け取る ##########
  }
  //########## データを受け取る ##########

  
  //########## 最初の50個のデータの平均値を出す ##########
  //上段
  int avedata=0;
  for(i=0;i<50;i++){
    avedata+=data_table1[(Plot_num-50)+i];
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
  //上段
  for(i=0;i<Plot_num-50;i++){
    avedata=0;
    for(t=0;t<50;t++){
      avedata+=data_table2[i+t];
    }
    avedata/=50;
    data_table2[i]=avedata;
  } 
  //########## 平均化する ##########


  //########## ピークを検出する ##########
  int kando_max[]={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
  int max_time[]={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
  
  int kando0=Sikiichi;
  int kando=Sikiichi;
  int kando_time=0;
  int kando_num1=0;
  int kando_num2=0;
  int kando_flag=0;
  int p=0;
  
  for(i=0;i<Plot_num-50;i++){
    if((data_table2[i])<data_table2[i+10] && data_table2[i]>Sikiichi){//10個先のデータと比較して上に上がっている　かつ　閾値以上の場合
      kando_num1++;
      if(kando_num1==10){//連続で10回上に上がっている場合
        kando_flag=1;
        kando=data_table2[i];
      }
    }else{
      kando_num1=0;
    }
    
    if(kando_flag==1){//上に上がっているモードの時
      kando0=data_table2[i];
      
      byte d=0;
      byte c=0;
      for(c=0;c<10;c++){
        if(kando0<data_table2[i+c]){
          kando0=data_table2[i+c];
          d=c;
        }
      } 
      
      if(kando0>kando){
        kando_time=i+d;
        kando_num2=0;
        kando=kando0;
      }else{
        kando_num2++;
        if(kando_num2==20){//20回連続でmax値より低い場合
          kando_max[p]=kando;
          max_time[p]=kando_time;      //peakを格納する
          
          p++;
          if(p==20) break;    //10個検出でやめる
          
          kando=Sikiichi;
          kando_num1=0;
          kando_flag=0;
          kando_num2=0;
        }
      }
    }
  }
  //########## ピークを検出する ##########
  
  
  //########## 距離を表示する ##########
  int graph_offset=50/2;      //50回平均の半分をずらして表示する
  
  fill(0);//black
  textAlign(LEFT);
  textSize(30);

  stroke(graph_color[9]);
  strokeWeight(2);
  
  float Kyori2=0;
  String Kyori="0";
  
  for(i=0;i<20;i++){
    Kyori2=max_time[i];
    if(Kyori2==0) break;
    
    if(mode==0){    //########## 1m表示の時 ##########
      if((Kyori2+sc_offx+graph_offset-Plot_num/5*page)<(sc_offx+screen_w)){
        if((Kyori2+sc_offx+graph_offset-Plot_num/5*page)>(sc_offx)){
          line(Kyori2+sc_offx+graph_offset-Plot_num/5*page,sc_offy,Kyori2+sc_offx+graph_offset-Plot_num/5*page,sc_offy+screen_h);//peak位置に線を引く
        }
      }
    }else{        //########## 3m表示の時 ##########
      if(Kyori2+sc_offx+graph_offset<(sc_offx+screen_w)){
        line(Kyori2+sc_offx+graph_offset,sc_offy,Kyori2+sc_offx+graph_offset,sc_offy+screen_h);//peak位置に線を引く
      }else if(Kyori2+sc_offx+graph_offset<(sc_offx+screen_w*2)){
        line(Kyori2+sc_offx+graph_offset-screen_w*1,sc_offy+screen_h*1,Kyori2+sc_offx+graph_offset-screen_w*1,sc_offy+screen_h*1+screen_h);//peak位置に線を引く
      }else if(Kyori2+sc_offx+graph_offset<(sc_offx+screen_w*3)){
        line(Kyori2+sc_offx+graph_offset-screen_w*2,sc_offy+screen_h*2,Kyori2+sc_offx+graph_offset-screen_w*2,sc_offy+screen_h*2+screen_h);//peak位置に線を引く
      }
    }
    
    if(i>5) continue;
    
    Kyori2+=graph_offset;
    Kyori2=map(Kyori2,0,735*5,0,5000);//735ピクセルは1000mm
    Kyori2/=10;
    String[] Kyori3 = splitTokens(str(Kyori2),".");
    
    Kyori3[0]+="cm";
    fill(graph_color[1]);//red
    textFont(myFont4);
    if(mode==0) text(Kyori3[0], 50+i*105, 80);//距離を表示する
    if(mode==1) text(Kyori3[0], 50+i*105, 60);//距離を表示する
  }
  //########## 距離を表示する ##########
  
    
  //###########データの保存##########
  //time1= millis();
  //time1=(time1-time0);
  //time2=time1;
  //time2/=1000;

  //mystr1 = str(time2);//保存データ
  //for(i=1;i<Plot_num;i++){
  //  mystr1+=",";
  //  mystr1+=str(data_table1[i]);
  //} 
  //output.println(mystr1);//ファイルにデータを保存する 
  //########### データの保存 ##########


  //########## 生データの値を半分にする ##########
  for(i=0;i<Plot_num;i++){
    getdata=data_table1[i];
    getdata /= 2;
    data_table1[i]=getdata;
  }
  //########## 生データの値を半分にする ##########
  
  
  
  
   //########### 生データのグラフ表示 ##########
  int x1=0;
  int x2=0;
  int y1=0;
  int y2=0;
  
  if(mode==0){      //########## 1m表示の時 ##########
    x1=0;
    x2=0;
    y1=0;
    y2=0;
    
    stroke(graph_color[7]);
    strokeWeight(1);
    for(i=735*page;i<(735*(page+1)-1);i++){
      x2 = x1 + 1;
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
      
      line(x1+sc_offx,y1+sc_offy,x2+sc_offx,y2+sc_offy);
      x1 = x1 + 1;
    }
  }else{      //########## 3m表示の時 ##########
  
    //########### 1列目 ##########
    x1=0;
    x2=0;
    y1=0;
    y2=0;
    
    stroke(graph_color[7]);
    strokeWeight(1);
    for(i=735*0;i<(735*(0+1)-1);i++){
      x2 = x1 + 1;
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
      
      line(x1+sc_offx,y1+sc_offy,x2+sc_offx,y2+sc_offy);
      x1 = x1 + 1;
    }
    
    
    //########### 2列目 ##########
    x1=0;
    x2=0;
    y1=0;
    y2=0;
    
    stroke(graph_color[7]);
    strokeWeight(1);
    for(i=735*1;i<(735*(1+1)-1);i++){
      x2 = x1 + 1;
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
      
      line(x1+sc_offx,y1+sc_offy+screen_h*1,x2+sc_offx,y2+sc_offy+screen_h*1);
      x1 = x1 + 1;
    }
    

    //########### 3列目 ##########
    x1=0;
    x2=0;
    y1=0;
    y2=0;
    
    stroke(graph_color[7]);
    strokeWeight(1);
    for(i=735*2;i<(735*(1+2)-1);i++){
      x2 = x1 + 1;
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
      
      line(x1+sc_offx,y1+sc_offy+screen_h*2,x2+sc_offx,y2+sc_offy+screen_h*2);
      x1 = x1 + 1;
    }
  }

  //########### 生データのグラフ表示 ##########
  




  
  //########### 加工後のグラフ表示 ########## 
  if(mode==0){      //########## 1m表示の時 ##########
    x2=0;
    y1=0;
    y2=0;
    
    stroke(graph_color[0]);
    strokeWeight(1);
    if(page==0){
      x1=graph_offset;
      for(i=735*page;i<(735*(page+1)-1)-graph_offset;i++){
        x2 = x1 + 1;
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
        
        line(x1+sc_offx,y1+sc_offy,x2+sc_offx,y2+sc_offy);
        x1 = x1 + 1;
      }  
    }else if(page!=4){
      x1=0;
      for(i=735*page-graph_offset;i<(735*(page+1)-graph_offset-1);i++){
        x2 = x1 + 1;
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
        
        line(x1+sc_offx,y1+sc_offy,x2+sc_offx,y2+sc_offy);
        x1 = x1 + 1;
      }
    }else{
      x1=0;
      for(i=735*page-graph_offset;i<(735*(page+1)-graph_offset-51);i++){
        x2 = x1 + 1;
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
        
        line(x1+sc_offx,y1+sc_offy,x2+sc_offx,y2+sc_offy);
        x1 = x1 + 1;
      }  
    }
  }else{      //########## 3m表示の時 ##########
    
    //########### 1列目 ##########
    x2=0;
    y1=0;
    y2=0;
    
    stroke(graph_color[0]);
    strokeWeight(1);
    x1=graph_offset;
    
    for(i=735*0;i<(735*(0+1)-1)-graph_offset;i++){
      x2 = x1 + 1;
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
      
      line(x1+sc_offx,y1+sc_offy,x2+sc_offx,y2+sc_offy);
      x1 = x1 + 1;
    }


    //########### 2列目 ##########
    x1=0;
    x2=0;
    y1=0;
    y2=0;
    
    stroke(graph_color[0]);
    strokeWeight(1);
    
    for(i=735*1-graph_offset;i<(735*(1+1)-graph_offset-1);i++){
      x2 = x1 + 1;
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
      
      line(x1+sc_offx,y1+sc_offy+screen_h*1,x2+sc_offx,y2+sc_offy+screen_h*1);
      x1 = x1 + 1;
    }


    //########### 3列目 ##########
    x1=0;
    x2=0;
    y1=0;
    y2=0;
    
    stroke(graph_color[0]);
    strokeWeight(1);
 
    for(i=735*2-graph_offset;i<(735*(2+1)-graph_offset-51);i++){
      x2 = x1 + 1;
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
      
      line(x1+sc_offx,y1+sc_offy+screen_h*2,x2+sc_offx,y2+sc_offy+screen_h*2);
      x1 = x1 + 1;
    }
      
  }
  //########### 加工後のグラフ表示 ##########
  
  //##########　グラフを表示する　##########
  
  

    
    
  
  
  //########## 終了　&　データの保存 ##########
  if(time2>endcyc){
    //output.flush();
    //output.close();


    //########## CSVファイルの読み出し ##########
    //String csvDataLine[] = loadStrings(savefile);
    //for(i=1;i<=csvDataLine.length-1;i++){
    //  string=string +csvDataLine[i]+"\r\n";
    //}
    //########## CSVファイルの読み出し ##########
    
    
    //########## クリップボードに入れる ##########
    //Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
    //StringSelection selection = new StringSelection(string);
    //clipboard.setContents(selection, null);
    //########## クリップボードに入れる ##########
    
    exit();
  }
  //########## 終了　&　データの保存 ##########
  
  delay(delaytime);//休む
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
  if(overRect(stop_button_X,button_Y,buttom_w,buttom_h)){
    if(stop_flag==0){
      stop_flag=1;

      fill(#FFFF00);//yellow
      strokeWeight(1);//線の太さ
      stroke(#FFFF00);//線の色　yellow
      rect(stop_button_X,button_Y,buttom_w,buttom_h);//ボタンを作成
      fill(0);//black
      textAlign(CENTER);
      textSize(15);
      text("START",stop_button_X+25,button_Y+18);
    
      noLoop();
    }else if(stop_flag==1){
      stop_flag=0;

      fill(#FF8000);//white
      strokeWeight(1);//線の太さ
      stroke(#FF8000);//線の色　white
      rect(stop_button_X,button_Y,buttom_w,buttom_h);//ボタンを作成
      fill(0);//black
      textAlign(CENTER);
      textSize(15);
      text("STOP", stop_button_X+25,button_Y+18);
    
      loop();
    }
  }else if(overRect(end_button_X,button_Y,buttom_w,buttom_h)){
    //output.flush();
    //output.close();


    //########## CSVファイルの読み出し ##########
    //String csvDataLine[] = loadStrings(savefile);
    //for(i=1;i<=csvDataLine.length-1;i++){
    //  string=string +csvDataLine[i]+"\r\n";
    //}
    //########## CSVファイルの読み出し ##########
    
    
    //########## クリップボードに入れる ##########
    //Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
    //StringSelection selection = new StringSelection(string);
    //clipboard.setContents(selection, null);
    //########## クリップボードに入れる ##########
    
    exit();
  }else if(overRect(page_button_X,button_Y,20,22)){
    page--;
    if(page==-1) page=4;
  }else if(overRect(page_button_X+30,button_Y,20,22)){
    page++;
    if(page==5) page=0;
  }else if(overRect(mode_button_X,button_Y,buttom_w,buttom_h)){
    if(mode==0){
      mode=1;
    }else if(mode==1){
      mode=0;
    }
  }
  
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
