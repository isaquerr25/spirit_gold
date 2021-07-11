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
extern string id_ordem = "GPFPAIDlIFETIME";
extern string Atributo_Pares = "";
extern bool Auto_Lots = true;
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
extern bool trailing_stop = true;
extern double trailing_stop_value_pip = 500;
extern bool gold_trocado = false;
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
    }

    if(limite_operation < __DATE__)
    { 
        
        status__account = conta();
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
    HideTestIndicators(TRUE);
    EventSetTimer(60);

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
    if(trailing_stop)
    {
        
        tStop(trailing_stop_value_pip,MAGICNUMBER);
    }
    //---
    // principal();
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
    //---
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
void pegasinal()
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
int abertura_ordem(string _id, string par, string abertura, double stop_loss, double stop_win, string direc, double lote)
{
    int order;
    string _direction = direc;
    //Alert(_direction);
    RefreshRates();
    Print(_id," par ",par," abertura ",abertura," stop_win ",stop_win," stop_loss ",stop_loss," direc ",direc," lote",lote, " point ",Point() );
    if (_direction == "BUY")
    {
        //Print("entrooooo", par);
        RefreshRates();
        order = OrderSend(par, OP_BUY, lote, Ask, 0, stop_win +Point(), stop_loss+Point(), "spirit", MAGICNUMBER, 0, clrBlueViolet);
        //order = OrderSend(par, OP_BUY, lote, Ask, 0, 0,0, "spirit", MAGICNUMBER, 0, clrBlueViolet);
        
        return (order);
    }
    if (_direction == "SELL")
    {
        //Print("entr_______", par);
        order = OrderSend(par, OP_SELL, lote, Ask, 0, stop_win+Point(), stop_loss+Point(), "spirit", MAGICNUMBER, 0, clrBlueViolet);
        //order = OrderSend(par, OP_SELL, lote, Ask, 0, 0, 0, "spirit", MAGICNUMBER, 0, clrBlueViolet);
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
