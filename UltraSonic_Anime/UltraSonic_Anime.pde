import processing.awt.PSurfaceAWT; //ライブラリの宣言

int[] graph_color = new int[21];
int i=0;

int screen_w=960;
int screen_h=200;

int ei;
int eii;

PFont myFont;
PFont myFont2;
PFont myFont3;
PFont myFont4;
PFont myFont5;
PImage img;
PImage img2;
PImage img3;




void setup() {
  frameRate(60);
  size(960,130,JAVA2D);//ソフトの表示サイズ　　　リテラルのみ
  
 
  //########## フォント設定 ##########
  myFont = createFont("Dialog.bold", 40);
  myFont2 = createFont("Dialog.bold", 20);
  myFont3 = createFont("Dialog.bold", 12);
  myFont4 = createFont("Dialog.bold", 30);
  myFont5 = createFont("Dialog.bold", 16);
  //########## フォント設定 ##########
  
  
  //########## Graphカラーの設定 ##########
  graph_color[0]=#FF0000;//red
  graph_color[1]=#FF8000;//orange
  graph_color[2]=#FFFF00;//yellow
  graph_color[3]=#80FF00;//light green
  graph_color[4]=#00FF00;//green
  graph_color[5]=#00FFFF;//light blue
  graph_color[6]=#00008B;//dark blue
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
  
  img = loadImage("tokaiRika.jpg");
  img2 = loadImage("Sen.jpg");
  img3 = loadImage("hand.jpg");

  PSurfaceAWT awtSurface = (PSurfaceAWT)surface;
  PSurfaceAWT.SmoothCanvas smoothCanvas = (PSurfaceAWT.SmoothCanvas)awtSurface.getNative();
  
  smoothCanvas.getFrame().setAlwaysOnTop(true);
  smoothCanvas.getFrame().removeNotify();
  
  //タイトルバー非表示
  smoothCanvas.getFrame().setUndecorated(true);
  
  //ウィンドウの位置
  smoothCanvas.getFrame().setLocation(10, 515); //モニターのどこか
  smoothCanvas.getFrame().addNotify();

  
  delay(1);          //Arduinoが立ち上がるまで待つ（これがないと通信に失敗する）
  
}





void draw() {
    //background(255, 255, 255);//light blue　　背景色
    background(#7fffd4);//light blue　　背景色
    
    int xpos=100;
    int angle1=-10;
    
    frameRate(60);
    
    
    image(img2,20, 15);
    image(img3,880, 10);
    //image(img,0, 65);
    
    //##########　タイトルの表示　##########
    fill(#ff0000);//red
    textAlign(LEFT);
    textFont(myFont);//サイズ40
    //text("超音波センサデモ", 10, 40);
    //text("Ultrasonic Sensor DEMO", 50, 30);
    //##########　タイトルの表示　##########
      
    
    strokeWeight(2);
    noFill();
    
    
    if(ei<=10){
      for(eii=0;eii<=ei;eii++){
        stroke(255,0, 0,255-25*eii);
        arc(xpos,60,25*(ei-eii),25*(ei-eii),radians(angle1),radians(angle1+20));
      }
    }else{
      for(eii=0;eii<=10;eii++){
        if(ei>100){
          stroke(graph_color[7],255-25*eii);
        }else if(ei>80){
          stroke(graph_color[6],255-25*eii);
        }else if(ei>60){
          stroke(graph_color[15],255-25*eii);
        }else if(ei>40){
          stroke(graph_color[1],255-25*eii);
        }else if(ei>20){
          stroke(graph_color[9],255-25*eii);
        }else if(ei>10){
          stroke(graph_color[14],255-25*eii);
        }else{
          stroke(graph_color[0],255-25*eii);
        }
        
        //stroke(255,0, 0,255-20*ii);
        if(25*(ei-eii)>770*2){
          xpos=770*2+100;
          angle1=170;
        }else{
          xpos=100;
          angle1=-10;
        }
        if(25*(ei-eii)<(50+760*4)){
          arc(xpos,60,25*(ei-eii),25*(ei-eii),radians(angle1),radians(angle1+20));
        }
      }
    }
  
    
    ei++;
    if(ei==125){
      ei=0;
    } //<>//
}
