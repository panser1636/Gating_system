/***************************************
该模块用来向ram中写入显示的数据
地址0~127：第7页
地址128~255：第6页
地址256~383：第5页
地址384~511：第4页
地址512~639：第3页
地址640~767：第2页
地址768~895：第1页
地址896~1023：第0页
****************************************/
module ram_write(
	input clk,							//时钟信号
	input rst_n,						//按键复位信号
	input en_ram_wr,					//模块开始写信号
	input [2:0] count,                // input count_number
	
	input finish_flag,				//key_lock
	input inputing,             
	input [2:0] key_num,
	input success,
	
	output reg wren,					//ram写使能
	output reg [9:0] wraddress,	//ram写地址
	output reg [7:0] data			//写到ram的数据
);
 
//状态说明
//等待模块使能 写数据 完成
parameter WaitInit=0,WriteData=1,Done=2,InputKey=3,Error=4,Welcome=5,Clear=6;
reg[2:0] state,next_state;
reg [24:0]welcome_flag;
reg [24:0]error_flag;
reg [7:0] zm[927:0];//写进ram的静态数据
reg [9:0] cnt_zm;//数据计数器
reg [9:0] cnt_zmw;//数据计数器
 
//字模数据初始化 字号大小16
initial begin
zm[0]=8'h00;zm[1]=8'h00;zm[2]=8'h07;zm[3]=8'hF0;zm[4]=8'h08;zm[5]=8'h08;zm[6]=8'h10;zm[7]=8'h04;
zm[8]=8'h10;zm[9]=8'h04;zm[10]=8'h08;zm[11]=8'h08;zm[12]=8'h07;zm[13]=8'hF0;zm[14]=8'h00;zm[15]=8'h00;//00

zm[16]=8'h00;zm[17]=8'h00;zm[18]=8'h00;zm[19]=8'h00;zm[20]=8'h08;zm[21]=8'h04;zm[22]=8'h08;zm[23]=8'h04;
zm[24]=8'h1F;zm[25]=8'hFC;zm[26]=8'h00;zm[27]=8'h04;zm[28]=8'h00;zm[29]=8'h04;zm[30]=8'h00;zm[31]=8'h00;//11

zm[32]=8'h00;zm[33]=8'h00;zm[34]=8'h0E;zm[35]=8'h0C;zm[36]=8'h10;zm[37]=8'h14;zm[38]=8'h10;zm[39]=8'h24;
zm[40]=8'h10;zm[41]=8'h44;zm[42]=8'h10;zm[43]=8'h84;zm[44]=8'h0F;zm[45]=8'h0C;zm[46]=8'h00;zm[47]=8'h00;//22

zm[48]=8'h00;zm[49]=8'h00;zm[50]=8'h0C;zm[51]=8'h18;zm[52]=8'h10;zm[53]=8'h04;zm[54]=8'h10;zm[55]=8'h84;
zm[56]=8'h10;zm[57]=8'h84;zm[58]=8'h11;zm[59]=8'h44;zm[60]=8'h0E;zm[61]=8'h38;zm[62]=8'h00;zm[63]=8'h00;//33

zm[64]=8'h00;zm[65]=8'h00;zm[66]=8'h00;zm[67]=8'h60;zm[68]=8'h01;zm[69]=8'hA0;zm[70]=8'h02;zm[71]=8'h24;
zm[72]=8'h0C;zm[73]=8'h24;zm[74]=8'h1F;zm[75]=8'hFC;zm[76]=8'h00;zm[77]=8'h24;zm[78]=8'h00;zm[79]=8'h24;//44

zm[80]=8'h00;zm[81]=8'h00;zm[82]=8'h1F;zm[83]=8'h98;zm[84]=8'h11;zm[85]=8'h04;zm[86]=8'h11;zm[87]=8'h04;
zm[88]=8'h11;zm[89]=8'h04;zm[90]=8'h10;zm[91]=8'h88;zm[92]=8'h10;zm[93]=8'h70;zm[94]=8'h00;zm[95]=8'h00;//55

zm[96]=8'h00;zm[97]=8'h00;zm[98]=8'h07;zm[99]=8'hF0;zm[100]=8'h08;zm[101]=8'h88;zm[102]=8'h11;zm[103]=8'h04;
zm[104]=8'h11;zm[105]=8'h04;zm[106]=8'h09;zm[107]=8'h04;zm[108]=8'h00;zm[109]=8'hF8;zm[110]=8'h00;zm[111]=8'h00;//66

zm[112]=8'h00;zm[113]=8'h00;zm[114]=8'h18;zm[115]=8'h00;zm[116]=8'h10;zm[117]=8'h00;zm[118]=8'h10;zm[119]=8'h7C;
zm[120]=8'h11;zm[121]=8'h80;zm[122]=8'h16;zm[123]=8'h00;zm[124]=8'h18;zm[125]=8'h00;zm[126]=8'h00;zm[127]=8'h00;//77

zm[128]=8'h00;zm[129]=8'h00;zm[130]=8'h0E;zm[131]=8'h38;zm[132]=8'h11;zm[133]=8'h44;zm[134]=8'h10;zm[135]=8'h84;
zm[136]=8'h10;zm[137]=8'h84;zm[138]=8'h11;zm[139]=8'h44;zm[140]=8'h0E;zm[141]=8'h38;zm[142]=8'h00;zm[143]=8'h00;//88

zm[144]=8'h00;zm[145]=8'h00;zm[146]=8'h0F;zm[147]=8'h80;zm[148]=8'h10;zm[149]=8'h48;zm[150]=8'h10;zm[151]=8'h44;
zm[152]=8'h10;zm[153]=8'h44;zm[154]=8'h08;zm[155]=8'h88;zm[156]=8'h07;zm[157]=8'hF0;zm[158]=8'h00;zm[159]=8'h00;//99

zm[160]=8'h10;zm[161]=8'h00;zm[162]=8'h1F;zm[163]=8'hC0;zm[164]=8'h00;zm[165]=8'h7C;zm[166]=8'h1F;zm[167]=8'h80;
zm[168]=8'h00;zm[169]=8'h7C;zm[170]=8'h1F;zm[171]=8'hC0;zm[172]=8'h10;zm[173]=8'h00;zm[174]=8'h00;zm[175]=8'h00;//W10

zm[176]=8'h10;zm[177]=8'h04;zm[178]=8'h1F;zm[179]=8'hFC;zm[180]=8'h11;zm[181]=8'h04;zm[182]=8'h11;zm[183]=8'h04;
zm[184]=8'h17;zm[185]=8'hC4;zm[186]=8'h10;zm[187]=8'h04;zm[188]=8'h08;zm[189]=8'h18;zm[190]=8'h00;zm[191]=8'h00;//E11

zm[192]=8'h10;zm[193]=8'h04;zm[194]=8'h1F;zm[195]=8'hFC;zm[196]=8'h10;zm[197]=8'h04;zm[198]=8'h00;zm[199]=8'h04;
zm[200]=8'h00;zm[201]=8'h04;zm[202]=8'h00;zm[203]=8'h04;zm[204]=8'h00;zm[205]=8'h0C;zm[206]=8'h00;zm[207]=8'h00;//L12

zm[208]=8'h03;zm[209]=8'hE0;zm[210]=8'h0C;zm[211]=8'h18;zm[212]=8'h10;zm[213]=8'h04;zm[214]=8'h10;zm[215]=8'h04;
zm[216]=8'h10;zm[217]=8'h04;zm[218]=8'h10;zm[219]=8'h08;zm[220]=8'h1C;zm[221]=8'h10;zm[222]=8'h00;zm[223]=8'h00;//C13

zm[224]=8'h07;zm[225]=8'hF0;zm[226]=8'h08;zm[227]=8'h08;zm[228]=8'h10;zm[229]=8'h04;zm[230]=8'h10;zm[231]=8'h04;
zm[232]=8'h10;zm[233]=8'h04;zm[234]=8'h08;zm[235]=8'h08;zm[236]=8'h07;zm[237]=8'hF0;zm[238]=8'h00;zm[239]=8'h00;//O14

zm[240]=8'h10;zm[241]=8'h04;zm[242]=8'h1F;zm[243]=8'hFC;zm[244]=8'h1F;zm[245]=8'h80;zm[246]=8'h00;zm[247]=8'h7C;
zm[248]=8'h1F;zm[249]=8'h80;zm[250]=8'h1F;zm[251]=8'hFC;zm[252]=8'h10;zm[253]=8'h04;zm[254]=8'h00;zm[255]=8'h00;//M15

zm[256]=8'h10;zm[257]=8'h04;zm[258]=8'h1F;zm[259]=8'hFC;zm[260]=8'h11;zm[261]=8'h04;zm[262]=8'h11;zm[263]=8'h04;
zm[264]=8'h17;zm[265]=8'hC4;zm[266]=8'h10;zm[267]=8'h04;zm[268]=8'h08;zm[269]=8'h18;zm[270]=8'h00;zm[271]=8'h00;//E16

zm[272]=8'h00;zm[273]=8'h00;zm[274]=8'h00;zm[275]=8'h00;zm[276]=8'h00;zm[277]=8'h00;zm[278]=8'h1F;zm[279]=8'hCC;
zm[280]=8'h00;zm[281]=8'h00;zm[282]=8'h00;zm[283]=8'h00;zm[284]=8'h00;zm[285]=8'h00;zm[286]=8'h00;zm[287]=8'h00;//!17

zm[288]=8'h00;zm[289]=8'h00;zm[290]=8'h00;zm[291]=8'h00;zm[292]=8'h00;zm[293]=8'h00;zm[294]=8'h1F;zm[295]=8'hCC;
zm[296]=8'h00;zm[297]=8'h00;zm[298]=8'h00;zm[299]=8'h00;zm[300]=8'h00;zm[301]=8'h00;zm[302]=8'h00;zm[303]=8'h00;//!18

zm[304]=8'h00;zm[305]=8'h00;zm[306]=8'h00;zm[307]=8'h00;zm[308]=8'h00;zm[309]=8'h00;zm[310]=8'h1F;zm[311]=8'hCC;
zm[312]=8'h00;zm[313]=8'h00;zm[314]=8'h00;zm[315]=8'h00;zm[316]=8'h00;zm[317]=8'h00;zm[318]=8'h00;zm[319]=8'h00;//!19

zm[320]=8'h08;zm[321]=8'h40;zm[322]=8'h31;zm[323]=8'h40;zm[324]=8'h22;zm[325]=8'h5E;zm[326]=8'h20;zm[327]=8'h82;
zm[328]=8'h27;zm[329]=8'h82;zm[330]=8'h20;zm[331]=8'hC2;zm[332]=8'hA9;zm[333]=8'h42;zm[334]=8'h65;zm[335]=8'h7E;
zm[336]=8'h22;zm[337]=8'h42;zm[338]=8'h24;zm[339]=8'h42;zm[340]=8'h28;zm[341]=8'h42;zm[342]=8'h21;zm[343]=8'hC2;
zm[344]=8'h22;zm[345]=8'h1F;zm[346]=8'h29;zm[347]=8'h00;zm[348]=8'h30;zm[349]=8'h00;zm[350]=8'h00;zm[351]=8'h00;//密20

zm[352]=8'h20;zm[353]=8'h40;zm[354]=8'h21;zm[355]=8'h80;zm[356]=8'h27;zm[357]=8'hFE;zm[358]=8'h3A;zm[359]=8'h08;
zm[360]=8'h22;zm[361]=8'h08;zm[362]=8'h23;zm[363]=8'hFC;zm[364]=8'h00;zm[365]=8'h00;zm[366]=8'h40;zm[367]=8'h10;
zm[368]=8'h4F;zm[369]=8'h10;zm[370]=8'h41;zm[371]=8'h10;zm[372]=8'h41;zm[373]=8'h10;zm[374]=8'h41;zm[375]=8'h12;
zm[376]=8'h7F;zm[377]=8'h11;zm[378]=8'h01;zm[379]=8'h02;zm[380]=8'h01;zm[381]=8'hFC;zm[382]=8'h00;zm[383]=8'h00;//码21

zm[384]=8'h02;zm[385]=8'h80;zm[386]=8'h0C;zm[387]=8'h80;zm[388]=8'hF7;zm[389]=8'hFE;zm[390]=8'h24;zm[391]=8'h84;
zm[392]=8'h26;zm[393]=8'h88;zm[394]=8'h12;zm[395]=8'h00;zm[396]=8'h12;zm[397]=8'hFF;zm[398]=8'hFE;zm[399]=8'h92;
zm[400]=8'h12;zm[401]=8'h92;zm[402]=8'h12;zm[403]=8'h92;zm[404]=8'h12;zm[405]=8'h92;zm[406]=8'hFE;zm[407]=8'h92;
zm[408]=8'h12;zm[409]=8'hFF;zm[410]=8'h12;zm[411]=8'h00;zm[412]=8'h02;zm[413]=8'h00;zm[414]=8'h00;zm[415]=8'h00;//错22

zm[416]=8'h02;zm[417]=8'h00;zm[418]=8'h42;zm[419]=8'h00;zm[420]=8'h33;zm[421]=8'hFE;zm[422]=8'h00;zm[423]=8'h04;
zm[424]=8'h00;zm[425]=8'h29;zm[426]=8'h01;zm[427]=8'h21;zm[428]=8'h79;zm[429]=8'h22;zm[430]=8'h49;zm[431]=8'h24;
zm[432]=8'h49;zm[433]=8'h28;zm[434]=8'h49;zm[435]=8'hF0;zm[436]=8'h49;zm[437]=8'h28;zm[438]=8'h49;zm[439]=8'h24;
zm[440]=8'h79;zm[441]=8'h22;zm[442]=8'h01;zm[443]=8'h21;zm[444]=8'h00;zm[445]=8'h21;zm[446]=8'h00;zm[447]=8'h00;//误23

zm[448]=8'h00;zm[449]=8'h00;zm[450]=8'h00;zm[451]=8'h09;zm[452]=8'h00;zm[453]=8'h0E;zm[454]=8'h00;zm[455]=8'h00;
zm[456]=8'h00;zm[457]=8'h00;zm[458]=8'h00;zm[459]=8'h00;zm[460]=8'h00;zm[461]=8'h00;zm[462]=8'h00;zm[463]=8'h00;//,24

zm[464]=8'h11;zm[465]=8'h90;zm[466]=8'h16;zm[467]=8'h98;zm[468]=8'hF8;zm[469]=8'h90;zm[470]=8'h13;zm[471]=8'hFF;
zm[472]=8'h10;zm[473]=8'hA0;zm[474]=8'h08;zm[475]=8'h00;zm[476]=8'h13;zm[477]=8'hFF;zm[478]=8'h2A;zm[479]=8'h48;
zm[480]=8'h4A;zm[481]=8'h49;zm[482]=8'h8B;zm[483]=8'hFF;zm[484]=8'h48;zm[485]=8'h00;zm[486]=8'h29;zm[487]=8'hFA;
zm[488]=8'h10;zm[489]=8'h01;zm[490]=8'h0B;zm[491]=8'hFE;zm[492]=8'h08;zm[493]=8'h00;zm[494]=8'h00;zm[495]=8'h00;//输25

zm[496]=8'h00;zm[497]=8'h01;zm[498]=8'h00;zm[499]=8'h02;zm[500]=8'h00;zm[501]=8'h04;zm[502]=8'h00;zm[503]=8'h08;
zm[504]=8'h00;zm[505]=8'h30;zm[506]=8'h80;zm[507]=8'hC0;zm[508]=8'h47;zm[509]=8'h00;zm[510]=8'h38;zm[511]=8'h00;
zm[512]=8'h07;zm[513]=8'h00;zm[514]=8'h00;zm[515]=8'hC0;zm[516]=8'h00;zm[517]=8'h30;zm[518]=8'h00;zm[519]=8'h0C;
zm[520]=8'h00;zm[521]=8'h02;zm[522]=8'h00;zm[523]=8'h01;zm[524]=8'h00;zm[525]=8'h01;zm[526]=8'h00;zm[527]=8'h00;//入26

zm[528]=8'h08;zm[529]=8'h40;zm[530]=8'h31;zm[531]=8'h40;zm[532]=8'h22;zm[533]=8'h5E;zm[534]=8'h20;zm[535]=8'h82;
zm[536]=8'h27;zm[537]=8'h82;zm[538]=8'h20;zm[539]=8'hC2;zm[540]=8'hA9;zm[541]=8'h42;zm[542]=8'h65;zm[543]=8'h7E;
zm[544]=8'h22;zm[545]=8'h42;zm[546]=8'h24;zm[547]=8'h42;zm[548]=8'h28;zm[549]=8'h42;zm[550]=8'h21;zm[551]=8'hC2;
zm[552]=8'h22;zm[553]=8'h1F;zm[554]=8'h29;zm[555]=8'h00;zm[556]=8'h30;zm[557]=8'h00;zm[558]=8'h00;zm[559]=8'h00;//密27

zm[560]=8'h20;zm[561]=8'h40;zm[562]=8'h21;zm[563]=8'h80;zm[564]=8'h27;zm[565]=8'hFE;zm[566]=8'h3A;zm[567]=8'h08;
zm[568]=8'h22;zm[569]=8'h08;zm[570]=8'h23;zm[571]=8'hFC;zm[572]=8'h00;zm[573]=8'h00;zm[574]=8'h40;zm[575]=8'h10;
zm[576]=8'h4F;zm[577]=8'h10;zm[578]=8'h41;zm[579]=8'h10;zm[580]=8'h41;zm[581]=8'h10;zm[582]=8'h41;zm[583]=8'h12;
zm[584]=8'h7F;zm[585]=8'h11;zm[586]=8'h01;zm[587]=8'h02;zm[588]=8'h01;zm[589]=8'hFC;zm[590]=8'h00;zm[591]=8'h00;//码28

zm[592]=8'h00;zm[593]=8'h00;zm[594]=8'h00;zm[595]=8'h0C;zm[596]=8'h00;zm[597]=8'h0C;zm[598]=8'h00;zm[599]=8'h00;
zm[600]=8'h00;zm[601]=8'h00;zm[602]=8'h00;zm[603]=8'h00;zm[604]=8'h00;zm[605]=8'h00;zm[606]=8'h00;zm[607]=8'h00;//.29

zm[608]=8'h00;zm[609]=8'h00;zm[610]=8'h00;zm[611]=8'h0C;zm[612]=8'h00;zm[613]=8'h0C;zm[614]=8'h00;zm[615]=8'h00;
zm[616]=8'h00;zm[617]=8'h00;zm[618]=8'h00;zm[619]=8'h00;zm[620]=8'h00;zm[621]=8'h00;zm[622]=8'h00;zm[623]=8'h00;//.30

zm[624]=8'h00;zm[625]=8'h00;zm[626]=8'h00;zm[627]=8'h0C;zm[628]=8'h00;zm[629]=8'h0C;zm[630]=8'h00;zm[631]=8'h00;
zm[632]=8'h00;zm[633]=8'h00;zm[634]=8'h00;zm[635]=8'h00;zm[636]=8'h00;zm[637]=8'h00;zm[638]=8'h00;zm[639]=8'h00;//.31

zm[640]=8'h00;zm[641]=8'h00;zm[642]=8'h02;zm[643]=8'h02;zm[644]=8'h42;zm[645]=8'h22;zm[646]=8'h22;zm[647]=8'h22;
zm[648]=8'h1A;zm[649]=8'h22;zm[650]=8'h02;zm[651]=8'h22;zm[652]=8'h02;zm[653]=8'h22;zm[654]=8'hFE;zm[655]=8'h22;
zm[656]=8'h02;zm[657]=8'h22;zm[658]=8'h02;zm[659]=8'h22;zm[660]=8'h0A;zm[661]=8'h22;zm[662]=8'h12;zm[663]=8'h22;
zm[664]=8'h63;zm[665]=8'hFF;zm[666]=8'h00;zm[667]=8'h00;zm[668]=8'h00;zm[669]=8'h00;zm[670]=8'h00;zm[671]=8'h00;//当31

zm[672]=8'h10;zm[673]=8'h00;zm[674]=8'h10;zm[675]=8'h00;zm[676]=8'h17;zm[677]=8'hFF;zm[678]=8'h94;zm[679]=8'h90;
zm[680]=8'h74;zm[681]=8'h92;zm[682]=8'h14;zm[683]=8'h91;zm[684]=8'h17;zm[685]=8'hFE;zm[686]=8'h10;zm[687]=8'h00;
zm[688]=8'h10;zm[689]=8'h00;zm[690]=8'h13;zm[691]=8'hF0;zm[692]=8'h30;zm[693]=8'h02;zm[694]=8'hD0;zm[695]=8'h01;
zm[696]=8'h17;zm[697]=8'hFE;zm[698]=8'h10;zm[699]=8'h00;zm[700]=8'h10;zm[701]=8'h00;zm[702]=8'h00;zm[703]=8'h00;//前32

zm[704]=8'h00;zm[705]=8'h01;zm[706]=8'h00;zm[707]=8'h02;zm[708]=8'h00;zm[709]=8'h04;zm[710]=8'h00;zm[711]=8'h08;
zm[712]=8'h00;zm[713]=8'h30;zm[714]=8'h00;zm[715]=8'hC0;zm[716]=8'h03;zm[717]=8'h00;zm[718]=8'hFC;zm[719]=8'h00;
zm[720]=8'h03;zm[721]=8'h00;zm[722]=8'h00;zm[723]=8'hC0;zm[724]=8'h00;zm[725]=8'h30;zm[726]=8'h00;zm[727]=8'h08;
zm[728]=8'h00;zm[729]=8'h04;zm[730]=8'h00;zm[731]=8'h02;zm[732]=8'h00;zm[733]=8'h01;zm[734]=8'h00;zm[735]=8'h00;//人33

zm[736]=8'h09;zm[737]=8'h41;zm[738]=8'h4A;zm[739]=8'h59;zm[740]=8'h2C;zm[741]=8'h6A;zm[742]=8'h08;zm[743]=8'hC6;
zm[744]=8'hFF;zm[745]=8'h44;zm[746]=8'h08;zm[747]=8'h4A;zm[748]=8'h2C;zm[749]=8'h71;zm[750]=8'h4A;zm[751]=8'h00;
zm[752]=8'h01;zm[753]=8'h01;zm[754]=8'h0E;zm[755]=8'h02;zm[756]=8'hF1;zm[757]=8'hCC;zm[758]=8'h10;zm[759]=8'h30;
zm[760]=8'h10;zm[761]=8'hCC;zm[762]=8'h1F;zm[763]=8'h02;zm[764]=8'h10;zm[765]=8'h01;zm[766]=8'h00;zm[767]=8'h00;//数34

zm[768]=8'h00;zm[769]=8'h00;zm[770]=8'h00;zm[771]=8'h00;zm[772]=8'h00;zm[773]=8'h00;zm[774]=8'h03;zm[775]=8'h0C;
zm[776]=8'h03;zm[777]=8'h0C;zm[778]=8'h00;zm[779]=8'h00;zm[780]=8'h00;zm[781]=8'h00;zm[782]=8'h00;zm[783]=8'h00;//:35

zm[784]=8'h02;zm[785]=8'h40;zm[786]=8'h02;zm[787]=8'h40;zm[788]=8'h01;zm[789]=8'h80;zm[790]=8'h0F;zm[791]=8'hF0;
zm[792]=8'h01;zm[793]=8'h80;zm[794]=8'h02;zm[795]=8'h40;zm[796]=8'h02;zm[797]=8'h40;zm[798]=8'h00;zm[799]=8'h00;//*36

zm[800]=8'h08;zm[801]=8'h20;zm[802]=8'h06;zm[803]=8'h20;zm[804]=8'h40;zm[805]=8'h7E;zm[806]=8'h31;zm[807]=8'h80;
zm[808]=8'h00;zm[809]=8'h02;zm[810]=8'h00;zm[811]=8'h7E;zm[812]=8'h7F;zm[813]=8'h42;zm[814]=8'h49;zm[815]=8'h42;
zm[816]=8'h49;zm[817]=8'h7E;zm[818]=8'h49;zm[819]=8'h42;zm[820]=8'h49;zm[821]=8'h7E;zm[822]=8'h49;zm[823]=8'h42;
zm[824]=8'h7F;zm[825]=8'h42;zm[826]=8'h00;zm[827]=8'h7E;zm[828]=8'h00;zm[829]=8'h02;zm[830]=8'h00;zm[831]=8'h00;//温37

zm[832]=8'h00;zm[833]=8'h02;zm[834]=8'h00;zm[835]=8'h0C;zm[836]=8'h3F;zm[837]=8'hF1;zm[838]=8'h24;zm[839]=8'h01;
zm[840]=8'h24;zm[841]=8'h21;zm[842]=8'h24;zm[843]=8'h32;zm[844]=8'h3F;zm[845]=8'hAA;zm[846]=8'hA4;zm[847]=8'hA4;
zm[848]=8'h64;zm[849]=8'hA4;zm[850]=8'h24;zm[851]=8'hA4;zm[852]=8'h3F;zm[853]=8'hAA;zm[854]=8'h24;zm[855]=8'h32;
zm[856]=8'h24;zm[857]=8'h01;zm[858]=8'h24;zm[859]=8'h01;zm[860]=8'h20;zm[861]=8'h01;zm[862]=8'h00;zm[863]=8'h00;//度38

zm[864]=8'h00;zm[865]=8'h00;zm[866]=8'h00;zm[867]=8'h00;zm[868]=8'h00;zm[869]=8'h00;zm[870]=8'h03;zm[871]=8'h0C;
zm[872]=8'h03;zm[873]=8'h0C;zm[874]=8'h00;zm[875]=8'h00;zm[876]=8'h00;zm[877]=8'h00;zm[878]=8'h00;zm[879]=8'h00;//:39

zm[880]=8'h00;zm[881]=8'h00;zm[882]=8'h00;zm[883]=8'h0C;zm[884]=8'h00;zm[885]=8'h0C;zm[886]=8'h00;zm[887]=8'h00;
zm[888]=8'h00;zm[889]=8'h00;zm[890]=8'h00;zm[891]=8'h00;zm[892]=8'h00;zm[893]=8'h00;zm[894]=8'h00;zm[895]=8'h00;//.40

zm[896]=8'h60;zm[897]=8'h00;zm[898]=8'h90;zm[899]=8'h00;zm[900]=8'h90;zm[901]=8'h00;zm[902]=8'h67;zm[903]=8'hE0;
zm[904]=8'h1F;zm[905]=8'hF8;zm[906]=8'h30;zm[907]=8'h0C;zm[908]=8'h20;zm[909]=8'h04;zm[910]=8'h40;zm[911]=8'h02;
zm[912]=8'h40;zm[913]=8'h02;zm[914]=8'h40;zm[915]=8'h02;zm[916]=8'h40;zm[917]=8'h02;zm[918]=8'h40;zm[919]=8'h02;
zm[920]=8'h20;zm[921]=8'h04;zm[922]=8'h78;zm[923]=8'h08;zm[924]=8'h00;zm[925]=8'h00;zm[926]=8'h00;zm[927]=8'h00;//℃41
end
 
//下一个状态确认
always @(*) begin
	if(!rst_n)
		next_state = WaitInit;
	else begin
		case(state)
			//等待模块使能
			WaitInit: if(en_ram_wr)begin 
					  	 if(inputing ==1'b1 && finish_flag==1'b0  )begin
							next_state = InputKey;
						 end 
						 else if(error_flag<=25'd5000000 && (success==1'b0 && finish_flag==1'b1))begin 
							next_state = Error;
						 end
						 else if(welcome_flag<=25'd5000000 && success==1'b1 && finish_flag==1'b1)begin 
							next_state = Welcome;
						 end
						 else begin
							next_state = WriteData;
						 end
					  end
					  else begin
						 next_state = WaitInit;
					  end
			//写数据
			WriteData: next_state = (cnt_zmw==9'd160) ? Done : WriteData;
			//数据写完成
			InputKey: 
				if(finish_flag==1'b1 && success==1'b1 )begin
					next_state = Clear;
				end
				else if(finish_flag==1'b1 && success==1'd0 )begin
					next_state = Clear;
				end
				else begin
					next_state = (cnt_zm==9'd160+16*key_num)? Done : InputKey;
				end
			
			Error:next_state = (cnt_zm==9'd160) ? Done : Error;
			
			Welcome: next_state = (cnt_zm==9'd160) ? Done : Welcome;
				
			Done: next_state = WaitInit;
			
			Clear:next_state = (cnt_zm==160+key_num*16) ? Done:Clear;
		endcase
	end
end

//每一个状态的逻辑变量赋值
always @(posedge clk,negedge rst_n) begin
	if(!rst_n) begin
		wren <= 1'b0;			//写使能信号复位
		data <= 8'd0;			//数据值复位
	end
	else begin
		case(state)
			WaitInit:begin
				wren <= 1'b0;	//等待模块使能状态 信号复位
				data <= 8'd0;
				
			end
			
			WriteData:begin
				wren <= 1'b1;	//写使能信号拉高
				if(cnt_zmw <= 143) begin
					data <= zm[cnt_zmw + 10'd640];//写到ram中的数据赋值
					end
				else if(cnt_zmw > 143 && cnt_zmw <= 159)begin
					data <= zm[cnt_zmw - 9'd144 + count*16];
					end
			end
			
			InputKey:begin
				wren <= 1'b1;	//写使能信号拉高
				if(cnt_zm<=159)begin
					data <= zm[cnt_zm + 10'd464];
				end
				else begin
				    data <= zm[(cnt_zm -9'd160)%16 + 10'd784];//写到ram中的数据赋值
				end
			end
			
			Error:begin
				wren <= 1'b1;	//写使能信号拉高
				if(cnt_zm <= 127) begin
					data <= zm[cnt_zm + 9'd320];//写到ram中的数据赋值
					end
				else begin
					data <= zm[cnt_zm%16 + 10'd272];
					end
				
			end
			
			Welcome:begin
				wren <= 1'b1;	//写使能信号拉高
				data <= zm[cnt_zm + 9'd160];//写到ram中的数据赋值
			end
			
			Done:begin
				wren <= 1'b0;
				data <= 8'd0;
			end	
			
			Clear:begin
				wren <= 1'b1;	//写使能信号拉高
				data <= zm[1'b0];//写到ram中的数据赋值
			end
		
		endcase
	end
 
end
 
//数据计数器计数
always @(posedge clk,negedge rst_n) begin
	if(!rst_n) begin
		cnt_zm <= 9'd0;//计数值复位
		cnt_zmw <= 9'd0;//计数值复位
		error_flag <= 9'd0;
		wraddress <= 10'd256+23;//地址复位，加入偏移量23，使得显示靠中间位置
	end
	else begin
		if(state==Error)begin
			error_flag <=  error_flag + 1'b1;
		end
		if(state==Welcome)begin
			welcome_flag <=  welcome_flag + 1'b1;
		end
		else if(state==InputKey)begin
			error_flag <= 9'd0;
			welcome_flag <= 9'd0;
		end
		
		case(cnt_zm)
			9'd158: cnt_zm <= 9'd1;		//第1页写完毕 转到第2页 //first page has been written 2 times
			9'd159: cnt_zm <= 9'd160;	//第2页写完毕 转到第3页
			160+key_num*16-2: cnt_zm <= 9'd161;	//第3页写完毕 转到第4页
			160+key_num*16-1: cnt_zm <= 160+key_num*16;	//第4页写完毕 转到第5页
			9'd482: cnt_zm <= 9'd321;	//第5页写完毕 转到第6页
			default:
				if(state == Done ||state == WaitInit)	
					cnt_zm <= 9'd0;
				else
					cnt_zm <= cnt_zm + 2'd2;//写数据状态下，计数器自增，加2是因为一个字模的高度为16，它本页的下一个数据应该在和当前数据间隔着一个
		endcase
		
		//页数说明：主要看你想把字体显示在哪一行
		case(cnt_zm)
			9'd1: wraddress<=10'd384+24;		//进入第2页，地址重新赋值，加入偏移量，显示靠中间位置
			9'd160: wraddress<=10'd512+48;	//进入第3页
			9'd161: wraddress<=10'd640+48;	//进入第4页
			160+key_num*16: wraddress<=10'd796;		//进入第5页
			9'd321: wraddress<=10'd800;		//进入第6页
			default:begin
				if(state==Done||state == WaitInit)				
					wraddress <= 10'd256+23; 
				else	
					wraddress <= wraddress + 1'b1;	//在写数据的时候地址加1
			end
		endcase
		
		///////////////////WriteData page /////////////////////////////////
		case(cnt_zmw)
			9'd158: cnt_zmw <= 9'd1;		//第1页写完毕 转到第2页 //two page was written at the number access 1
			9'd159: cnt_zmw <= 9'd160;	//第2页写完毕 转到第3页
			160+key_num*16-2: cnt_zmw <= 9'd161;	//第3页写完毕 转到第4页
			160+key_num*16-1: cnt_zmw <= 160+key_num*16;	//第4页写完毕 转到第5页
			9'd482: cnt_zmw <= 9'd321;	//第5页写完毕 转到第6页
			default:
				if(state == Done||state==WaitInit)	
					cnt_zmw <= 9'd0;
				else
					cnt_zmw <= cnt_zmw + 2'd2;//写数据状态下，计数器自增，加2是因为一个字模的高度为16，它本页的下一个数据应该在和当前数据间隔着一个
		endcase
		
		//页数说明：主要看你想把字体显示在哪一行
		case(cnt_zmw)
			9'd1: wraddress<=10'd384+24;		//进入第2页，地址重新赋值，加入偏移量，显示靠中间位置
			9'd160: wraddress<=10'd512+48;	//进入第3页
			9'd161: wraddress<=10'd640+48;	//进入第4页
			160+key_num*16: wraddress<=10'd796;		//进入第5页
			9'd321: wraddress<=10'd800;		//进入第6页
			default:begin
				if(state==Done||state==WaitInit)				
					wraddress <= 10'd256+23;
				else	
					wraddress <= wraddress + 1'b1;	//在写数据的时候地址加1
			end
		endcase
		
	end
end
 
//状态转换
always @(posedge clk,negedge rst_n) begin
	if(!rst_n)
		state <= WaitInit;
	else
		state <= next_state;
end
 
endmodule