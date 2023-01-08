//########## I2C ##########
// #define MICON_ESP32              // undefined if Arduino
#ifdef MICON_ESP32
#   error "I2C Sub functionality is not implemented in ESP32 Arduino Core"
#   error "If you want to implement, see https://www.arduino.cc/reference/en/libraries/esp32-i2c-slave/"
#endif
#define ADDRESS 0x8
#include <Wire.h>
//########## I2C ##########


byte data_send[32];
byte registerIndex = 0;
byte preR=0;


byte digital_filter=1;

#include <DueTimer.h>


//########## 使用してない ##########
inline void digitalWriteDirect(int pin, boolean val){
  if(val) g_APinDescription[pin].pPort -> PIO_SODR = g_APinDescription[pin].ulPin;
  else    g_APinDescription[pin].pPort -> PIO_CODR = g_APinDescription[pin].ulPin;
}

static inline void delayNanoseconds(uint32_t) __attribute__((always_inline, unused));
static inline void delayNanoseconds(uint32_t nsec){
  /*
   * Based on Paul Stoffregen's implementation
   * for Teensy 3.0 (http://www.pjrc.com/)
   */
  if (nsec == 0) return;
  uint32_t n = (nsec * 1000) / 35714;
  asm volatile(
      "L_%=_delayNanos:"       "\n\t"
      "subs   %0, #1"                 "\n\t"
      "bne    L_%=_delayNanos" "\n"
      : "+r" (n) :
  );
}
//########## 使用してない ##########




bool H_flag=true;
int Freq = 22000;
bool timer_flag=true;



//########## 超音波の発振（クロック制御） ##########
void Handler1(){
  if(H_flag==true){
    REG_PIOC_CODR |= (0x01 << 28); //3OFF   PORTC 28bit OFF
    REG_PIOB_SODR |= (0x01 << 25); //2ON    PORTB 25bit ON
    
    H_flag = false;
  }else if(H_flag==false){
    REG_PIOB_CODR |= (0x01 << 25); //2OFF   PORTB 25bit OFF
    REG_PIOC_SODR |= (0x01 << 28); //3ON    PORTC 28bit ON
    
    H_flag = true;   
  }
}
//########## 超音波の発振（クロック制御） ##########









#define DATA_LEN 5000//##########全データ取りのバイト
#define Sen_LEN 3675//##########全データ取りのバイト
uint16_t ADC_table[DATA_LEN];
uint16_t ADC_table2[DATA_LEN];
uint16_t ADC_table3[DATA_LEN];
uint16_t k=0;
uint16_t t=0;
uint16_t cyc1=12;
uint16_t cyc2=0;
int Sikiichi = 50;

byte PCmode=1;//##########　1：Processingから制御している


void getADC1(){
  //ADC_table[k]=IIR_Filter(analogRead(A0));
  ADC_table[k]=analogRead(A0);
  delayMicroseconds(2);
  k++;
}



//########## IIR Filter 使用してない ########## 
float alpha = 0.5; // 0 < alpha < 1 
float y;           //Output
static int y_old;

int IIR_Filter(int x){
  y = alpha * y_old + (1 - alpha) * x;
  y_old = y;
  return y;
}
//########## IIR Filter 使用してない ########## 





void setup() {
  Serial.begin(115200);

  //########## I2C Setting ##########
  Wire.begin(ADDRESS);            // join i2c bus with address #8
  Wire.setClock(100000);
  
  Wire.onReceive(receiveEvent);   // register event
  Wire.onRequest(requestEvent);   // register event
  //########## I2C Setting ##########
  
  
  pinMode(13,OUTPUT);
  delay(500);

  analogReadResolution(12);

  //########## 超音波発振ピンの設定 ##########
  pinMode(2,OUTPUT);
  pinMode(3,OUTPUT);
  digitalWriteDirect(2,LOW);
  digitalWriteDirect(3,LOW);
  //########## 超音波発振ピンの設定 ########## 

  
}










void loop() {

  uint16_t i=0;
  uint32_t delay_us=0;

  //########### Timerの設定 ##########
  Timer1.attachInterrupt(Handler1).setFrequency(Freq*2);//##########発振タイマー
  Timer2.attachInterrupt(getADC1).setFrequency(125000);//##########ADCの間隔　125kHz＝8usec
  //########### Timerの設定 ##########
  
  
  //########## 発振回数の設定 ##########
  delay_us=1000000;
  delay_us/=Freq;
  delay_us*=8;////plus数
  //########## 発振回数の設定 ##########


  //##########ESP32にReadyを送る##########
  int hh=0;
  while(1){
    if(registerIndex==2){
      data_send[0]=2;
      registerIndex=0;
      break;
    }else{
      hh++;
      if(hh>400){
        data_send[0]=20;
        registerIndex=0;
        delay(2000);
      }
    }
    delay(10);
  }
  delay(1);
  //##########ESP32にReadyを送る##########


  //########## ProcessingにReadyを送る ##########
  Serial.write(5);
  Serial.flush();
  //########## ProcessingにReadyを送る ##########
  
  
    
  //##########Processingから閾値を受け取る##########
  int pp=0;
  while(true){
    if(Serial.available()==2) { //2byteの閾値を受信した場合
      //##########閾値を受け取る##########
      Sikiichi = Serial.read()<<8;
      Sikiichi |= Serial.read();
      //##########閾値を受け取る##########
      PCmode=1;
      break;
    }

    if(pp==100){//###########Processingと通信してない場合###########
      PCmode=0;    
      break;
    }
    pp++; 
    delay(1);
  }
  //##########Processingから閾値を受け取る##########

  
      
  //########## 超音波の発振 ##########
  if(timer_flag!=true){
    for(i=0;i<8;i++){
      REG_PIOC_CODR |= (0x01 << 28); //3OFF   PORTC 28bit OFF
      REG_PIOB_SODR |= (0x01 << 25); //2ON    PORTB 25bit ON
  
      delayMicroseconds(12);
  
      REG_PIOB_CODR |= (0x01 << 25); //2OFF   PORTB 25bit OFF
      REG_PIOC_SODR |= (0x01 << 28); //3ON    PORTC 28bit ON
      
      delayMicroseconds(12);
    }
  }else{//########## こっちで発振させている ##########
    Timer1.start();
    delayMicroseconds(delay_us);
    Timer1.stop();
  }
  REG_PIOB_CODR |= (0x01 << 25); //2OFF   PORTB 25bit OFF
  REG_PIOC_CODR |= (0x01 << 28); //3OFF   PORTC 28bit OFF

//  REG_PIOC_SODR |= (0x01 << 28); //3ON    PORTC 28bit ON
//  delayMicroseconds(12);
//  REG_PIOC_CODR |= (0x01 << 28); //3OFF   PORTC 28bit OFF
  
//  delayMicroseconds(12);
//  REG_PIOB_SODR |= (0x01 << 25); //2ON    PORTB 25bit ON
//  delayMicroseconds(12);
//  REG_PIOB_CODR |= (0x01 << 25); //2OFF   PORTB 25bit OFF
  //########## 超音波の発振 ##########



  //########## データの取得 ##########
  k=0;
//  for(k=0;k<4000;k++){
//    ADC_table[k]=analogRead(A0);
//    delayMicroseconds(3);
//  }
  Timer2.start();
  delay(32);
  Timer2.stop();
  //########## データの取得 ##########

  

  //########## デジタルフィルタ（一般的なIIRフィルタ） ##########
  if(digital_filter==1){
    float AA = 0.2;
    for(k=1;k<DATA_LEN;k++){
      ADC_table[k] = AA*ADC_table[k-1] + (1-AA)*ADC_table[k];
    }
  }
  //########## デジタルフィルタ（一般的なIIRフィルタ）  ##########
  

  //########## 最初の50個のデータの平均値を出す ##########
  int avedata=0;
  
  for(i=0;i<50;i++){
    avedata+=ADC_table[(Sen_LEN-50)+i];
  }
  avedata/=50;
  //########## 最初の50個のデータの平均値を出す ##########

  
  //########## デジタルフィルタ2 ##########
  if(digital_filter==1){
    k=0;
    int p_k_cnt1=3;
    int k_table[20];
    int g=0;
    int kk=0;
    int k_cnt1=0;
    int k_cnt2=0;
    int k_flag=0;
    
    int getdata1;
    int getdata2;
    int getdata3;
    int k_cnt2max=0;
    byte h=0;


    for(k=0;k<DATA_LEN-50;k=k+50){
      k_cnt1=0;
      for(kk=0;kk<50;kk++){
        if(abs(ADC_table[k+kk]-avedata)>1000){
          k_cnt1++;
        }
      }

//      Serial.print(k);
//      Serial.print(',');
//      Serial.println(k_cnt1);

      if(k_cnt1>15){
        k_table[h]=k;
        h++;
      }
    }


    for(k=0;k<DATA_LEN-50;k=k+50){
      k_flag=0;
      for(g=0;g<h;g++){
        if((k_table[g]-1*50)<=k && k<=(k_table[g]+1*50)){
          k_flag=1;
        }
      }

      if(k_flag==0){
        for(kk=0;kk<50;kk++){
          getdata1=ADC_table[k+kk];
          getdata1-=avedata;
          getdata1/=20;
          getdata1+=avedata;
          ADC_table[k+kk]=getdata1;
        }
      }
    }


    
    for(h=0;h<0;h++){//########## フィルタを4回かける
      for(k=0;k<DATA_LEN-2;k=k+2){
        kk=0;
        k_cnt1=0;
        k_flag=0;

        //########## peakの数を数える ##########
        for(kk=0;kk<20;kk++){
          getdata1=ADC_table[(k+kk+1)]-ADC_table[k+kk];
          getdata2=(ADC_table[k+kk+1]-avedata);
          
          if(getdata1>0){
            if(k_flag==0){
              k_flag=1;
            }
          }else if(getdata1<0 && getdata2<0){
            if(k_flag==1){
              k_flag=0;
              k_cnt1++;
            }
          }
        }
        //########## peakの数を数える ##########

        if(k_cnt1>=3 && k_cnt1<=6){
          for(kk=0;kk<20;kk++){
            ADC_table3[k+kk]=ADC_table[k+kk];
          }
        }else{//########## peakの数がおかしいときは出力を1/10にする
          for(kk=0;kk<20;kk++){
            //if(h==0){
              ADC_table3[k+kk]=(ADC_table[k+kk]-avedata)/10;
              ADC_table3[k+kk]+=avedata;
            //}
          }
        }
        
        p_k_cnt1=k_cnt1;
      }

      //########## フィルタ後の値を入れる ##########
      for(k=0;k<DATA_LEN;k++){
        ADC_table[k]=ADC_table3[k];
      }
      //########## フィルタ後の値を入れる ##########
    }




    
//    for(k=0;k<DATA_LEN;k++){
//      if(abs(ADC_table[k]-avedata)<200){
//        ADC_table[k]=(ADC_table[k]-avedata)/10;
//        ADC_table[k]+=avedata;
//      }
//    }
  
//    for(k=0;k<DATA_LEN-100;k=k+100){
//      k_cnt1=0;
//      k_cnt2=0;
//      for(kk=0;kk<100;kk++){
//        if((ADC_table[k+kk]-avedata)>0){
//          k_cnt1++;
//        }else{
//          k_cnt2++;
//        }
//      }
//
//      if(abs(k_cnt1-k_cnt2)>=30 || k_cnt1<=10 || k_cnt2<=10){
//        for(kk=0;kk<100;kk++){
//          ADC_table[k+kk]=(ADC_table[k+kk]-avedata)/20;
//          //ADC_table[k+kk]/=10;
//          ADC_table[k+kk]+=avedata;
//        }
//      }
//    }






    
    for(k=0;k<150;k++){
      ADC_table[k]=(ADC_table[k+kk]-avedata)/10;
      ADC_table[k]+=avedata;
    }
  }else if(digital_filter==2){
//    HPF 10oder fc=18kHz
    float A10 =  0.7203292847;
    float A11 = -1.4406604767;
    float A12 =  0.7203292847;
    float C11 =  1.1003780365;
    float C12 = -0.7809410095;

    float A20 =  0.5961322784;
    float A21 = -1.1922664642;
    float A22 =  0.5961322784;
    float C21 =  0.9106540680;
    float C22 = -0.473876953;

    float A30 =  0.5198841095;
    float A31 = -1.0397663116;
    float A32 =  0.5198841095;
    float C31 =  0.7941761017;
    float C32 = -0.2853565216;

    float A40 =  0.4756793976;
    float A41 = -0.9513568878;
    float A42 =  0.4756793976;
    float C41 =  0.7266483307;
    float C42 = -0.1760654449;

    float A50 =  0.4553241730;
    float A51 = -0.9106502533;
    float A52 =  0.4553241730;
    float C51 =  0.6955566406;
    float C52 = -0.1257419586;


//    LPF 10oder fc=31kHz 
    float A60 =  0.4269371033;
    float A61 =  0.8538761139;
    float A62 =  0.4269371033;
    float C61 =  0.0217208862;
    float C62 = -0.7294731140;

    float A70 =  0.3395709991;
    float A71 =  0.6791419983;
    float A72 =  0.3395709991;
    float C71 =  0.0172767639;
    float C72 = -0.3755588531;

    float A80 =  0.2892246246;
    float A81 =  0.5784492493;
    float A82 =  0.2892246246;
    float C81 =  0.0147151947;
    float C82 = -0.1716117859;

    float A90 =  0.2610988617;
    float A91 =  0.5221977234;
    float A92 =  0.2610988617;
    float C91 =  0.0132827759;
    float C92 = -0.0576763153;
    
    float A100 =  0.2483997345;
    float A101 =  0.4967975616;
    float A102 =  0.2483997345;
    float C101 =  0.0126380920;
    float C102 = -0.0062332153;

    double indata = 0.0;

    double add1 = 0.0;
    double dl_a11 = 0.0;
    double dl_a12 = 0.0;
    double dl_b11 = 0.0;
    double dl_b12 = 0.0;
    double add2 = 0.0;
    double dl_a21 = 0.0;
    double dl_a22 = 0.0;
    double dl_b21 = 0.0;
    double dl_b22 = 0.0;
    double add3 = 0.0;
    double dl_a31 = 0.0;
    double dl_a32 = 0.0;
    double dl_b31 = 0.0;
    double dl_b32 = 0.0;
    double add4 = 0.0;
    double dl_a41 = 0.0;
    double dl_a42 = 0.0;
    double dl_b41 = 0.0;
    double dl_b42 = 0.0;
    double add5 = 0.0;
    double dl_a51 = 0.0;
    double dl_a52 = 0.0;
    double dl_b51 = 0.0;
    double dl_b52 = 0.0;
    double add6 = 0.0;
    double dl_a61 = 0.0;
    double dl_a62 = 0.0;
    double dl_b61 = 0.0;
    double dl_b62 = 0.0;
    double add7 = 0.0;
    double dl_a71 = 0.0;
    double dl_a72 = 0.0;
    double dl_b71 = 0.0;
    double dl_b72 = 0.0;
    double add8 = 0.0;
    double dl_a81 = 0.0;
    double dl_a82 = 0.0;
    double dl_b81 = 0.0;
    double dl_b82 = 0.0;
    double add9 = 0.0;
    double dl_a91 = 0.0;
    double dl_a92 = 0.0;
    double dl_b91 = 0.0;
    double dl_b92 = 0.0;
    double add10 = 0.0;
    double dl_a101 = 0.0;
    double dl_a102 = 0.0;
    double dl_b101 = 0.0;
    double dl_b102 = 0.0;

    double outdata = 0.0;

    for(k=1;k<DATA_LEN;k++){
      indata = (double)ADC_table[k];
//HPF 
      add1 = indata*A10 + dl_a11*A11 + dl_a12*A12 + dl_b11*C11 + dl_b12*C12;
      dl_a11 = indata; 
      dl_a12 = dl_a11;
      dl_b11 = add1;
      dl_b12 = dl_b11;

      add2 = add1*A20 + dl_a21*A21 + dl_a22*A22 + dl_b21*C21 + dl_b22*C22;      
      dl_a21 = add1; 
      dl_a22 = dl_a21;
      dl_b21 = add2;
      dl_b22 = dl_b21;

      add3 = add2*A30 + dl_a31*A31 + dl_a32*A32 + dl_b31*C31 + dl_b32*C32;      
      dl_a31 = add2; 
      dl_a32 = dl_a31;
      dl_b31 = add3;
      dl_b32 = dl_b31;

      add4 = add3*A40 + dl_a41*A41 + dl_a42*A42 + dl_b41*C41 + dl_b42*C42;      
      dl_a41 = add3; 
      dl_a42 = dl_a41;
      dl_b41 = add4;
      dl_b42 = dl_b41;

      add5 = add4*A50 + dl_a51*A51 + dl_a52*A52 + dl_b51*C51 + dl_b52*C52;      
      dl_a51 = add4; 
      dl_a52 = dl_a51;
      dl_b51 = add5;
      dl_b52 = dl_b51;


//LPF
      add6 = add5*A60 + dl_a61*A61 + dl_a62*A62 + dl_b61*C61 + dl_b62*C62;      
      dl_a61 = add5; 
      dl_a62 = dl_a61;
      dl_b61 = add6;
      dl_b62 = dl_b61;

      add7 = add6*A70 + dl_a71*A71 + dl_a72*A72 + dl_b71*C71 + dl_b72*C72;      
      dl_a71 = add6; 
      dl_a72 = dl_a71;
      dl_b71 = add7;
      dl_b72 = dl_b71;

      add8 = add7*A80 + dl_a81*A81 + dl_a82*A82 + dl_b81*C81 + dl_b82*C82;      
      dl_a81 = add7; 
      dl_a82 = dl_a81;
      dl_b81 = add8;
      dl_b82 = dl_b81;

      add9 = add8*A90 + dl_a91*A91 + dl_a92*A92 + dl_b91*C91 + dl_b92*C92;      
      dl_a91 = add8; 
      dl_a92 = dl_a91;
      dl_b91 = add9;
      dl_b92 = dl_b91;

      add10 = add9*A100 + dl_a101*A101 + dl_a102*A102 + dl_b101*C101 + dl_b102*C102;      
      dl_a101 = add9; 
      dl_a102 = dl_a101;
      dl_b101 = add10;
      dl_b102 = dl_b101;

      outdata = (add10 * 4  ) + 2048.0;
      ADC_table[k] = (int)outdata;
    }
  }
  //########## デジタルフィルタ2 ##########

  
  //########## データの取得 ##########


  //########## Processingにデータの送信 ##########
  if(PCmode==1){
    byte m=0;
    int n=0;
    for(m=0;m<5;m++){
      while(1){
        if(Serial.available()>=1) break;
        delayMicroseconds(1);
      }
      
      byte rrr=Serial.read();
      
      for(k=0;k<Sen_LEN/5;k++){
        Serial.write(highByte(ADC_table[n]));
        Serial.write(lowByte(ADC_table[n]));
        Serial.flush();
        n++;
      }
    }
  }
  //########## Processingにデータの送信 ##########


  
  
  //########## 平均値に対する増減を絶対値にする ##########
  int getdata;
  for(i=0;i<Sen_LEN;i++){
    getdata=ADC_table[i];
    getdata = abs(avedata-getdata);
    ADC_table2[i]=getdata;
  }
  //########## 平均値に対する増減を絶対値にする ##########


  
  //########## 平均化する ##########
  int t=0;
  uint16_t ii=0; 
  for(ii=0;ii<2;ii++){
    for(i=0;i<Sen_LEN-50;i++){
      avedata=0;
      for(t=0;t<50;t++){
        avedata+=ADC_table2[i+t];
      }
      avedata/=50;
      ADC_table2[i]=avedata;
    }
  }
  //########## 平均化する ##########

  
  //########## ピークを検出する ##########
  int kando_max[]={0,0,0,0,0,0,0,0,0,0};
  int max_time[]={0,0,0,0,0,0,0,0,0,0};

  int kando0=Sikiichi;
  int kando=Sikiichi;
  int kando_time=0;
  int kando_num1=0;
  int kando_num2=0;
  int kando_flag=0;
  int p=0;
  
  for(i=0;i<Sen_LEN-50;i++){
    if(ADC_table2[i]<ADC_table2[i+10] && ADC_table2[i]>Sikiichi){//10個先のデータと比較して上に上がっている　かつ　閾値以上の場合
      kando_num1++;
      if(kando_num1==40){//連続で40回上に上がっている場合
        kando_flag=1;
        kando=ADC_table2[i];
      }
    }else{
      kando_num1=0;
    }
    
    if(kando_flag==1){//上に上がっているモードの時
      kando0=ADC_table2[i];
      byte d=0;
      byte c=0;
      for(c=0;c<10;c++){
        if(kando0<ADC_table2[i+c]){
          kando0=ADC_table2[i+c];
          d=c;
        }
      }
      
      if(kando0>kando){
        kando_time=i+d;
        kando_num2=0;
        kando=kando0;
      }else{
        kando_num2++;
        if(kando_num2==40){//40回連続でmax値より低い場合
          kando_max[p]=kando;
          max_time[p]=kando_time;      //peakを格納する

          p++;
          if(p==10) break;    //10個検出でやめる
          
          kando=Sikiichi;
          kando0=Sikiichi;
          kando_num1=0;
          kando_flag=0;
          kando_num2=0;
        }
      }
    }
  }
  //########## ピークを検出する ##########
  
  
  //########## 距離を計算する ##########
  int graph_offset=50/2*2;      //50回平均の半分をずらして表示する
  graph_offset-=0;
  
  int kyori0 = -65;
  float Kyori2=0;
  float Kyori3=0;
  String Kyori="0";

  int posx[]={50,100,150};
  float kyori4[]={0,0,0,0,0,0,0,0,0,0};
  int Kyori5=0;

  int max_pos=kando_max[9];
  byte max_pos1=9;
  
  for(i=0;i<9;i++){
    if(max_pos<kando_max[i]){
      if(max_time[i]>150){//##########1000/735*150＝204㎜以上で距離を出す
        max_pos=kando_max[i];
        max_pos1=i;
      }
    }
  }
          
  Kyori2=max_time[max_pos1];
  if(Kyori2==0){
    Kyori5=0;
  }else{
    Kyori2+=graph_offset;
    Kyori2=map(Kyori2,0,735*5,0,5000);//4000ピクセルは6800mm
    Kyori2/=10;
    Kyori5=(int)Kyori2;
  }
  //########## 距離を計算する ##########

  

  //########## ESPに距離を送る ##########
  digitalWrite(13,HIGH);
  
  hh=0;
  while(1){
    if(registerIndex==3){
      data_send[1]=lowByte(Kyori5);
      data_send[2]=highByte(Kyori5);
      data_send[0]=3;
      registerIndex=0;
      break;
    }else{
      hh++;
      if(hh>200){
        data_send[0]=20;
        registerIndex=0;
        software_reset();
      }
    }
    delay(1);
  }
  delay(1);
  
  digitalWrite(13,LOW);
//  Serial.println("ESP");
  //########## ESPに距離を送る ##########
  



  //##########ESP32にPCmodeを送る##########
  hh=0;
  while(1){
    if(registerIndex==4){
      data_send[1]=PCmode;
      data_send[0]=4;
      registerIndex=0;
      break;
    }else{
      hh++;
      if(hh>400){
        data_send[0]=20;
        registerIndex=0;
        software_reset();
      }
    }
    delay(1);
  }
  delay(1);
//  Serial.println("PCmode");
  //##########ESP32にPCmodeを送る##########
  
  
  
  if(PCmode==0){//########## LCDに表示する場合

    //##########ESP32にデータを送る##########
    int mm=0;
    int nn=0;
    int pp=0;

    //######### 32byteづつ　30回送る 生データ##########
    for(mm=0;mm<30;mm++){
      hh=0;
      while(1){
        if(registerIndex==5){
          for(nn=0;nn<15;nn++){   
            data_send[2*nn+1]=(lowByte(ADC_table[pp]));
            data_send[2*nn+2]=(highByte(ADC_table[pp]));
            pp=pp+5;
          }
          data_send[0]=5;
          registerIndex=0;
          break;
        }else{
          hh++;
          if(hh>400){
            data_send[0]=20;
            registerIndex=0;
            software_reset();
          }
        }
        delay(2);
      }
      delay(2);
    }
    //######### 32byteづつ　30回送る ##########
    
    
    pp=0;
    nn=0;

    //######### 32byteづつ　30回送る 加工データ##########
    for(mm=0;mm<30;mm++){
      hh=0;
      while(1){
        if(registerIndex==6){
          for(nn=0;nn<15;nn++){   
            data_send[2*nn+1]=(lowByte(ADC_table2[pp]));
            data_send[2*nn+2]=(highByte(ADC_table2[pp]));
            pp=pp+5;
          }
          data_send[0]=6;
          registerIndex=0;
          break;
        }else{
          hh++;
          if(hh>400){
            data_send[0]=20;
            registerIndex=0;
            software_reset();
          }
        }
        delay(2);
      }
      delay(2);
    }
    //######### 32byteづつ　30回送る ##########
    delay(2);
    
    //##########ESP32にデータを送る##########
    

    //##########ESP32から終了を受け取る##########
    hh=0;
    while(1){
      if(registerIndex==10){
        data_send[0]=10;
        registerIndex=0;
        break;
      }else{
        hh++;
        if(hh>400){
          data_send[0]=20;
          registerIndex=0;
          software_reset();
        }
      }
      delay(2);
    }
    delay(2);
    //##########ESP32から終了を受け取る##########
  }else{//PCmode=1
    while(true){
      if(Serial.available()==1) { //2byteの閾値を受信した場合
        byte RR = Serial.read();
        if(RR==100) digital_filter=2;
        if(RR==5) digital_filter=1;
        if(RR==50) digital_filter=0;
        if(RR==100 || RR==50 || RR==5) break;
      }
    }
  }

  
  
  
  delay(100);
}




void software_reset() {
  SCB->AIRCR = ((0x5FA << SCB_AIRCR_VECTKEY_Pos) | SCB_AIRCR_SYSRESETREQ_Msk);
}







void receiveEvent(int howMany) {
  if( howMany == 0 ) {
      return;
  }

  byte R;
  while(Wire.available()) { // loop through all but the last
    R = Wire.read();
  }
  registerIndex=R;
}






// function that executes whenever data is requested by main
// this function is registered as an event, see setup()
void requestEvent(void) {
//  Serial.println("requestEvent");
  for(byte q=0;q<32;q++){
    Wire.write(data_send[q]);// respond with message of 32 bytes
  }
}
