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
extern string id_ordem = "FXBANK";
extern string Atributo_Pares = "";
bool Auto_Lots = true;
extern int MAGICNUMBER = 100;
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
extern string urlK = "http://185.227.110.67:80/";
extern string endereco = "185.227.110.67";
extern int porta_ = 80;
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
bool trailing_stop = true;
double trailing_stop_value_pip = 500;
bool gold_trocado = false;
extern int control_cicle = 30;
extern double x_spread = 2.5;
enum ouro_s
{
    GOLD=0,
    XAUUSD=1

};
input ouro_s ouro=GOLD;

enum prata_s
{
    PRATA=0,
    XAGUSD=1

};
input prata_s prata=PRATA;
int OnInit()
{
    int  fileHandle =0;
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
        fileHandle     =    FileOpen(id_ordem+"_1555.txt" , FILE_READ|FILE_WRITE|FILE_TXT);
        FileWriteString(fileHandle,"");  
        FileClose(fileHandle);
    }

    //Print("!!Atenção não coloque o robo em outros Pares!!");

    //
    // buono dei test //

    // pegasinal();
    HideTestIndicators(TRUE);
    EventSetTimer(control_cicle);

    //---
    return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    //--- destroy timer
    EventKillTimer();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    //---
    // principal();
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
    //---
    string myIP = httpGET(urlK + "velho/customs/"+id_ordem+"/");
    Comment(myIP);
    if (myIP !=resultadoserver)
    {
        LerMensagem();
        fecha_ou_move(myIP);
        pegasinal(myIP);
        resultadoserver = myIP;
    }

    //Print("asddddddd");
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void pegasinal(string myIP )
{
    string out = "";
    CJAVal json(NULL, jtUNDEF);
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
        if (json["base_sinais"][i]["status"].ToStr() != "abertura")
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
                        get_ticket = abertura_ordem(
                        "SPIRIT",
                        json["base_sinais"][i]["par"].ToStr() + Atributo_Pares,
                        json["base_sinais"][i]["abertura"].ToStr(),
                        StringToDouble(json["base_sinais"][i]["stop_win"].ToStr()),
                        StringToDouble(json["base_sinais"][i]["stop_loss"].ToStr()),
                        json["base_sinais"][i]["direcao"].ToStr(),
                        entrada,
                        StringToDouble(json["base_sinais"][i]["preco"].ToStr())
                        );
                
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
}

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
        Comment("Conta validada \n Todos os sinais serão abertos sem necessidade de abrir outros pares");
        volta = true;
    }
    return (volta);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int abertura_ordem(string _id, string par, string abertura, double stop_loss, double stop_win, string direc, double lote, double preco)
{
    int order;
    string _direction = direc;
    //Alert(_direction);
    RefreshRates();
    par = vr_par(par);
    if (stop_loss >0)
        stop_loss = NP(stop_loss,par);

    if (stop_win >0)
        stop_win = NP(stop_win,par);
        
    preco = NP(preco,par);
    
    Print(_id," par ",par," abertura ",preco," stop_win ",stop_win," stop_loss ",stop_loss," direc ",direc," lote",lote, " point ",Point());
    if (_direction == "BUY")
    {
        //Print("entrooooo", par);
        RefreshRates();

        order = OrderSend(par, OP_BUY, lote, preco, 0, stop_win , stop_loss, "spirit", MAGICNUMBER, 0, clrBlueViolet);
        RefreshRates();
        if(order==-1)
        {
            order = OrderSend(par, OP_BUYLIMIT, lote, preco, 0, stop_win , stop_loss, "spirit", MAGICNUMBER, 0, clrBlueViolet);
            RefreshRates();
        }
        if(order==-1)
        {
            order = OrderSend(par, OP_BUYSTOP, lote, preco, 0, stop_win , stop_loss, "spirit", MAGICNUMBER, 0, clrBlueViolet);
            RefreshRates();
        }
        //order = OrderSend(par, OP_BUY, lote, Ask, 0, 0,0, "spirit", MAGICNUMBER, 0, clrBlueViolet);
        RefreshRates();
        return (order);
    }
    if (_direction == "SELL")
    {
        //Print("entr_______", par);
        RefreshRates();

        order = OrderSend(par, OP_SELL, lote, preco, 0, stop_win , stop_loss, "spirit", MAGICNUMBER, 0, clrBlueViolet);
        RefreshRates();
        if(order==-1)
        {
            order = OrderSend(par, OP_SELLLIMIT, lote, preco, 0, stop_win , stop_loss, "spirit", MAGICNUMBER, 0, clrBlueViolet);
            RefreshRates();
        }
        if(order==-1)
        {
            order = OrderSend(par, OP_SELLSTOP, lote, preco, 0, stop_win , stop_loss, "spirit", MAGICNUMBER, 0, clrBlueViolet);
            RefreshRates();
        }
        return (order);
        RefreshRates();
    }
    return (0);
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

void MensagemHistoricomove(string dict_, string atributo_)
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

double NP(double price,string moeda)
{
    //NormalizeDouble( ,MarketInfo(moeda,MODE_DIGITS))
    //double tickSize = SymbolInfoDouble(moeda, SYMBOL_TRADE_TICK_SIZE);
    return (NormalizeDouble(price+Point,MarketInfo(moeda,MODE_DIGITS)));
}

string vr_par(string moeda)
{
 
    
    
    if ((moeda) == "GOLD"+Atributo_Pares)
        {
            StringReplace(moeda, Atributo_Pares, "");
            if(ouro ==0)
            {
                return("GOLD"+Atributo_Pares);
            }
            else
            {
                return("XAUUSD"+Atributo_Pares);
            }
        }
        if ((moeda) == "PRATA"+Atributo_Pares)
        {
            StringReplace(moeda, Atributo_Pares, "");
            if(prata ==0)
            {
                return("PRATA"+Atributo_Pares);
            }
            else
            {
                return("XAGUSD"+Atributo_Pares);
            }
        }
    
    return (moeda);
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
                    Print(OrderSymbol()+" Buy's Stop Trailled to "+(string)bsl);
                    }else{
                    Print(OrderSymbol()+" Buy's Stop Trail ERROR");
                }
            }
            else if(OrderType()==OP_SELL && (OrderStopLoss()>ssl || OrderStopLoss()==0)   && OrderOpenPrice()-stop*MarketInfo(OrderSymbol(),MODE_POINT)> (MarketInfo(OrderSymbol(),MODE_BID)))
                if(OrderModify(OrderTicket(),OrderOpenPrice(),ssl,OrderTakeProfit(),0,clrNONE))
                {
                    Print(OrderSymbol()+" Sell's Stop Trailled to "+(string)ssl);
                    }else{
                    Print(OrderSymbol()+" Sell's Stop Trail ERROR");
                }
    }
}

bool travaZero(int tick)// Symbol + stop in pips + magic number
{
    for(int i=OrdersTotal()-1; i>=0; i--)
    {
        
        if (OrderSelect(i, SELECT_BY_POS) == false)
            continue;
        if (tick!=OrderTicket())
            continue;
        int stop = MarketInfo(OrderSymbol(), MODE_SPREAD);
        double bsl=NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID)-stop*MarketInfo(OrderSymbol(),MODE_POINT),MarketInfo(OrderSymbol(),MODE_DIGITS));
        
        double ssl=NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK)+stop*MarketInfo(OrderSymbol(),MODE_POINT),MarketInfo(OrderSymbol(),MODE_DIGITS));
        int MN = MAGICNUMBER;
        if(OrderMagicNumber()==MN)
            
            if(OrderType()==OP_BUY && (OrderStopLoss()<OrderOpenPrice()))
            {    
                if(OrderModify(OrderTicket(),OrderOpenPrice(),NP(OrderOpenPrice()+((MarketInfo(OrderSymbol(), MODE_SPREAD)*x_spread)),OrderSymbol()),OrderTakeProfit(),0,clrNONE))
                {
                    return(true);
                    //Print(OrderSymbol()+" Buy's Stop Trailled to "+(string)bsl);
                    }else{
                        return(false);
                    //Print(OrderSymbol()+" Buy's Stop Trail ERROR");
                }
            }
            else if(OrderType()==OP_SELL && (OrderStopLoss()>OrderOpenPrice()))
                
                if(OrderModify(OrderTicket(),OrderOpenPrice(),NP(OrderOpenPrice()-((MarketInfo(OrderSymbol(), MODE_SPREAD)*x_spread)),OrderSymbol()),OrderTakeProfit(),0,clrNONE))
                {
                    return(true);
                    //Print(OrderSymbol()+" Buy's Stop Trailled to "+(string)bsl);
                    }else{
                        return(false);
                    //Print(OrderSymbol()+" Buy's Stop Trail ERROR");
                }
    }
    return(false);
}


void fecha_ou_move(string myIP)
{
    bool fechou__ = false;
    double valor_capitado = 0;
    //Print("nnnnn");
    bool estaNatList = false;
    CJAVal json(NULL, jtUNDEF);
    json.Deserialize(myIP);
    
    //retorar futuramento o histórico de quanto ganhou
    bool temRodando = false;
    int ids_ordens[1];
    //Alert("entrou no fecha ");
    for (int i = 0; i < OrdersTotal(); i++)
    {

        if (OrderSelect(i, SELECT_BY_POS) == false)
            continue;
        if (OrderMagicNumber() == MAGICNUMBER && OrderSymbol() == Symbol())
        {
            temRodando = true;
            //while(ArraySize(ids_ordens) < i) 
            //    ArrayResize(ids_ordens, ArraySize(ids_ordens) + 1);
            //Alert(ArraySize(ids_ordens), i ," vamos ver");
            //ids_ordens[i] = OrderTicket();
        }
    }
    //Alert(ids_ordens[i]);
    CJAVal banco_tiket(NULL, jtUNDEF);
    banco_tiket.Deserialize(db_historico);
    CJAVal log_historico(NULL, jtUNDEF);
    log_historico.Deserialize(LerHistorico());
    
    CJAVal move_json(NULL, jtUNDEF);
    move_json.Deserialize(LerHistoricoMove());

    for (int x = 0; x < OrdersTotal(); x++)
    {

        if (OrderSelect(x, SELECT_BY_POS) == false)
            continue;
       // if (OrderSelect(ids_ordens[x], SELECT_BY_TICKET) == false)
       // {
       //     //Alert("não deu ");
       //     continue;
       // }
        //Print("EM RODO000000000 ccccccccccccccccccccc->",x);
        //Alert("EM RODO000000000 ->",ids_ordens[x]);
        
        if (OrderMagicNumber() == MAGICNUMBER)
        {
            bool estaNatList_ = false;
            //Alert("EM RODO ->",ids_ordens[x]);
            string str_move = move_json[(string)OrderTicket()].ToStr();

            string asd = banco_tiket[(string)OrderTicket()].ToStr();
            string log_histoSTR = log_historico[(string)OrderTicket()].ToStr();

            if (log_histoSTR == "" || log_histoSTR == NULL)
            {
                estaNatList = false;
            }
            else
            {
                estaNatList = true;
            }
            //Alert("1");
            string idcorrent = "";
            if (asd != "" && asd != NULL)
            {
                int i = 0;
                while (i < 300)
                {
                    string asda = json["base_sinais"][i]["par"].ToStr();
                    if (json["base_sinais"][i]["par"].ToStr() == "final")
                    {
                        i = 500;
                    }
                    if (asda == "" && asda == NULL)
                    {
                        i = 500;
                    }
                    
                    if (json["base_sinais"][i]["id"].ToStr() == (string)asd && (json["base_sinais"][i]["status"].ToStr() == "close" || json["base_sinais"][i]["status"].ToStr() == "modif"))
                    {
                       
                        idcorrent = (string)json["base_sinais"][i]["id"].ToStr();
                        if(json["base_sinais"][i]["status"].ToStr() == "modif")
                            if (str_move != "" && str_move != NULL)
                            {
                                if(travaZero(OrderTicket()))
                                {
                                    MensagemHistorico((string)OrderTicket(), idcorrent);
                                }
                                else
                                {
                                    continue;
                                }
                            }
                            else
                            {
                                continue;
                            }
                        estaNatList_ = true;

                        i = 500;
                    }
                    i += 1;
                }
            }
            //Alert("2");
            if (asd != "" && asd != NULL && !estaNatList && estaNatList_)
            {
                
                x = 0;
                valor_capitado += OrderProfit();
                fechou__ = true;
                bool verific = false;
                RefreshRates();
                int ghcccc = 0;
                while (!verific)
                {
                    verific = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(),MODE_ASK), 3, clrBlueViolet);
                    if(!verific)
                    {
                        verific = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(),MODE_BID), 3, clrBlueViolet);
                    }
                    //Alert("o jsomn asssssssssssssssssssss",idcorrent);
                    //Alert("fechamento");
                    ghcccc +=1;
                    if(ghcccc=5)
                    {
                        MensagemHistorico((string)OrderTicket(), idcorrent);
                        break;
                    }
                }
                RefreshRates();
                MensagemHistorico((string)OrderTicket(), idcorrent);
            }
        }
    }
}





void send_db_historico(string myIP)
{
    bool fechou__ = false;
    double valor_capitado = 0;
    //Print("nnnnn");
    bool estaNatList = false;
    CJAVal json(NULL, jtUNDEF);
    json.Deserialize(myIP);
    //retorar futuramento o histórico de quanto ganhou
    bool temRodando = false;
    int ids_ordens[1];
    //Alert("entrou no fecha ");
    for (int i = 0; i < OrdersTotal(); i++)
    {

        if (OrderSelect(i, SELECT_BY_POS) == false)
            continue;
        if (OrderMagicNumber() == MAGICNUMBER && OrderSymbol() == Symbol())
        {
            temRodando = true;
            //while(ArraySize(ids_ordens) < i) 
            //    ArrayResize(ids_ordens, ArraySize(ids_ordens) + 1);
            //Alert(ArraySize(ids_ordens), i ," vamos ver");
            //ids_ordens[i] = OrderTicket();
        }
    }
    //Alert(ids_ordens[i]);
    CJAVal banco_tiket(NULL, jtUNDEF);
    banco_tiket.Deserialize(db_historico);
    CJAVal log_historico(NULL, jtUNDEF);
    log_historico.Deserialize(LerHistorico());
    
    for (int x = 0; x < OrdersTotal(); x++)
    {

        if (OrderSelect(x, SELECT_BY_POS) == false)
            continue;
       // if (OrderSelect(ids_ordens[x], SELECT_BY_TICKET) == false)
       // {
       //     //Alert("não deu ");
       //     continue;
       // }
        //Print("EM RODO000000000 ccccccccccccccccccccc->",x);
        //Alert("EM RODO000000000 ->",ids_ordens[x]);
        
        if (OrderMagicNumber() == MAGICNUMBER && OrderSymbol() == Symbol())
        {
            bool estaNatList_ = false;
            //Alert("EM RODO ->",ids_ordens[x]);
            
            string asd = banco_tiket[(string)OrderTicket()].ToStr();
            string log_histoSTR = log_historico[(string)OrderTicket()].ToStr();

            if (log_histoSTR == "" || log_histoSTR == NULL)
            {
                estaNatList = false;
            }
            else
            {
                estaNatList = true;
            }
            //Alert("1");
            string idcorrent = "";
            if (asd != "" && asd != NULL)
            {
                int i = 0;
                while (i < 300)
                {
                    string asda = json["base_sinais"][i]["par"].ToStr();
                    if (json["base_sinais"][i]["par"].ToStr() == "final")
                    {

                        i = 500;
                    }
                    if (asda == "" && asda == NULL)
                        i = 500;

                    if (json["base_sinais"][i]["id"].ToStr() == asd && json["base_sinais"][i]["status"].ToStr() == "fechamento")
                    {
                        estaNatList_ = true;
                        idcorrent = (string)json["base_sinais"][i]["id"].ToStr();
                        i = 500;
                    }
                    i += 1;
                }
            }
            //Alert("2");
            if (asd != "" && asd != NULL && !estaNatList && estaNatList_)
            {
                x = 0;
                valor_capitado += OrderProfit();
                fechou__ = true;
                bool verific = false;
                RefreshRates();
                while (!verific)
                {
                    verific = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(),MODE_ASK), 3, clrBlueViolet);
                    //Alert("o jsomn asssssssssssssssssssss",idcorrent);
                    //Alert("fechamento");
                }
                RefreshRates();
                MensagemHistorico((string)OrderTicket(), idcorrent);
            }
        }
    }
}




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
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string backHistorico(string id_)
{

    string fg = httpPost(endereco, porta_, "get_to_id", id_);

    return (fg);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string httpPost(string strUrl, int port, string idxfile = "get_to_id", string identi_op = "")
{
    //Alert("Request");
    string headers = "Content-Type: application/json";
    string js;
    if (idxfile == "get_to_id")
        js = "{\"id\":" + identi_op + "}";
    else
        js = identi_op;
    uchar data[];
    uchar result[];
    string result_hdr;

    StringToCharArray(js, data);

    int HttpOpen = hSession(false);
    string serve_header = "";
    char resultado[];
    int offget;
    if (idxfile == "access_account")
    {
        offget = WebRequest(
            "POST",                                        // HTTP method
            "http://" + endereco + ":80/userk/" + idxfile, // URL
            headers,                                       // headers
            100000000,                                     // timeout
            data,                                          // the array of the HTTP message body
            result,                                        // an array containing server response data
            result_hdr                                     // headers of server response
        );
    }
    else
    {
        offget = WebRequest(
            "POST",                                      // HTTP method
            "http://" + endereco + ":80/velho/" + idxfile, // URL
            headers,                                     // headers
            100000000,                                   // timeout
            data,                                        // the array of the HTTP message body
            result,                                      // an array containing server response data
            result_hdr                                   // headers of server response
        );
    }
    // Alert("Error when trying to call APIU* : ", GetLastError());

    string DOTStr = CharArrayToString(result, 0);
    // Alert("Veio do server ,",DOTStr);
    /*
   int err = GetLastError();

   if(err>0)Print ("Last MSDN Error =: ",err);

   int read[1];




   InternetCloseHandle(HttpOpen);

   InternetCloseHandle(HttpRequest);
   InternetCloseHandle(result);
   InternetCloseHandle(HttpConnect);*/
    return (DOTStr);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
}
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

string LerHistoricoMove()
{
    int f = FileOpen(id_ordem+"_1555.txt", FILE_READ | FILE_TXT);
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
}
