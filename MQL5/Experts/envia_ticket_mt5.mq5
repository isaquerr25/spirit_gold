//+------------------------------------------------------------------+
//|                                                 telegram-mt5.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
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
input int MAGICNUMBER = 100046;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
//#include <ghttp.mqh>
#include <JAson.mqh>
#include <Arrays\ArrayObj.mqh>
//#include <Web.mqh>
string db_id[1];
string db_historico = "";
string pares_bloquados[];
string bank_ticks[1];
bool status__account = false;
bool trava_entrada_banca_baixa = false;
input string iq_server = "copy";
input string urlK = "http://185.227.110.67:80/";
input string endereco = "185.227.110.67";
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
CJAVal log_historico_geral(NULL, jtUNDEF);


CJAVal log_progress_order(NULL, jtUNDEF);


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
{
   log_historico_geral.Deserialize(Lerreversa());
   log_progress_order.Deserialize(Ler_());
   int  fileHandle =0;
   if(!FileIsExist(iq_server+"_1550.txt",0))
   {
      Print("File Not _1550, Regenerating....." );
      fileHandle     =    FileOpen(iq_server+"_1550.txt" , FILE_READ|FILE_WRITE|FILE_TXT);
      FileWriteString(fileHandle,"");  
      FileClose(fileHandle);

      Print("File Not _1557, Regenerating....." );
      fileHandle     =    FileOpen(iq_server+"_1557.txt" , FILE_READ|FILE_WRITE|FILE_TXT);
      FileWriteString(fileHandle,"");  
      FileClose(fileHandle);

      Print("File Not _1556, Regenerating....." );
      fileHandle     =    FileOpen(iq_server+"_1556.txt" , FILE_READ|FILE_WRITE|FILE_TXT);
      FileWriteString(fileHandle,"");  
      FileClose(fileHandle);
   }
   //
   // buono dei test //

   // pegasinal();
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
   bool revisar = false;
   for (int i = 0; i < OrdersTotal(); i++)
   {

      if (OrderSelect(i) == false)
         continue;
      string log_geral = log_progress_order[(string)OrderGetTicket(i)].ToStr();
      if (log_geral == "" || log_geral == NULL)
      {   
         switch (OrderGetInteger(ORDER_TYPE))
         {
         case 1:
            revisar = true;
            break;
         case 0:
            revisar = true;
            break;
         default:
            break;
         }
         break;
      }
   }
   if(!revisar)
   {
      for (int i = 0; i < HistoryOrdersTotal(); i++)
      {

         if (OrderSelect(i) == false)
            continue;

         string log_geral = log_historico_geral[(string)OrderGetTicket(i)].ToStr();
         string log_histoSTR = log_progress_order[(string)OrderGetTicket(i)].ToStr(); 
         if (log_histoSTR == "gravado" && log_geral !="fechamento")
         {
            revisar = true;
            break;
         }
      }
   }
   //---
   // principal();
   if(revisar)
   {
      varresinal();

      varresinalfechado();
      log_historico_geral.Deserialize(Lerreversa());
      log_progress_order.Deserialize(Ler_());
   }
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
   //---
   varresinal();

   varresinalfechado();

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

void varresinalfechado()
{
   bool v_fechou = false;
   //alert("varre sinal");
   CJAVal log_historico(NULL, jtUNDEF);
   log_historico.Deserialize(Ler_());
   

   CJAVal log_historico__(NULL, jtUNDEF);
   log_historico__.Deserialize(Lerreversa());
   

   for (int i = 0; i < HistoryOrdersTotal(); i++)
   {
      
      if (OrderSelect(i) == false)
         continue;
      string log_histoSTR = log_historico[(string)OrderGetTicket(i)].ToStr();
      string log_histoSTR__ = log_historico__[(string)OrderGetTicket(i)].ToStr();
      //alert("11111");
      bool estaNatList = false;
      if (log_histoSTR == "gravado" && log_histoSTR__ !="fechamento")
      {
         estaNatList = false;
      }
      else
      {
         estaNatList = true;
      }
      if (!estaNatList)
      {
         v_fechou = true;
         string js = ("{\"ticket\":\"" + (string)OrderGetTicket(i) + "\",\"status\":\"fechamento\"}");
         log_historico[(string)OrderGetTicket(i)] = "fechamento";
         string back_ = httpPost(endereco, porta_, "auter_sinal", js);

         CJAVal back_server(NULL, jtUNDEF);
         back_server.Deserialize(back_);
         while (true)
         {
            //alert("__________a333333");
            if (back_server["status"].ToStr() == "fechamento")
            {
               break;
            }
         }
         MensagemHistorico((string)OrderGetTicket(i));
      }
   
   }
}

void varresinal()
{
   bool temRodando = false;
   
   if(!temRodando)
   {
      limpar();
   }
   //alert("varre sinal222");
   CJAVal log_historico(NULL, jtUNDEF);
   log_historico.Deserialize(Ler_());
   

   CJAVal log_historico__(NULL, jtUNDEF);
   log_historico__.Deserialize(Lerreversa());

   for (int i = 0; i < OrdersTotal(); i++)
   {

      if (OrderSelect(i) == false)
         continue;
      string log_histoSTR = log_historico[(string)OrderGetTicket(i)].ToStr();
      string log_histoSTR__ = log_historico__[(string)OrderGetTicket(i)].ToStr();
      bool estaNatList = false;
      //alert(log_histoSTR, " ggggggg");
      if ((log_histoSTR == "" || log_histoSTR == NULL) && log_histoSTR__ !="fechamento")
      {
         estaNatList = false;
      }
      else
      {
         estaNatList = true;
      }
      if (!estaNatList)
      {
         string direcao = "buy";
         switch (OrderGetInteger(ORDER_TYPE))
         {
         case 1:
            direcao = ("sell");
            break;
         case 0:
            direcao = ("buy");
            break;
         default:
            estaNatList = true;
            break;
         }
         if(estaNatList)
         {
            continue;
         }
         string js = ("{\"ticket\":\"" + (string)OrderGetTicket(i) + "\",\"abertura\":\"" + iq_server + "\",\"direcao\":\"" + direcao +
                     "\",\"par\":\"" + (string)OrderGetString(ORDER_SYMBOL) + "\",\"lots\":\"" + (string)OrderGetDouble(ORDER_VOLUME_INITIAL) + "\",\"status\":\"abertura\"}");
         while (true)
         {
            //alert("__________al222");
            string back_ = httpPost(endereco, porta_, "set_sinal", js);
            CJAVal back_server(NULL, jtUNDEF);
            back_server.Deserialize(back_);
            string hjh = back_server["status"].ToStr();
            if (hjh == "gravado" || hjh == "jaTem")
            {
               if (hjh == "gravado")
               {
                  Mensagem((string)OrderGetTicket(i), "gravado");
               }
               break;
            }
         }
         Mensagem((string)OrderGetTicket(i), "gravado");
      }
      
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Mensagem(string dict_, string atributo_)
{

   while (true)
   {
      int h = FileOpen(iq_server+"_1550.txt", FILE_READ | FILE_WRITE | FILE_ANSI | FILE_TXT);
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
void MensagemHistorico(string id__)
{

   while (true)
   {
      int h = FileOpen(iq_server+"_1557.txt", FILE_READ | FILE_WRITE | FILE_ANSI | FILE_TXT);
      if (h == INVALID_HANDLE)
      {
         //Print("Não pode enviar o sinal para ser protocolado");
      }
      else
      {
         FileSeek(h, 0, SEEK_END);
         FileWrite(h, "{\""+id__+"\":\"fechamento\"}");
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
string httpPost(string strUrl, int port, string idxfile = "get_to_id", string identi_op = "")
{
   ////alert("Request");
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
   // //alert("Error when trying to call APIU* : ", GetLastError());

   string DOTStr = CharArrayToString(result, 0);
   // //alert("Veio do server ,",DOTStr);
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
   int f = FileOpen(iq_server+"_1550.txt", FILE_READ | FILE_TXT);
   int i = 0;
   string str;
   while (FileIsEnding(f) == false)
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

void limpar()
{
   int file_handle=FileOpen(iq_server+"_1550.txt",FILE_READ|FILE_WRITE|FILE_TXT); 
   FileFlush(file_handle); 
   FileClose(file_handle);
   file_handle=FileOpen(iq_server+"_1557.txt",FILE_READ|FILE_WRITE|FILE_TXT); 
   FileFlush(file_handle); 
   FileClose(file_handle);
}
string LerHistorico()
{
   int f = FileOpen(iq_server+"_1556.txt", FILE_READ | FILE_TXT);
   int i = 0;
   string str;
   string backString = "";
   while (FileIsEnding(f) == false)
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
string Ler_()
{
   int f = FileOpen(iq_server+"_1550.txt", FILE_READ | FILE_TXT);
   int i = 0;
   string str;
   string backString = "";
   while (FileIsEnding(f) == false)
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
   int f = FileOpen(iq_server+"_1557.txt", FILE_READ | FILE_TXT);
   int i = 0;
   string str;
   string backString = "";
   while (FileIsEnding(f) == false)
   {
      str = FileReadString(f);
      backString = backString + str;
   }
   StringReplace(backString, "}", ",");
   StringReplace(backString, "{", "");
   backString = "{" + backString + "}";
   FileClose(f);
   return (backString);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
