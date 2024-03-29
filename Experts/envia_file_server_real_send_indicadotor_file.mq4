//+------------------------------------------------------------------+
//|                                                  GOLD SPIRIT.mq4 |
//|                                                   Copyright 2021 |
//|                                     DEVELOPER ISAQUE R. FERREIRA |
//+------------------------------------------------------------------+

#property copyright "Copyright 2021"
#property version   "1.00"
#property link   "https://t.me/isaquerr25"
#property description "DEVELOPER ISAQUE R. FERREIRA"
#property description "Mais info"
#property link   "https://t.me/isaquerr25" 
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 DarkOrchid

//+------------------------------------------------------------------+
//| Expert variaveis                                                 |
//+------------------------------------------------------------------+
#include <mql4-http.mqh>
double ma21_ant,ma9,ma21,ma9_ant;
double resultado_r = 0.0;
datetime ctm[1];
datetime LastTime;
double lot,slv,tpv;
extern int MAGICNUMBER  = 100046;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include <ghttp.mqh>
#include <JAson.mqh>
#include <Arrays\ArrayObj.mqh>
#include  <Web.mqh>
string db_id[1];
string db_historico ="";
string pares_bloquados[];
string bank_ticks[1];
bool status__account = false;
bool trava_entrada_banca_baixa = false;
extern string urlK = "http://147.135.80.138:80/";
extern string endereco = "147.135.80.138";
extern int porta_ = 80;
#import  "Wininet.dll"
int InternetOpenW(string, int, string, string, int);
int InternetConnectW(int, string, int, string, string, int, int, int);
int InternetOpenUrlW(int, string, string, int, int, int);
int InternetReadFile(int, string, int, int& OneInt[]);
int InternetCloseHandle(int);
int HttpOpenRequestW(int, string, string, string, string, string, int, int);
bool HttpSendRequestW(int, string, int, string, int);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HttpSendRequestW(int hRequest, string lpszHeaders, int dwHeadersLength, char &lpOptional[], int dwOptionalLength);

#import "Kernel32.dll"
bool MoveFileExW(string &lpExistingFileName,string &lpNewFileName,int dwFlags);
#import
#define MOVEFILE_REPLACE_EXISTING 0x1
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

//
// buono dei test //

// pegasinal();
   HideTestIndicators(TRUE);
   EventSetTimer(60);

//---
   return(INIT_SUCCEEDED);
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
      if(FileIsExist("arquivosdesinais.txt"))
            ado();
// principal();
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
    if(FileIsExist("arquivosdesinais.txt"))
      ado();

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
      if(FileIsExist("arquivosdesinais.txt"))
            ado();
   
  }
void ado()
{
	LerMensagem();
    for(int i=0;i<ArraySize(db_id);i++)
    {
        string js = (db_id[i]);
        if(js == "" || js == NULL)
         break;
        while(True)
        {
            
            string back_ = httpPost(endereco,porta_,"set_sinal",js);
            CJAVal back_server(NULL, jtUNDEF);
            back_server.Deserialize(back_);
            string hjh = back_server["status"].ToStr();
            if(hjh == "gravado" || hjh == "jaTem")
            {    
                break;
            }
            
        }
        
    }
    ArrayFree(db_id);
}
void varresinalfechado()
{

    for(int i = 0; i < OrdersHistoryTotal(); i++)
    {
        
        if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false)  continue;
        if(OrderMagicNumber() == MAGICNUMBER)
        {
          
            CJAVal log_historico(NULL, jtUNDEF);
            log_historico.Deserialize(Ler_());
            string log_histoSTR = log_historico[(string)OrderTicket()].ToStr();
           
            bool estaNatList = false;
           if(log_histoSTR =="gravado")
           {
               estaNatList = false;
           }
           else
           {
               estaNatList = true;
           }
           if(!estaNatList)
           {
               
               string js = ("{\"ticket\":\""+(string)OrderTicket()+"\",\"status\":\"fechamento\"}");
               log_historico[(string)OrderTicket()] = "fechamento";
               while(True)
               {
                  
                   string back_ = httpPost(endereco,porta_,"auter_sinal",js);
                   
                   CJAVal back_server(NULL, jtUNDEF);
                   back_server.Deserialize(back_);
   
                   if(back_server["status"].ToStr() == "fechamento")
                   {
                       break;
                   }
               }
               string ff = log_historico.Serialize();
               
               MensagemHistorico(ff);
            }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Mensagem(string dict_,string atributo_)
  {

   while(True)
     {
      int h=FileOpen("logs_1550.txt",FILE_READ|FILE_WRITE|FILE_ANSI|FILE_TXT);
      if(h==INVALID_HANDLE)
        {
         //Print("Não pode enviar o sinal para ser protocolado");
        }
      else
        {
         FileSeek(h,0,SEEK_END);
         FileWrite(h,"{\""+dict_+"\":\""+atributo_+"\"}");
         FileClose(h);
         break;
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MensagemHistorico(string dict_)
{

    while(True)
    {
        int h=FileOpen("logs_1550.txt",FILE_READ|FILE_WRITE|FILE_ANSI|FILE_TXT);
        if(h==INVALID_HANDLE)
        {
         //Print("Não pode enviar o sinal para ser protocolado");
        }
        else  
        {
            FileSeek(h,0,SEEK_END);
            FileFlush(h);
            FileWrite(h,dict_);
            FileClose(h);
            break;
        }
    }
}
void Mensagemreversa(string dict_,string atributo_)
  {
      
      while(True)
     {
      int h=FileOpen("logs_1557.txt",FILE_READ|FILE_WRITE|FILE_ANSI|FILE_TXT);
      if(h==INVALID_HANDLE)
        {
         //Print("Não pode enviar o sinal para ser protocolado");
        }
      else
        {
         FileSeek(h,0,SEEK_END);
         FileWrite(h,"{\""+(string)dict_+"\":\""+(string)atributo_+"\"}");
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
		
		string fg = httpPost(endereco,porta_,"get_to_id",id_);
		
		return (fg);
	}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+






//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string httpPost(string strUrl,int port,string idxfile = "get_to_id",string identi_op="")
  {
   //Alert("Request");
   string headers = "Content-Type: application/json";
   string js;
   if(idxfile =="get_to_id")
        js = "{\"id\":"+identi_op+"}";
   else
      js =identi_op;
   uchar data[];
   uchar result[];
   string result_hdr;

   
   StringToCharArray(js, data);

   int HttpOpen = hSession(false);
   string serve_header = "";
   char resultado[];
   int offget;
   if(idxfile =="access_account")
   {
      offget = WebRequest(
                  "POST",           // HTTP method
                  "http://"+endereco+":80/userk/"+idxfile,              // URL
                  headers,          // headers
                  100000000,          // timeout
                  data,          // the array of the HTTP message body
                  result,        // an array containing server response data
                  result_hdr   // headers of server response
               );
   }
   else
   {
      offget = WebRequest(
                  "POST",           // HTTP method
                  "http://"+endereco+":80/api/"+idxfile,              // URL
                  headers,          // headers
                  100000000,          // timeout
                  data,          // the array of the HTTP message body
                  result,        // an array containing server response data
                  result_hdr   // headers of server response
               );
   }
  // Alert("Error when trying to call APIU* : ", GetLastError());

   string DOTStr=CharArrayToString(result,0);
  // Alert("Veio do server ,",DOTStr);
   /*
   int err = GetLastError();

   if(err>0)Print ("Last MSDN Error =: ",err);

   int read[1];




   InternetCloseHandle(HttpOpen);

   InternetCloseHandle(HttpRequest);
   InternetCloseHandle(result);
   InternetCloseHandle(HttpConnect);*/
   return(DOTStr);

  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LerMensagem()
  {
   int f = FileOpen("arquivosdesinais.txt",FILE_READ|FILE_WRITE|FILE_ANSI|FILE_TXT);
   int i =0;
   string str;
   while(FileIsEnding(f) == False)
     {
      str = FileReadString(f);
      ArrayResize(db_id,ArraySize(db_id)+1);
      db_id[i] = str;
      i++;
     }
   FileFlush(f);
   FileClose(f);
   FileDelete("arquivosdesinais.txt");
  }
string LerHistorico()
  {
   int f = FileOpen("logs_1556.txt",FILE_READ|FILE_TXT);
   int i =0;
   string str;
   string backString ="";
   while(FileIsEnding(f) == False)
     {
      str = FileReadString(f);
      backString = backString+str;
     }
   StringReplace(backString,"}","");
   StringReplace(backString,"{","");
   backString = "{"+backString+"}";
   FileClose(f);
   return(backString);
  }
string Ler_()
  {
   int f = FileOpen("arquivosdesinais.txt",FILE_READ|FILE_WRITE|FILE_ANSI|FILE_TXT);
   int i =0;
   string str;
   string backString ="";
   while(FileIsEnding(f) == False)
     {
      str = FileReadString(f);
      backString = backString+str;
     }
   StringReplace(backString,"}","");
   StringReplace(backString,"{","");
   backString = "{"+backString+"}";
   FileClose(f);
   FileDelete(f);
   return(backString);
  }
string Lerreversa()
  {
   int f = FileOpen("logs_1557.txt",FILE_READ|FILE_TXT);
   int i =0;
   string str;
   string backString ="";
   while(FileIsEnding(f) == False)
     {
      str = FileReadString(f);
      backString = backString+str;
     }
   StringReplace(backString,"}","");
   StringReplace(backString,"{","");
   backString = "{"+backString+"}";
   FileClose(f);
   return(backString);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
