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

//+------------------------------------------------------------------+
//| Expert variaveis                                                 |
//+------------------------------------------------------------------+
#include <mql4-http.mqh>
double ma21_ant, ma9, ma21, ma9_ant;
double resultado_r = 0.0;
datetime ctm[1];
datetime LastTime;
double lot, slv, tpv;
extern string id_ordem = "dark";
extern string Atributo_Pares = "";
extern bool Auto_Lots = true;
extern double Lots_GOLD = 0.1;
extern int MAGICNUMBER = 100046;
extern double Lots = 0.1; /*Lots*/ // Lot
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
extern string urlK = "http://147.135.80.138:80/";
extern string endereco = "147.135.80.138";
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
int OnInit()
{
    int  fileHandle =0;
    if(!FileIsExist(id_ordem+"_1550.txt",0))
    {
        Print("File Not _1550, Regenerating....." );
        fileHandle     =    FileOpen(id_ordem+"_1550.txt" , FILE_READ|FILE_WRITE|FILE_TXT);
        FileWriteString(fileHandle,"");  
        FileClose(fileHandle);

        Print("File Not _1557, Regenerating....." );
        fileHandle     =    FileOpen(id_ordem+"_1557.txt" , FILE_READ|FILE_WRITE|FILE_TXT);
        FileWriteString(fileHandle,"");  
        FileClose(fileHandle);

        Print("File Not _1556, Regenerating....." );
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
    Alert("!!Atenção não coloque o robo em outros Pares!!");

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
    //---
    // principal();
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
    //---

    LerMensagem();
    send_db_historico();
    pegasinal();
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
    Print("asddddddd");
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
    string myIP = httpGET(urlK + "api/custom/"+Symbol()+"/"+id_ordem+"/");
    json.Deserialize(myIP);
    int i = 0;
    bool estaNatList = false;
    while (true)
    {
        estaNatList = false;
        CJAVal histo(NULL, jtUNDEF);
        histo.Deserialize(Lerreversa());
        string log_histoSTR = histo[(string)json["base_sinais"][i]["id"].ToStr()].ToStr();

        json.Deserialize(myIP);

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
            if (json["base_sinais"][i]["status"].ToStr() != "abertura")
            {
                estaNatList = true;
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

            if (Auto_Lots)
            {
                Lots = NormalizeDouble(StringToDouble(json["base_sinais"][i]["lots"].ToStr()), 2);
            }
            if (!estaNatList && !trava_entrada_banca_baixa)
            {
                int get_ticket;

                get_ticket = abertura_ordem(
                    "fghfghfghf",
                    json["base_sinais"][i]["par"].ToStr() + Atributo_Pares,
                    json["base_sinais"][i]["abertura"].ToStr(),
                    0,
                    0,
                    json["base_sinais"][i]["direcao"].ToStr(),
                    typeAccount(StringToDouble(json["base_sinais"][i]["lots"].ToStr())));

                if (get_ticket != -1)
                {
                    Mensagem((string)get_ticket, json["base_sinais"][i]["id"].ToStr());
                    ArrayResize(db_id, ArraySize(db_id) + 1);

                    db_id[ArraySize(db_id) - 1] = json["base_sinais"][i]["id"].ToStr();
                }
                Mensagemreversa((string)json["base_sinais"][i]["id"].ToStr(), (string)get_ticket);
            }
        }
        else if (i > 20)
        {
            break;
        }
        if (i >= 100)
            break;

        i++;
    }
}
double typeAccount(double valor)
{
    double total = AccountInfoDouble(ACCOUNT_BALANCE) + AccountInfoDouble(ACCOUNT_CREDIT) + AccountInfoDouble(ACCOUNT_PROFIT);
    int tipeAccount_ = 0;
    // Start of the 'sdy
    if (total < 2000)
        tipeAccount_ = 1; // Variations..
    else if (total > 1999 && total < 3000)
        tipeAccount_ = 2;
    else if (total > 2999 && total < 4000)
        tipeAccount_ = 3;
    else if (total > 3999 && total < 10000)
        tipeAccount_ = 4;
    else if (total > 9999 && total < 12000)
        tipeAccount_ = 5;
    else
        tipeAccount_ = 6;

    Alert("tipo de conta ", tipeAccount_);
    return (backLot(valor, tipeAccount_));
}
double backLot(double valor, int contaType)
{
    double valor_ = valor;
    if(Symbol() == "GOLD"+Atributo_Pares ||    Symbol() == "XAUUSD"+Atributo_Pares )
    {
        if (contaType == 1)
        {
            if (valor_ > 0.15)
                valor_ = 0.15;
            else
                valor_ = valor;
        }
        else if (contaType == 2)
        {
            if (valor_ > 0.15)
                valor_ = 0.15;
            else
                valor_ = valor;
        }
        else if (contaType == 3)
        {
            if (valor_ > 0.18)
                valor_ = 0.18;
            else
                valor_ = valor;
        }
        else if (contaType == 4)
        {
            if (valor_ > 0.20)
                valor_ = 0.20;
            else
                valor_ = valor;
        }
        else if (contaType == 5)
        {
            if (valor_ > 0.20)
                valor_ = 0.20;
            else
                valor_ = valor;
        }
        else
        {
            if (valor_ > 0.20)
                valor_ = 0.20;
            else
                valor_ = valor;
        }
    }
    else
    {
        if (contaType == 1)
        {
            if (valor_ > 1.20)
                valor_ = 1.20;
            else
                valor_ = valor;
        }
        else if (contaType == 2)
        {
            if (valor_ > 2.0)
                valor_ = 2.0;
            else
                valor_ = valor;
        }
        else if (contaType == 3)
        {
            if (valor_ > 3.0)
                valor_ = 3.0;
            else
                valor_ = valor;
        }
        else if (contaType == 4)
        {
            if (valor_ > 4.0)
                valor_ = 4.0;
            else
                valor_ = valor;
        }
        else if (contaType == 5)
        {
            if (valor_ > 6.0)
                valor_ = 6.0;
            else
                valor_ = valor;
        }
        else
        {
            if (valor_ > 8.0)
                valor_ = 8.0;
            else
                valor_ = valor;
        }
    }
    return (NormalizeDouble((valor_), 2));
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
int abertura_ordem(string _id, string par, string abertura, string stop_win, string stop_loss, string direc, double lote)
{
    int order;
    string _direction = direc;
    //Alert(_direction);
    RefreshRates();
    if (_direction == "buy")
    {
        Alert("entrooooo", par);
        RefreshRates();
        order = OrderSend(par, OP_BUY, lote, Ask, 0, 0, 0, "_id", MAGICNUMBER, 0, clrBlueViolet);
        return (order);
    }
    if (_direction == "sell")
    {
        Alert("entr_______", par);
        order = OrderSend(par, OP_SELL, lote, Ask, 0, 0, 0, "_id", MAGICNUMBER, 0, clrBlueViolet);
        return (order);
        RefreshRates();
    }
    return (0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void send_db_historico()
{
    bool fechou__ = false;
    double valor_capitado = 0;
    Alert("nnnnn");
    bool estaNatList = false;
    CJAVal json(NULL, jtUNDEF);
    string myIP = httpGET(urlK + "api/custom/"+Symbol()+"/"+id_ordem+"/");
    json.Deserialize(myIP);
    //retorar futuramento o histórico de quanto ganhou
    bool temRodando = false;
    for (int i = 0; i < OrdersTotal(); i++)
    {

        if (OrderSelect(i, SELECT_BY_POS) == false)
            continue;
        if (OrderMagicNumber() == MAGICNUMBER)
            temRodando = true;
    }
    if(!temRodando)
    {
        limpar();
    }
    for (int i = 0; i < OrdersTotal(); i++)
    {

        if (OrderSelect(i, SELECT_BY_POS) == false)
            continue;
        if (OrderMagicNumber() == MAGICNUMBER)
        {
            int i = 0;
            bool estaNatList_ = false;

            CJAVal banco_tiket(NULL, jtUNDEF);
            banco_tiket.Deserialize(db_historico);
            string asd = banco_tiket[(string)OrderTicket()].ToStr();
            Alert(asd);
            CJAVal log_historico(NULL, jtUNDEF);
            log_historico.Deserialize(LerHistorico());
            string log_histoSTR = log_historico[(string)OrderTicket()].ToStr();

            Alert(asd, "  ", json["base_sinais"][i]["id"].ToStr());

            bool estaNatList = false;
            if (log_histoSTR == "" || log_histoSTR == NULL)
            {
                estaNatList = false;
            }
            else
            {
                estaNatList = true;
            }
            string idcorrent = "";
            if (asd != "" && asd != NULL)
            {

                while (true)
                {

                    CJAVal histo(NULL, jtUNDEF);
                    histo.Deserialize(Lerreversa());
                    string log_histoSTR = histo[(string)json["base_sinais"][i]["id"].ToStr()].ToStr();

                    json.Deserialize(myIP);

                    string asda = json["base_sinais"][i]["par"].ToStr();
                    if (json["base_sinais"][i]["par"].ToStr() == "final")
                    {

                        break;
                    }
                    if (asda == "" && asda == NULL)
                        break;

                    if (json["base_sinais"][i]["id"].ToStr() == asd && json["base_sinais"][i]["status"].ToStr() == "fechamento")
                    {
                        Alert("passou");
                        estaNatList_ = true;
                        idcorrent = (string)json["base_sinais"][i]["id"].ToStr();
                        break;
                    }

                    if (i > 1000)
                        break;
                    i += 1;
                }
            }
            Alert(OrderTicket());
            if (asd != "" && asd != NULL && !estaNatList && estaNatList_)
            {
                valor_capitado += OrderProfit();
                fechou__ = true;
                Alert("ndddddn");
                bool verific = false;
                while (!verific)
                {
                    verific = OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrBlueViolet);

                    // Alert("o jsomn asssssssssssssssssssss",get_status_server["id"].ToStr());

                    //Alert("o jsomn asdddddd");
                }
                MensagemHistorico((string)OrderTicket(), idcorrent);
            }
        }
    }
    if(fechou__)
    {
        conta(valor_capitado);
    }   
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
            "http://" + endereco + ":80/api/" + idxfile, // URL
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
