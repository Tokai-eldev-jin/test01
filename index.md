<!doctype html>
<!--
Copyright 2017-2020 JellyWare Inc. All Rights Reserved.
-->
<html>
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="description" content="BlueJelly">
    <meta name="viewport" content="width=640, maximum-scale=1.0, user-scalable=yes">
    <title>BlueJelly-ESP32  BLE DEMO</title>
    <link href="https://fonts.googleapis.com/css?family=Lato:100,300,400,700,900" rel="stylesheet" type="text/css">
    <link rel="stylesheet" href="style.css">
    <script type="text/javascript" src="bluejelly.js"></script>
    <script type="text/javascript" src="./smoothie.js"></script>
  </head>

<body>
<div class="container">
    <div class="title margin">
        <font color="orange"> <h4><p id="title">BlueJelly-ESP32  BLE DEMO</p></h4></font>
    </div>

    <div class="contents margin">
        <button id="startNotifications" class="button">Start Notify</button>
        <button id="stopNotifications" class="button">Stop Notify</button>
        
        <button id="startNotifications2" class="button">Start Notify2</button>
        <button id="stopNotifications2" class="button">Stop Notify2</button>
        
        
		<input id="write_value" class="button" value="sensor1" size="20">
        <button id="write" class="button">Write</button>
        
        <input id="write_value2" class="button" value="sensor2" size="20">
        <button id="write2" class="button">Write2</button>
        
        <hr>
        <div id="svg">GRAPH AREA</div>
        <hr>
        <span id="data_text"> </span>
        <span>　　</span>
        <span id="data_text2"> </span>
        <!--<div id="device_name"> </div>
        <div id="uuid_name"> </div>
        
        <div id="status"> </div>-->

    </div>
    <!--<div class="footer margin">
                For more information, see <a href="https://jellyware.jp/kurage" target="_blank">jellyware.jp</a> and <a href="https://github.com/electricbaka/bluejelly" target="_blank">GitHub</a> !
    </div>-->
</div>


<script>



let startflag=0;
let startflag2=0;

//--------------------------------------------------
//Global変数
//--------------------------------------------------
//BlueJellyのインスタンス生成
const ble = new BlueJelly();
const ble2 = new BlueJelly();

const ble3 = new BlueJelly();
const ble4 = new BlueJelly();

//TimeSeriesのインスタンス生成
const ble_data = new TimeSeries();



//-------------------------------------------------
//smoothie.js
//-------------------------------------------------
function createTimeline() {
    const chart = new SmoothieChart({
        millisPerPixel: 20,
        grid: {
            fillStyle: '#ff8319',
            strokeStyle: '#ffffff',
            millisPerLine: 800
        },
        maxValue: 5000,
        minValue: 0
    });
    chart.addTimeSeries(ble_data, {
        strokeStyle: 'rgba(255, 255, 255, 1)',
        fillStyle: 'rgba(255, 255, 255, 0.2)',
        lineWidth: 4
    });
    chart.streamTo(document.getElementById("chart"), 500);
}


//--------------------------------------------------
//ロード時の処理
//--------------------------------------------------
window.onload = function () {
  //UUIDの設定
  ble.setUUID("UUID1","dd5f7232-1560-4792-953d-0b2015f15340","8796fa1b-986d-419a-8f84-137710a2354f");//TX　　Service UUID,Characteristic UUID
  ble2.setUUID("UUID1","dd5f7232-1560-4792-953d-0b2015f15340","1e630bfc-08ca-44c0-a7c5-58dae380884d");//RX　　Service UUID,Characteristic UUID
  
  ble3.setUUID("UUID1","3d8b49c4-2a4b-4cfe-9d99-3d13621031ce","6032fbc0-8fec-4d4f-b524-205ee4a999c6");//TX　　Service UUID,Characteristic UUID
  ble4.setUUID("UUID1","3d8b49c4-2a4b-4cfe-9d99-3d13621031ce","6647334e-f0bd-4bd6-8a43-3c317f2ccc11");//RX　　Service UUID,Characteristic UUID
  
  //UUIDの取得方法→Powershellで　[Guid]::NewGuid()　と打つとUUIDが発行される。3回やって、1個目をService UUIDにして2個目と3個目をCharacteristic UUIDにする。
  //smoothie.js
  //createTimeline();
  
  
  
  console.log(startflag);
  
  let cnt=0;
  
  const countUp = () => {
      Create_grapf();
	  setTimeout(countUp,50);
  }
  countUp();

}


//--------------------------------------------------
//Scan後の処理
//--------------------------------------------------
ble.onScan = function (deviceName) {
  //document.getElementById('device_name').innerHTML = deviceName;
  document.getElementById('status').innerHTML = "found device!";
}


//--------------------------------------------------
//ConnectGATT後の処理
//--------------------------------------------------
ble.onConnectGATT = function (uuid) {
  console.log('> connected GATT!');

  //document.getElementById('uuid_name').innerHTML = uuid;
  //document.getElementById('status').innerHTML = "connected GATT!";
}


//--------------------------------------------------
//Sensor1 Read後の処理：得られたデータの表示など行う
//--------------------------------------------------
ble.onRead = function (data, uuid){
  //フォーマットに従って値を取得
  let value = "";
  for(let i = 0; i < data.byteLength; i++){
    value = value + String.fromCharCode(data.getInt8(i));
  }

  //数値化
  value = Number(value);

  //コンソールに値を表示
  //console.log(value);
  
  let value2=Math.round(value*0.5);
  let str_value="";
  let str_value2="";
  
  if(String(value).length==1) str_value= "000"+value;
  if(String(value).length==2) str_value= "00"+value;
  if(String(value).length==3) str_value= "0"+value;
  if(String(value).length==4) str_value= value;


  //HTMLにデータを表示
  document.getElementById('data_text').innerHTML = str_value;
  startflag = 1;
  console.log(startflag);

}



//--------------------------------------------------
//Sensor2 Read後の処理：得られたデータの表示など行う
//--------------------------------------------------
ble3.onRead = function (data, uuid){
  //フォーマットに従って値を取得
  let value = "";
  for(let i = 0; i < data.byteLength; i++){
    value = value + String.fromCharCode(data.getInt8(i));
  }

  //数値化
  value = Number(value);

  //コンソールに値を表示
  //console.log(value);
  
  let str_value="";
  
  if(String(value).length==1) str_value= "000"+value;
  if(String(value).length==2) str_value= "00"+value;
  if(String(value).length==3) str_value= "0"+value;
  if(String(value).length==4) str_value= value;


  //HTMLにデータを表示
  document.getElementById('data_text2').innerHTML = str_value;
  startflag2 = 1;
  console.log(startflag2);
}




//--------------------------------------------------
//Sensot1 Write後の処理
//--------------------------------------------------
ble2.onWrite = function(uuid){
  //document.getElementById('uuid_name').innerHTML = uuid;
  //document.getElementById('status').innerHTML = "written data"
}


//--------------------------------------------------
//Sensot2 Write後の処理
//--------------------------------------------------
ble4.onWrite = function(uuid){
  //document.getElementById('uuid_name').innerHTML = uuid;
  //document.getElementById('status').innerHTML = "written data"
}





//--------------------------------------------------
//Start Notify後の処理
//--------------------------------------------------
ble.onStartNotify = function(uuid){
  console.log('> Start Notify!');

  //document.getElementById('uuid_name').innerHTML = uuid;
  //document.getElementById('status').innerHTML = "started Notify";
}


//--------------------------------------------------
//Stop Notify後の処理
//--------------------------------------------------
ble.onStopNotify = function(uuid){
  console.log('> Stop Notify!');

  //document.getElementById('uuid_name').innerHTML = uuid;
  //document.getElementById('status').innerHTML = "stopped Notify";
}


//-------------------------------------------------
//ボタンが押された時のイベント登録
//--------------------------------------------------
document.getElementById('startNotifications').addEventListener('click', function() {
      ble.startNotify('UUID1');
});

document.getElementById('stopNotifications').addEventListener('click', function() {
      ble.stopNotify('UUID1');
});

document.getElementById('startNotifications2').addEventListener('click', function() {
      ble3.startNotify('UUID1');
});

document.getElementById('stopNotifications2').addEventListener('click', function() {
      ble3.stopNotify('UUID1');
});



document.getElementById('write').addEventListener('click', function() {
  //フォーマットに従って値を変換
  const textEncoder = new TextEncoder();
  const text_data = document.getElementById('write_value').value;
  const text_data_encoded = textEncoder.encode(text_data + '\n');

  //write
  ble2.write('UUID1', text_data_encoded);
});

document.getElementById('write2').addEventListener('click', function() {
  //フォーマットに従って値を変換
  const textEncoder = new TextEncoder();
  const text_data = document.getElementById('write_value2').value;
  const text_data_encoded = textEncoder.encode(text_data + '\n');

  //write
  ble4.write('UUID1', text_data_encoded);
});





var array1 = new Array(100);
for(let i=0;i<100;i++){
		array1[i] = new Array(2);
}








function Create_grapf() {
	let screen_w = 600;
	let screen_h = 300;
	let Max_val = 5000;
	let Min_val = 0;
	let i=0;
	let ii=0;
	var plot_color = new Array('red', 'blue', 'yellow' ,'green');
	
	
	if(startflag==1 &&  startflag2==1){
		let getdata1= Number(document.getElementById('data_text').innerText);
		let getdata2= Number(document.getElementById('data_text2').innerText);
		
		
		for(ii=0;ii<2;ii++){
			for(i=0;i<=98;i++){
				array1[i][ii]=array1[(i+1)][ii];
			}
		}
		array1[99][0]=getdata1;
		array1[99][1]=getdata2;
		
		
		
		let display_text="<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='" + screen_h + "' width='" + screen_w + "' viewBox='-50 -10 700 400' class='SvgFrame'>";
		display_text = display_text + "<line x1='0' y1='0' x2='" + screen_w + "' y2='0' style='stroke:black;stroke-width:1' />";
		display_text = display_text + "<line x1='0' y1='" + screen_h + "' x2='" + screen_w + "' y2='" + screen_h + "' style='stroke:black;stroke-width:1' />";
		display_text = display_text + "<line x1='0' y1='0' x2='0' y2='" + screen_h + "' style='stroke:black;stroke-width:1' />";
		display_text = display_text + "<line x1='" + screen_w + "' y1='0' x2='" + screen_w + "' y2='" + screen_h + "' style='stroke:black;stroke-width:1' />";
	
		for(i=1;i<=4;i++){
			display_text = display_text + "<line x1='" + screen_w/5*i + "' y1='0' x2='" + (screen_w/5*i) + "' y2='" + screen_h + "' style='stroke:gray;stroke-width:1' />";
			display_text = display_text + "<line x1='0' y1='" + screen_h/5*i + "' x2='" +  screen_w + "' y2='" + screen_h/5*i + "' style='stroke:gray;stroke-width:1' />";
		}
	
		for(i=0;i<=5;i++){
	        display_text = display_text + "<text x='-5' y='"+ (screen_h/5*i+10) +"' font-size='20' stroke='black' text-anchor='end' stroke-width='1'>"+(Max_val-Max_val/5*i)+"</text>"
	    }
	    
		
		
		for(ii=0;ii<2;ii++){
		    let x1 = 0;
		    
		    for(let i = 0;i<=98;i++){
		    	let x2=0;
		        x2 = x1 + screen_w / 100;
		        y1 = array1[i][ii]
		        y1 -= Min_val;
		        y1 *= screen_h;
		        y1 /= (Max_val - Min_val);
		        y1 = screen_h - y1;
		        
		        y2 =  array1[(i+1)][ii];
		        y2 -= Min_val;
		        y2 *= screen_h;
		        y2 /= (Max_val - Min_val);
		        y2 = screen_h - y2;
		        display_text = display_text + "<line x1='" + x1 + "' y1='" + y1 + "' x2='" + x2 + "' y2='" + y2 + "' style='stroke:"+ plot_color[ii] +";stroke-width:2' />";
		        
		        x1 += screen_w / 100
		        
		    }
	    }
	
	    
	    display_text += "</svg>"
	    document.getElementById("svg").innerHTML =  display_text;
    }


}



</script>
</body>
</html>
