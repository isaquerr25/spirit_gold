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
extern string id_ordem = "dark_save";
extern string id_find_server = "black";
extern string Atributo_Pares = "";
extern bool Auto_Lots = true;
extern int MAGICNUMBER = 100046;
extern int MAGICNUMBERCORRECT = 12;
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
extern string urlK = "http://185.227.110.67:80/";
extern string endereco = "185.227.110.67";
extern int porta_ = 80;
extern double  porcent_start = 15;
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
    if(MAGICNUMBER == MAGICNUMBERCORRECT ){
        Alert("Numeros magicos precisam ser diferentes");
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
    Comment("Porcentagem Geral Da conta: "+DoubleToString(porcent_corrent(),2)+" % \n "+
        "Porcenta das ordens MAGICNUMBERCORRECT:%"+DoubleToString(somaPer(MAGICNUMBERCORRECT),2)+
        "\n Porcenta das ordens MAGICNUMBER:%"+DoubleToString(somaPer(MAGICNUMBER),2)
        );
    //---
    // principal();
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
    //---
    limpar();
    string myIP = httpGET(urlK + "api/custom/"+Symbol()+"/"+id_find_server+"/"+(string)AccountInfoInteger(ACCOUNT_LOGIN)+"/");

    if (myIP !=resultadoserver)
    {
        LerMensagem();
        pegasinal(myIP);
        send_db_historico(myIP);
        resultadoserver = myIP;
    }
    bool revisar = false;
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
void pegasinal(string myIP)
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
            if (json["base_sinais"][i]["typeOrder"].ToStr() != "normal"){

                estaNatList = true;
            }
            if (json["base_sinais"][i]["status"].ToStr() != "abertura")
            {
                estaNatList = true;
            }
            if (!estaNatList && !trava_entrada_banca_baixa)
            {
               Alert("aaaaaaassswwwaaaaa,", estaNatList);
            }
            if (json["base_sinais"][i]["abertura"].ToStr() != id_find_server)
            {
                estaNatList = true;
            }
            if (!estaNatList && !trava_entrada_banca_baixa)
            {
               Alert("aaaaaaaaaaaa," ,estaNatList);
            }
            if (log_histoSTR != "" || log_histoSTR == "-1")
            {
                estaNatList = true;
            }
            if (!estaNatList && !trava_entrada_banca_baixa)
            {
               Alert("aaaaaa," ,estaNatList);
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
               Alert("estaNatList,", estaNatList);
                int get_ticket;

                if(somaPer(MAGICNUMBER) <= (porcent_start * (-1))){

                    get_ticket = abertura_ordem(
                        "correct",
                        json["base_sinais"][i]["par"].ToStr() + Atributo_Pares,
                        json["base_sinais"][i]["abertura"].ToStr(),
                        "0",
                        "0",
                        json["base_sinais"][i]["direcao"].ToStr(),
                        NormalizeDouble(StringToDouble(json["base_sinais"][i]["lots"].ToStr()),2),
                        MAGICNUMBERCORRECT,
                        true
                        );

                }else{
                    get_ticket = StrToInteger(json["base_sinais"][i]["ticket"].ToStr());
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
double porcent_corrent()
{
    double deposit = AccountInfoDouble(ACCOUNT_BALANCE);
    double corrent = AccountInfoDouble(ACCOUNT_PROFIT);
    double porcent = ((deposit + corrent) / deposit * 100)-100;

    return (deposit);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int abertura_ordem(string _id, string par, string abertura, string stop_win, string stop_loss, string direc, double lote, int magic,bool reverse)
{
    int order;
    string _direction = direc;
    //Alert(_direction);
    if(reverse){
        if(_direction == "buy"){
            _direction = "sell";
        }else
        {
            _direction = "buy";
        }
    }
    RefreshRates();
    if (_direction == "buy")
    {
        //Print("entrooooo", par);
        RefreshRates();
        order = OrderSend(par, OP_BUY, lote, Ask, 0, 0, 0, _id, magic, 0, clrBlueViolet);
        return (order);
    }
    if (_direction == "sell")
    {
        //Print("entr_______", par);
        order = OrderSend(par, OP_SELL, lote, Ask, 0, 0, 0, _id, magic, 0, clrBlueViolet);
        return (order);
        RefreshRates();
    }
    return (0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double somaNumberMagic(int magi){
    double valor_capitado = 0;
    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (OrderSelect(i, SELECT_BY_POS) == false)
            continue;
        if (OrderMagicNumber() == magi && OrderSymbol() == Symbol())
        {
            valor_capitado += OrderProfit();
        }
    }
    return(valor_capitado);
}

double somaPer(int magi){
    double valor_capitado = 0;
    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (OrderSelect(i, SELECT_BY_POS) == false)
            continue;
        if (OrderMagicNumber() == magi && OrderSymbol() == Symbol())
        {
            valor_capitado += OrderProfit();
        }
    }
    double deposit = AccountInfoDouble(ACCOUNT_BALANCE);
    double porcent = ((deposit + valor_capitado) / deposit * 100)-100;
    return(porcent);
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
                    verific = OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrBlueViolet);
                    //Alert("o jsomn asssssssssssssssssssss",idcorrent);
                    //Alert("fechamento");
                }
                RefreshRates();
                MensagemHistorico((string)OrderTicket(), idcorrent);
            }
        }
    }
    if(fechou__)
    {
        double asdff = conta(valor_capitado);
    }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void limpar()
{
    int enrodo = 0;
    for (int i = 0; i < OrdersTotal(); i++)
    {

        if (OrderSelect(i, SELECT_BY_POS) == false)
            continue;
        if (OrderMagicNumber() == MAGICNUMBER && OrderSymbol() == Symbol())
        {
            enrodo = OrdersTotal();
        }
    }
    if(enrodo ==0)
    {
        int file_handle=FileOpen(id_ordem+"_1550.txt",FILE_WRITE|FILE_TXT);
        if(file_handle!=INVALID_HANDLE)
        {
            FileFlush(file_handle);
            FileClose(file_handle);
        }
        else
        {
            Print("não funcionou");
            PrintFormat("Error, code = %d",GetLastError());
        }
        file_handle=FileOpen(id_ordem+"_1557.txt",FILE_WRITE|FILE_TXT);
        FileFlush(file_handle);
        FileClose(file_handle);
        file_handle=FileOpen(id_ordem+"_1556.txt",FILE_WRITE|FILE_TXT);
        FileFlush(file_handle);
        FileClose(file_handle);
        Print("limpou ",Symbol());
    }
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
