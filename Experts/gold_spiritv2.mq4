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
extern string id_entrada = "5";
extern string Atributo_Pares = "";
extern int MAGICNUMBER = 100046;
extern double Lots = 0.1;
extern double Lots_exponenvical = 1.2;
extern double Lots_max = 0.2;
extern double Prof_dolar_min = 1.0;
double Lot_s_change = Lots;
double Lot_rotativo= Lots;
bool flag_close_order = false;
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
int porta_ = 80;
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
    status__account = conta();
    if (!status__account)
    {
        Alert("Sua conta não é valida ou sem conexão como servidor");
        Alert("Chame no Telegram +5566999791203");
        ExpertRemove();
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
    // 
    if(flag_close_order)
    {
        string verifica  = corrent_profit();
        if( verifica == "fechado")
        {
            flag_close_order =false;
        }
    }
    LerMensagem();
    pegasinal();
    

}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
    //---
    if(flag_close_order)
    {
        string verifica  = corrent_profit();
        if( verifica == "fechado")
        {
            flag_close_order =false;
        }
    }
    LerMensagem();
    pegasinal();
    status__account = conta();

    if (!status__account)
    {
        Alert("Sua conta não é valida");
        Alert("Chame no Telegram +5566999791203");
        ExpertRemove();
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
    LerMensagem();
    pegasinal();
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void pegasinal()
{
    string out = "";

    CJAVal json(NULL, jtUNDEF);
    //string myIP = httpGET(urlK + "api/get__sinal");
    string myIP = httpGET(urlK + "api/custom/"+Symbol()+"/"+id_entrada+"/");
    
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
            if ((string)(asda + Atributo_Pares) != (string)Symbol())
            {
                estaNatList = true;
            }
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
                Alert("chegou");
                int get_ticket;
                
                get_ticket = get_enter(json["base_sinais"][i]["direcao"].ToStr());

                if (get_ticket != -1)
                {
                    Mensagem((string)get_ticket, json["base_sinais"][i]["id"].ToStr());
                    ArrayResize(db_id, ArraySize(db_id) + 1);

                    db_id[ArraySize(db_id) - 1] = json["base_sinais"][i]["id"].ToStr();
                }
                Mensagemreversa((string)json["base_sinais"][i]["id"].ToStr(), (string)get_ticket);
            }
        }
        else if (i > 2000)
        {
            break;
        }
        if (i >= 2000)
            break;

        i++;
    }
}
bool conta()
{
    bool volta = false;
    CJAVal json_(NULL, jtUNDEF);

    string js = "{\"nome\":\"" + AccountInfoString(ACCOUNT_NAME) + "\",\"conta\":\"" + (string)AccountInfoInteger(ACCOUNT_LOGIN) + "\",\"invest\":\"" + (string)(AccountInfoDouble(ACCOUNT_BALANCE) + AccountInfoDouble(ACCOUNT_CREDIT) + AccountInfoDouble(ACCOUNT_PROFIT)) + "\"}";
    string state_db = httpPost("nem ta usando mais isso", 80, "access_account", js);

    json_.Deserialize(state_db);
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
    double _abertura = NormalizeDouble(StrToDouble(abertura), 5);
    double _stop_win = NormalizeDouble(StrToDouble(stop_win), 5);
    double _stop_loss = NormalizeDouble(StrToDouble(stop_loss), 5);
    RefreshRates();
    if (_direction == "buy")
    {
        //alert("entrooooo", par);
        RefreshRates();
        order = OrderSend(par, OP_BUY, lote, Ask, 0, 0, 0, "_id", MAGICNUMBER, 0, clrBlueViolet);
        return (order);
    }
    if (_direction == "sell")
    {
        //alert("entr_______", par);
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
    //alert("nnnnn");
    bool estaNatList = false;
    CJAVal json(NULL, jtUNDEF);
    string myIP = httpGET(urlK + "api/custom/"+Symbol()+"/"+id_entrada+"/");
    json.Deserialize(myIP);
    //retorar futuramento o histórico de quanto ganhou
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
            //alert(asd);
            CJAVal log_historico(NULL, jtUNDEF);
            log_historico.Deserialize(LerHistorico());
            string log_histoSTR = log_historico[(string)OrderTicket()].ToStr();

            //alert(asd, "  ", json["base_sinais"][i]["id"].ToStr());

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
                    if (json["base_sinais"][i]["abertura"].ToStr() != id_entrada)
                    {

                        estaNatList_ = true;
                    }
                    if (asda == "" && asda == NULL)
                        break;

                    if (json["base_sinais"][i]["id"].ToStr() == asd && json["base_sinais"][i]["status"].ToStr() == "fechamento")
                    {
                        //alert("passou");
                        estaNatList_ = true;
                        idcorrent = (string)json["base_sinais"][i]["id"].ToStr();
                        break;
                    }

                    if (i > 1000)
                        break;
                    i += 1;
                }
            }
            //alert(OrderTicket());
            if (asd != "" && asd != NULL && !estaNatList && estaNatList_)
            {
                //alert("ndddddn");
                bool verific = false;
                while (!verific)
                {

                    verific = OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrBlueViolet);

                    // Alert("o jsomn asssssssssssssssssssss",get_status_server["id"].ToStr());

                    //Alert("o jsomn asdddddd");
                    i++;
                    if(i >=200)
                    {
                        break;
                    }
                }
                MensagemHistorico((string)OrderTicket(), idcorrent);
            }
        }
    }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Mensagem(string dict_, string atributo_)
{

    while (True)
    {
        int h = FileOpen("logs_1550.txt", FILE_READ | FILE_WRITE | FILE_ANSI | FILE_TXT);
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
        int h = FileOpen("logs_1556.txt", FILE_READ | FILE_WRITE | FILE_ANSI | FILE_TXT);
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
        int h = FileOpen("logs_1557.txt", FILE_READ | FILE_WRITE | FILE_ANSI | FILE_TXT);
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
    int f = FileOpen("logs_1550.txt", FILE_READ | FILE_TXT);
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
    int f = FileOpen("logs_1556.txt", FILE_READ | FILE_TXT);
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
    int f = FileOpen("logs_1557.txt", FILE_READ | FILE_TXT);
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int trasIntString(string texto_s, string charactere_de_corte)
{
    string to_split = texto_s;        // A string to split into substrings
    string sep = charactere_de_corte; // A separator as a character
    ushort u_sep;                     // The code of the separator character
    string result[];                  // An array to get strings
                                      //--- Get the separator code
    u_sep = StringGetCharacter(sep, 0);
    //--- Split the string to substrings
    int k = StringSplit(to_split, u_sep, result);
    return (k);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void trasTextoString()
{
}
//+------------------------------------------------------------------+

int get_enter(string direc)
{
    //alert(1);
    string estilo_order = "nenhuma";
    Lot_s_change = corrent_lote(direc);
    int id_orden = 0;
    if (Lot_s_change != 0)
    {
        //alert(2);
        estilo_order = "exite";
    }
    if (estilo_order == "exite")
    {
        //alert(3);
        if (corrent_direc(direc) != direc)
        {
            //alert(4);
            //caso já exista mas tenha que vender
            string all_state_order = corrent_profit();
            if (all_state_order == "fechado")
            {
                //alert(5);
                id_orden = abertura_ordem("_id", Symbol(), 0, 0, 0, direc, Lots);
                Lot_rotativo = Lots;
            }
            else
            {
                //alert(6);
                flag_close_order = true;
            }
        }
        else
        {
            //alert(7);
            //existe e abrirá um novo
            Lot_rotativo = filterLot(Lot_rotativo);
            //alert(Lot_rotativo);
            id_orden = abertura_ordem("_id", Symbol(), 0, 0, 0, direc, NormalizeDouble(Lot_rotativo, 2));
        }
    }
    else
    {
        //alert(8);
        //abrirá um novo
        id_orden = abertura_ordem("_id", Symbol(), 0, 0, 0, direc, Lots);
        Lot_rotativo =Lots;
    }
    return(id_orden);
}

double filterLot(double entrada)
{
    //alert(9);
    double oqVolta = entrada * Lots_exponenvical;
    if (oqVolta > Lots_max)
        oqVolta = Lots_max;

    return (oqVolta);
}

double corrent_lote(string direc)
{
    //alert(10);
    int int_direc = 0;
    double lot_atual = 0;
    string fhg = direc;
    if (direc == "buy")
    {
        int_direc = 0;
    }
    else
    {
        int_direc = 1;
    }
    for (int i = 0; i < OrdersTotal(); i++)
    {

        if (OrderSelect(i, SELECT_BY_POS) == false)
            continue;
        if (OrderMagicNumber() == MAGICNUMBER)
        {
            if (lot_atual < OrderLots())
            {
                lot_atual = OrderLots();
            }
        }
    }
    return (lot_atual);
}
string corrent_profit()
{
    //alert(11);
    double lucro_all_order = 0;
    string estado = "aberto";
    for (int i = 0; i < OrdersTotal(); i++)
    {

        if (OrderSelect(i, SELECT_BY_POS) == false)
            continue;
        if (OrderMagicNumber() == MAGICNUMBER)
        {
            lucro_all_order += OrderProfit();
        }
    }
    if (lucro_all_order > Prof_dolar_min)
    {   
        while(OrdersTotal() != 0)
        {
            
            for (int i = 0; i < OrdersTotal(); i++)
            {

                if (OrderSelect(i, SELECT_BY_POS) == false)
                    continue;
                if (OrderMagicNumber() == MAGICNUMBER)
                {
                    OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrBlueViolet);
                }
            }
        }
        if(OrdersTotal() == 0)
            flag_close_order = false;
        estado = "fechado";
    }
    return (estado);
}
string corrent_direc(string direc)
{
    //alert(12);
    int int_direc = 0;
    string direc_ = direc;
    if (direc == "buy")
    {
        int_direc = 0;
    }
    else
    {
        int_direc = 1;
    }
    for (int i = 0; i < OrdersTotal(); i++)
    {

        if (OrderSelect(i, SELECT_BY_POS) == false)
            continue;
        if (OrderMagicNumber() == MAGICNUMBER)
        {
            
            int_direc = OrderType();
            
        }
    }
    switch (int_direc)
    {
    case 1:
        direc_ = "sell";
        break;
    default:
        direc_ = "buy";
        break;
    }
    return (direc_);
}