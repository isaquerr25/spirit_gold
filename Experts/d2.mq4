//+------------------------------------------------------------------+
//|                                                  GOLD SPIRIT.mq4 |
//|                                                   Copyright 2021 |
//|                                     DEVELOPER ISAQUE R. FERREIRA |
//+------------------------------------------------------------------+

#property copyright "Copyright 2021"
#property version "1.00"
#property link "https://t.me/isaquerr25"
#property description "DEVELOPER ISAQUE R. FERREIRA"
#property description "Mais info"
#property link "https://t.me/isaquerr25"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 DarkOrchid

//+------------------------------------------------------------------+A
//| Expert variaveis                                                 |
//+------------------------------------------------------------------+
#include <mql4-http.mqh>
double ma21_ant, ma9, ma21, ma9_ant;
double resultado_r = 0.0;
datetime ctm[1];
datetime LastTime;
double lot, slv, tpv;
string id_ordem = "GPFPAIDlIFETIME";
//extern string Atributo_Pares = "";
//extern bool Auto_Lots = true;
extern int MAGICNUMBER = 100046;
datetime limite_operation;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include <ghttp.mqh>
#include <JAson.mqh>
#include <Arrays\ArrayObj.mqh>
#include <Web.mqh>
string db_id[1];
string db_historico = "";
string pares_bloquados[];
string bank_ticks[1];
bool status__account = false;
bool trava_entrada_banca_baixa = false;
extern double entrada = 0.10;
//extern string urlK = "http://185.227.110.67:80/";
//extern string endereco = "185.227.110.67";
//extern int porta_ = 80;
#import "Wininet.dll"
int InternetOpenW(string, int, string, string, int);
int InternetConnectW(int, string, int, string, string, int, int, int);
int InternetOpenUrlW(int, string, string, int, int, int);
int InternetReadFile(int, string, int, int &OneInt[]);
int InternetCloseHandle(int);
int HttpOpenRequestW(int, string, string, string, string, string, int, int);
bool HttpSendRequestW(int, string, int, string, int);


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HttpSendRequestW(int hRequest, string lpszHeaders, int dwHeadersLength, char &lpOptional[], int dwOptionalLength);

#import "Kernel32.dll"
bool MoveFileExW(string &lpExistingFileName, string &lpNewFileName, int dwFlags);
#import
#define MOVEFILE_REPLACE_EXISTING 0x1
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string resultadoserver;
extern bool trailing_stop = true;
extern double trailing_stop_value_pip = 500;
//extern bool gold_trocado = false;
//extern float camadas_de_stop= 2;
//extern float camadas_de_take= 2;
//extern int conjunto_de_velas= 8;
extern bool takeProft= true;
int estagio = 0;
double line_buy = 0;
double line_sell = 0;
double line_topo = 0;
double line_fundo = 0;
bool estavaDentro = false;
extern double stop_min= 220;
extern double entrada_acima= 10;
double openprice = 0;
extern double multap= 1.10;
extern double max_lot= 0.9;
double lot_em_andamento= 0;
//extern bool entra_reverso=true;

extern bool trava_no_zero=true;
extern double trava_no_zero_distance= 200;
extern double trava_no_zero_pip= 100;

int OnInit()
{
    /*int  fileHandle =0;
    if(!FileIsExist(id_ordem+"_1550.txt",0))
    {
        //Print("File Not _1550, Regenerating....." );
        fileHandle     =    FileOpen(id_ordem+"_1550.txt" , FILE_READ|FILE_WRITE|FILE_TXT);
        FileWriteString(fileHandle,"");  
        FileClose(fileHandle);

        //Print("File Not _1557, Regenerating....." );
        fileHandle     =    FileOpen(id_ordem+"_1557.txt" , FILE_READ|FILE_WRITE|FILE_TXT);
        FileWriteString(fileHandle,"");  
        FileClose(fileHandle);

        //Print("File Not _1556, Regenerating....." );
        fileHandle     =    FileOpen(id_ordem+"_1556.txt" , FILE_READ|FILE_WRITE|FILE_TXT);
        FileWriteString(fileHandle,"");  
        FileClose(fileHandle);
    
        
    }*/
      datetime compilation_date=__DATE__;
      datetime NY=D'2021.10.01 00:00'; 
    if(NY < compilation_date)
    { 
        
        //status__account = conta();
        if (!status__account)
        {
            Alert(status__account);
            Alert(limite_operation);
            Alert("Sua conta não é valida ou sem conexão como servidor");
            Alert("Chame no Telegram +5566999791203");
            ExpertRemove();
        }
    }
    //Print("!!Atenção não coloque o robo em outros Pares!!");

    //
    // buono dei test //

    // pegasinal();
    HideTestIndicators(true);
    EventSetTimer(60);
    
    for (int i = 0; i < OrdersTotal(); i++)
    {

        if (OrderSelect(i, SELECT_BY_POS) == false)
            continue;
        if (OrderMagicNumber() == MAGICNUMBER && OrderSymbol() == Symbol())
        {
            estagio = 2;
            //while(ArraySize(ids_ordens) < i) 
            //    ArrayResize(ids_ordens, ArraySize(ids_ordens) + 1);
            //Alert(ArraySize(ids_ordens), i ," vamos ver");
            //ids_ordens[i] = OrderTicket();
        }
    }


    //---
    return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    //--- destroy timer
    ObjectsDeleteAll(0);
    EventKillTimer();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
      
    bool temRodando = false;
    if(trava_no_zero)
    {
        
        travaZero(trava_no_zero_pip,MAGICNUMBER,trava_no_zero_distance);
    }
    if(trailing_stop)
    {
        
        tStop(trailing_stop_value_pip,MAGICNUMBER);
    }
   /* if(estagio == 0 && entra_reverso)
    {
        if(vaiAoContario())
        {
            openprice = Open[1];
            estagio=2;
        }
    }*/
    if(estagio == 0)
    {
        //ObjectsDeleteAll(0);
        if(workBar())
        {
            openprice = Open[1];
            estagio=1;
            //Print("estagio ",estagio);
        }
            
    }
    if(line_buy != High[1]  &&   line_sell != Low[1] && !temRodando && openprice != Open[1])
    {
        Print(line_buy ," tAMANAHO MAX ",High[1],"LLLL ", line_sell," TAMANHO MIN ",Low[1]);
        line_buy = 0;
        line_sell =0;
        estagio=0;
    }
    else
    {
        //Alert("entrou no fecha ");
        for (int i = 0; i < OrdersTotal(); i++)
        {

            if (OrderSelect(i, SELECT_BY_POS) == false)
                continue;
            if (OrderMagicNumber() == MAGICNUMBER && OrderSymbol() == Symbol())
            {
                temRodando = true;
            }
        }
        if(!temRodando && estagio ==1)
        {
            if(trabalha_entrada(line_buy,line_sell))
            {
                estagio=2;
                //Print("estagio ",estagio);
            }    
        }
    } 
    temRodando = false;
    /*
    if((line_sell-(line_sell-line_buy) > Close[0] || line_buy+(line_sell-line_buy) < Close[0]) && (estagio==2) && !temRodando)
        estagio=0;
        */
    //---
    // principal();
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
   datetime compilation_date=__DATE__;
   datetime NY=D'2021.10.01 00:00'; 
    if(NY < compilation_date)
    { 
        
        //status__account = conta();
        if (!status__account)
        {
            Alert(status__account);
            Alert(limite_operation);
            Alert("Sua conta não é valida ou sem conexão como servidor");
            Alert("Chame no Telegram +5566999791203");
            ExpertRemove();
        }
    }
    //---
    /*
    string myIP = httpGET(urlK + "velho/custom/"+Symbol()+"/"+id_ordem+"/"+(string)AccountInfoInteger(ACCOUNT_LOGIN)+"/");
    if (myIP !=resultadoserver)
    {
        LerMensagem();
        pegasinal();
        resultadoserver = myIP;
    }
    if(limite_operation < __DATE__)
    {
        status__account = conta();
        if (!status__account)
        {
            Alert("Sua conta não é valida ou sem conexão como servidor");
            Alert("Chame no Telegram +5566999791203");
            ExpertRemove();
        }
    }
    */

    //Print("asddddddd");

    /*
    if(estagio == 0)
    {
        if(workBar())
            estagio=1;
    }
    else
    {
        bool temRodando = false;

    //Alert("entrou no fecha ");
        for (int i = 0; i < OrdersTotal(); i++)
        {

            if (OrderSelect(i, SELECT_BY_POS) == false)
                continue;
            if (OrderMagicNumber() == MAGICNUMBER && OrderSymbol() == Symbol())
            {
                temRodando = true;
            }
        }
        if(!temRodando && estagio ==1)
        {
            if(trabalha_entrada(line_sell,line_buy,line_fundo,line_topo))
                estagio=2;
        }
        else if(!temRodando && estagio ==2)
        {   
            estagio = 0;
            ObjectsDeleteAll(0);
        }
    } 
    */
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    //---
}
//+------------------------------------------------------------------+

bool workBar()
{
    double preco_max = 0;
    double preco_min = 0;
    bool deu_errado = false;
    bool jaCriou = false;
    int count= 0;
    int ja_foi = 0;
    int addPontos =0;
    int jarodouTudo = 0;
   

    if(High[1] != line_buy)
    {
        line_buy = High[1]; 
        jaCriou = true;
    }
    if(Low[1] != line_sell)
    {
        line_sell = Low[1]; 
        jaCriou = true;
    }
    return(jaCriou);
}
bool trabalha_entrada(double price_buy,double price_sell)
{
    bool fez = false;
    if(Ask>price_buy+(entrada_acima*Point))
    {
        abertura_ordem("spirit fima", Symbol(), "string abertura", Ask-(stop_min*Point),0, "BUY", calcula_entrada());
        fez = true;
    }
    if(Bid<price_sell-(entrada_acima*Point))
    {
        abertura_ordem("spirit fima", Symbol(), "string abertura", Bid+(stop_min*Point),0, "SELL", calcula_entrada());
        fez = true;
    }
    return(fez);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool vaiAoContario()
{
    bool fez = false;

    double arrecado =0; 
    int cont_dentro =0;
    string direc = "";
    for(int i=0;i<OrdersHistoryTotal();i++) 
    { 
     //---- check selection result 
        if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) continue;
        
        if(OrderMagicNumber()==MAGICNUMBER)
        {
            cont_dentro++;
            if(cont_dentro >1)
            {
                
                arrecado+=OrderProfit();
                 switch (OrderType())
                {
                case 1:
                direc = ("sell");
                break;
                case 0:
                direc = ("buy");
                break;
                default:
                break;
                }
            }

        }
    }
    if(arrecado<0)
        if(direc =="sell")
        {
            abertura_ordem("spirit fima", Symbol(), "string abertura", Ask-(stop_min*Point),0, "BUY", calcula_entrada());
            fez = true;
        }
        else
        {
            abertura_ordem("spirit fima", Symbol(), "string abertura", Bid+(stop_min*Point),0, "SELL", calcula_entrada());
            fez = true;
        }
    return(fez);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*void pegasinal()
{
    string out = "";

    CJAVal json(NULL, jtUNDEF);
    string myIP = httpGET(urlK + "velho/customs/"+id_ordem+"/");
    json.Deserialize(myIP);
    int i = 0;
    bool estaNatList = false;
    CJAVal histo(NULL, jtUNDEF);
    histo.Deserialize(Lerreversa());
    while (i <= 100)
    {
        estaNatList = false;
        
        string log_histoSTR = histo[(string)json["base_sinais"][i]["id"].ToStr()].ToStr();

        

        string asda = json["base_sinais"][i]["par"].ToStr();
        if (json["base_sinais"][i]["par"].ToStr() == "final")
        {
            estaNatList = true;
        }
        if (asda != "" && asda != NULL)
        {
            for (int x = 0; x < ArraySize(pares_bloquados); x++)
            {
                //Print(pares_bloquados[x], json["base_sinais"][i]["par"].ToStr());
                if (pares_bloquados[x] == json["base_sinais"][i]["par"].ToStr())
                {
                    estaNatList = true;
                }
            }
       
            if (json["base_sinais"][i]["abertura"].ToStr() != id_ordem)
            {
                estaNatList = true;
            }
            if (log_histoSTR != "" || log_histoSTR == "-1")
            {
                estaNatList = true;
            }
            for (int x = 0; x < ArraySize(db_id); x++)
            {

                if (db_id[x] == json["base_sinais"][i]["id"].ToStr())
                {
                    estaNatList = true;
                }
            }
            if (!estaNatList && !trava_entrada_banca_baixa)
            {
                 int get_ticket;
                if (gold_trocado && (json["base_sinais"][i]["par"].ToStr()) == "GOLD")
                {
                    get_ticket = abertura_ordem(
                        "SPIRIT",
                        "XAUUSD" + Atributo_Pares,
                        json["base_sinais"][i]["abertura"].ToStr(),
                        StringToDouble(json["base_sinais"][i]["stop_win"].ToStr()),
                        StringToDouble(json["base_sinais"][i]["stop_loss"].ToStr()),
                        json["base_sinais"][i]["direcao"].ToStr(),
                        entrada);
                }
                else
                {
                    get_ticket = abertura_ordem(
                        "SPIRIT",
                        json["base_sinais"][i]["par"].ToStr() + Atributo_Pares,
                        json["base_sinais"][i]["abertura"].ToStr(),
                        StringToDouble(json["base_sinais"][i]["stop_win"].ToStr()),
                        StringToDouble(json["base_sinais"][i]["stop_loss"].ToStr()),
                        json["base_sinais"][i]["direcao"].ToStr(),
                        entrada);
                }
                if (get_ticket != -1)
                {
                    Mensagem((string)get_ticket, json["base_sinais"][i]["id"].ToStr());
                    ArrayResize(db_id, ArraySize(db_id) + 1);

                    db_id[ArraySize(db_id) - 1] = json["base_sinais"][i]["id"].ToStr();
                }
                Mensagemreversa((string)json["base_sinais"][i]["id"].ToStr(), (string)get_ticket);

            }
        }
        else
        {
            break;
        }

        i++;
    }
}*/
/*
bool conta(double capitado = 0)
{
    bool volta = false;
    CJAVal json_(NULL, jtUNDEF);

    string js = "{\"nome\":\"" + AccountInfoString(ACCOUNT_NAME) + "\",\"conta\":\"" + 
                    (string)AccountInfoInteger(ACCOUNT_LOGIN) + "\",\"invest\":\"" + 
                    (string)(AccountInfoDouble(ACCOUNT_BALANCE) + AccountInfoDouble(ACCOUNT_CREDIT) + AccountInfoDouble(ACCOUNT_PROFIT)) + 
                    "\",\"lucro_ordem\":\""+(string)capitado+"\"}";
    string state_db = httpPost("nem ta usando mais isso", 80, "access_account", js);

    json_.Deserialize(state_db);
    string data_db = json_["data_atualizacao"].ToStr();
    limite_operation = D''+StringReplace(data_db,"-",".");
    if (json_["status_vencimento"] == "True")
    {
        //Comment("Conta validada \n Todos os sinais serão abertos sem necessidade de abrir outros pares");
        volta = true;
    }
    return (volta);
}*/

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int abertura_ordem(string _id, string par, string abertura, double stop_loss, double stop_win, string direc, double lote)
{
    int order;
    string _direction = direc;
    //Alert(_direction);
    RefreshRates();
    Print(_id," par ",par," abertura ",abertura," stop_win ", NP(stop_win+Point)," stop_loss ",NP(stop_loss+Point)," direc ",direc," lote",lote, " point ",Point() );
    if (takeProft)
    {
        if (_direction == "BUY")
        {
            //Print("entrooooo", par);Digits
            int order = OrderSend(par, OP_BUY, lote, Ask, 0,  stop_loss, 0, "spirit", MAGICNUMBER, 0, clrBlueViolet);
            //order = OrderSend(par, OP_BUY, lote, Ask, 0, 0,0, "spirit", MAGICNUMBER, 0, clrBlueViolet);
            if(order<0) 
            { 
            //Print("OrderSend failed with error #",GetLastError()); 
            estagio = 0;
            } 
            else 
            //Print("OrderSend placed successfully"); 
            return (order);
        }
        if (_direction == "SELL")
        {
            //Print("entr_______", par);
            order = OrderSend(par, OP_SELL, lote, Bid, 0,  stop_loss,  0, "spirit", MAGICNUMBER, 0, clrBlueViolet);
            //order = OrderSend(par, OP_SELL, lote, Ask, 0, 0, 0, "spirit", MAGICNUMBER, 0, clrBlueViolet);
            if(order<0) 
            { 
            //Print("OrderSend failed with error #",GetLastError()); 
            estagio = 0;
            } 
            return (order);
            RefreshRates();
            
        }
    }
    else
    {
        if (_direction == "BUY")
        {
            //Print("entrooooo", par);Digits
            int order = OrderSend(par, OP_BUY, lote, Ask, 0,  NormalizeDouble(stop_loss+Point,Digits), 0, "spirit", MAGICNUMBER, 0, clrBlueViolet);
            //order = OrderSend(par, OP_BUY, lote, Ask, 0, 0,0, "spirit", MAGICNUMBER, 0, clrBlueViolet);
            if(order<0) 
            { 
            //Print("OrderSend failed with error #",GetLastError()); 
            estagio = 0;
            } 
            else 
            //Print("OrderSend placed successfully"); 
            return (order);
        }
        if (_direction == "SELL")
        {
            //Print("entr_______", par);
            order = OrderSend(par, OP_SELL, lote, Bid, 0,  NormalizeDouble(stop_loss+Point,Digits),  0, "spirit", MAGICNUMBER, 0, clrBlueViolet);
            //order = OrderSend(par, OP_SELL, lote, Ask, 0, 0, 0, "spirit", MAGICNUMBER, 0, clrBlueViolet);
            if(order<0) 
            { 
            //Print("OrderSend failed with error #",GetLastError()); 
            estagio = 0;
            } 
            return (order);
            RefreshRates();
            
        }
    }
    return (0);
}

double NP(double price)
{
   double tickSize = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
   return (NormalizeDouble(price+Point,Digits));
}
double calcula_entrada()
{
    double arrecado =0; 
    int cont_dentro =0;
    for(int i=0;i<OrdersHistoryTotal();i++) 
    { 
     //---- check selection result 
        if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) continue;
        
        if(OrderMagicNumber()==MAGICNUMBER)
        {
            cont_dentro++;
            if(cont_dentro >10)
            {
                
                arrecado+=OrderProfit();
                
                
            }
        }
    }
    if(arrecado<0)
    {
        if(lot_em_andamento<max_lot)
        {
            lot_em_andamento=lot_em_andamento*multap;
            //Comment("ENTRADA (",lot_em_andamento,")");
        }
        else
        {
            lot_em_andamento=max_lot;
        }
    }
    else
    {
        lot_em_andamento = entrada;
    }
   return (NormalizeDouble(lot_em_andamento,2));
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void limpar()
{
   int file_handle=FileOpen(id_ordem+"_1550.txt",FILE_READ|FILE_WRITE|FILE_TXT); 
   FileFlush(file_handle); 
   FileClose(file_handle);
   file_handle=FileOpen(id_ordem+"_1557.txt",FILE_READ|FILE_WRITE|FILE_TXT); 
   FileFlush(file_handle); 
   FileClose(file_handle);
}
void Mensagem(string dict_, string atributo_)
{

    while (True)
    {
        int h = FileOpen(id_ordem+"_1550.txt", FILE_READ | FILE_WRITE | FILE_ANSI | FILE_TXT);
        if (h == INVALID_HANDLE)
        {
            //Print("Não pode enviar o sinal para ser protocolado");
        }
        else
        {
            FileSeek(h, 0, SEEK_END);
            FileWrite(h, "{\"" + dict_ + "\":\"" + atributo_ + "\"}");
            FileClose(h);
            break;
        }
    }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MensagemHistorico(string dict_, string atributo_)
{

    while (True)
    {
        int h = FileOpen(id_ordem+"_1556.txt", FILE_READ | FILE_WRITE | FILE_ANSI | FILE_TXT);
        if (h == INVALID_HANDLE)
        {
            //Print("Não pode enviar o sinal para ser protocolado");
        }
        else
        {
            FileSeek(h, 0, SEEK_END);
            FileWrite(h, "{\"" + (string)dict_ + "\":\"" + (string)atributo_ + "\"}");
            FileClose(h);
            break;
        }
    }
}

void travaZero(int stop, int MN,int dista)// Symbol + stop in pips + magic number
{


    for(int i=OrdersTotal()-1; i>=0; i--)
    {
        
        if (OrderSelect(i, SELECT_BY_POS) == false)
            continue;
        
        double bsl=NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID)-stop*MarketInfo(OrderSymbol(),MODE_POINT),MarketInfo(OrderSymbol(),MODE_DIGITS));
        
        double ssl=NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK)+stop*MarketInfo(OrderSymbol(),MODE_POINT),MarketInfo(OrderSymbol(),MODE_DIGITS));
        
        

        if(OrderMagicNumber()==MN)
            
            if(OrderType()==OP_BUY && (OrderStopLoss()<bsl || OrderStopLoss()==0) && OrderOpenPrice()+stop*MarketInfo(OrderSymbol(),MODE_POINT)< (MarketInfo(OrderSymbol(),MODE_ASK)))
            {    
                if(OrderStopLoss() < OrderOpenPrice() && Ask > OrderOpenPrice()+NP(dista*Point))
                    if(OrderModify(OrderTicket(),OrderOpenPrice(),bsl,OrderTakeProfit(),0,clrNONE))
                    {
                        //Print(OrderSymbol()+" Buy's Stop Trailled to "+(string)bsl);
                        }else{
                        //Print(OrderSymbol()+" Buy's Stop Trail ERROR");
                    }
            }
            else if(OrderType()==OP_SELL && (OrderStopLoss()>ssl || OrderStopLoss()==0)   && OrderOpenPrice()-stop*MarketInfo(OrderSymbol(),MODE_POINT)> (MarketInfo(OrderSymbol(),MODE_BID)))
                
                if(OrderStopLoss() > OrderOpenPrice() && Bid < OrderOpenPrice()+(dista*Point))
                    if(OrderModify(OrderTicket(),OrderOpenPrice(),ssl,OrderTakeProfit(),0,clrNONE))
                    {
                        //Print(OrderSymbol()+" Sell's Stop Trailled to "+(string)ssl);
                        }else{
                        //Print(OrderSymbol()+" Sell's Stop Trail ERROR");
                    }
    }
}


void tStop(int stop, int MN)// Symbol + stop in pips + magic number
{


    for(int i=OrdersTotal()-1; i>=0; i--)
    {
        
        if (OrderSelect(i, SELECT_BY_POS) == false)
            continue;
        
        double bsl=NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID)-stop*MarketInfo(OrderSymbol(),MODE_POINT),MarketInfo(OrderSymbol(),MODE_DIGITS));
        
        double ssl=NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK)+stop*MarketInfo(OrderSymbol(),MODE_POINT),MarketInfo(OrderSymbol(),MODE_DIGITS));
        
        if(OrderMagicNumber()==MN)
            if(OrderType()==OP_BUY && (OrderStopLoss()<bsl || OrderStopLoss()==0) && OrderOpenPrice()+stop*MarketInfo(OrderSymbol(),MODE_POINT)< (MarketInfo(OrderSymbol(),MODE_ASK)))
            {    
                if(OrderModify(OrderTicket(),OrderOpenPrice(),bsl,OrderTakeProfit(),0,clrNONE))
                {
                    //Print(OrderSymbol()+" Buy's Stop Trailled to "+(string)bsl);
                    }else{
                    //Print(OrderSymbol()+" Buy's Stop Trail ERROR");
                }
            }
            else if(OrderType()==OP_SELL && (OrderStopLoss()>ssl || OrderStopLoss()==0)   && OrderOpenPrice()-stop*MarketInfo(OrderSymbol(),MODE_POINT)> (MarketInfo(OrderSymbol(),MODE_BID)))
                if(OrderModify(OrderTicket(),OrderOpenPrice(),ssl,OrderTakeProfit(),0,clrNONE))
                {
                    //Print(OrderSymbol()+" Sell's Stop Trailled to "+(string)ssl);
                    }else{
                    //Print(OrderSymbol()+" Sell's Stop Trail ERROR");
                }
    }
}

/*
void Mensagemreversa(string dict_, string atributo_)
{

    while (True)
    {
        int h = FileOpen(id_ordem+"_1557.txt", FILE_READ | FILE_WRITE | FILE_ANSI | FILE_TXT);
        if (h == INVALID_HANDLE)
        {
            //Print("Não pode enviar o sinal para ser protocolado");
        }
        else
        {
            FileSeek(h, 0, SEEK_END);
            FileWrite(h, "{\"" + (string)dict_ + "\":\"" + (string)atributo_ + "\"}");
            FileClose(h);
            break;
        }
    }
}*/
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//string backHistorico(string id_)
//{
//
//    string fg = httpPost(endereco, porta_, "get_to_id", id_);
//
//    return (fg);
//}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//string httpPost(string strUrl, int port, string idxfile = "get_to_id", string identi_op = "")
//{
//    //Alert("Request");
//    string headers = "Content-Type: application/json";
//    string js;
//    if (idxfile == "get_to_id")
//        js = "{\"id\":" + identi_op + "}";
//    else
//        js = identi_op;
//    uchar data[];
//    uchar result[];
//    string result_hdr;
//
//    StringToCharArray(js, data);
//
//    int HttpOpen = hSession(false);
//    string serve_header = "";
//    char resultado[];
//    int offget;
//    if (idxfile == "access_account")
//    {
//        offget = WebRequest(
//            "POST",                                        // HTTP method
//            "http://" + endereco + ":80/userk/" + idxfile, // URL
//            headers,                                       // headers
//            100000000,                                     // timeout
//            data,                                          // the array of the HTTP message body
//            result,                                        // an array containing server response data
//            result_hdr                                     // headers of server response
//        );
//    }
//    else
//    {
//        offget = WebRequest(
//            "POST",                                      // HTTP method
//            "http://" + endereco + ":80/velho/" + idxfile, // URL
//            headers,                                     // headers
//            100000000,                                   // timeout
//            data,                                        // the array of the HTTP message body
//            result,                                      // an array containing server response data
//            result_hdr                                   // headers of server response
//        );
//    }
//    // Alert("Error when trying to call APIU* : ", GetLastError());
//
//    string DOTStr = CharArrayToString(result, 0);
//    // Alert("Veio do server ,",DOTStr);
//    /*
//   int err = GetLastError();
//
//   if(err>0)Print ("Last MSDN Error =: ",err);
//
//   int read[1];
//
//
//
//
//   InternetCloseHandle(HttpOpen);
//
//   InternetCloseHandle(HttpRequest);
//   InternetCloseHandle(result);
//   InternetCloseHandle(HttpConnect);*/
//    return (DOTStr);
//}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
void LerMensagem()
{
    int f = FileOpen(id_ordem+"_1550.txt", FILE_READ | FILE_TXT);
    int i = 0;
    string str;
    while (FileIsEnding(f) == False)
    {
        str = FileReadString(f);
        db_historico = db_historico + str;
        StringReplace(str, "}", "");
        StringReplace(str, "{", "");
        StringReplace(str, ",", "");
        StringReplace(str, "\"", "");
        StringSubstr(str, StringFind(str, ":"), StringLen(str));
        ArrayResize(db_id, ArraySize(db_id) + 1);
        db_id[i] = str;
        i++;
    }
    StringReplace(db_historico, "}", "");
    StringReplace(db_historico, "{", "");
    db_historico = "{" + db_historico + "}";
    FileClose(f);
}*/
/*
string LerHistorico()
{
    int f = FileOpen(id_ordem+"_1556.txt", FILE_READ | FILE_TXT);
    int i = 0;
    string str;
    string backString = "";
    while (FileIsEnding(f) == False)
    {
        str = FileReadString(f);
        backString = backString + str;
    }
    StringReplace(backString, "}", "");
    StringReplace(backString, "{", "");
    backString = "{" + backString + "}";
    FileClose(f);
    return (backString);
}

string Lerreversa()
{
    int f = FileOpen(id_ordem+"_1557.txt", FILE_READ | FILE_TXT);
    int i = 0;
    string str;
    string backString = "";
    while (FileIsEnding(f) == False)
    {
        str = FileReadString(f);
        backString = backString + str;
    }
    StringReplace(backString, "}", "");
    StringReplace(backString, "{", "");
    backString = "{" + backString + "}";
    FileClose(f);
    return (backString);
}*/

void makeLine(double preco_criacao,string obj_name)
{
    
    
    //--- creating label object (it does not have time/price coordinates) 
    Print(preco_criacao);
    if(!ObjectCreate(obj_name,OBJ_HLINE,0,0,preco_criacao)) 
        { 
        Print("Error: can't create label! code #",GetLastError()); 
        } 
   
}
