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
string string_log_historico_geral_p ="";
string string_log_progress_order_p ="";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
{
   //Alert("222");
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
   //Alert(TimeCurrent() - (TimeCurrent()%186400));

   
   

   for(int i=0; i<(int)PositionsTotal(); i++)
   {
      
    
      ulong ticket=PositionGetTicket(i);
      //Alert(ticket);
      //Alert(OrderGetInteger(POSITION_TYPE));
      
      if(ticket ==0) continue;
      
      //Alert("333");
      
      string log_geral ="";
      
      if(!seraQueTem(string_log_progress_order_p,(string)ticket))
      {
         log_geral = log_progress_order[(string)ticket].ToStr();
      }
      
      //Alert("4444");   
         
      //Alert(log_geral);
      
      //Alert(revisar);
      
      if (log_geral == "" || log_geral == NULL)
      {   
         
         switch (PositionGetInteger(POSITION_TYPE))
        {
        
            
            case 0:
               Comment("--->>><><><><><><>",ticket);
               revisar = true;
               break;
            case 1:
               Comment("--->>><><><><><><>",ticket);
               revisar = true;
               break;
            default:
               break;
        }
        
      }
      
   }
   
   
   if(!revisar)
   {
      //Alert("dsfgd");
      //Alert(TimeCurrent() - (TimeCurrent()%186400));
      HistorySelect(0,TimeCurrent());
      for (int i = 0; i < HistoryOrdersTotal(); i++)
      {
         ulong ticket=HistoryOrderGetTicket(i);
         if(ticket<=0)  continue;
         //Alert("dsfgd");
         if(aindaTaAtivo(ticket)) continue;
         //Alert("ffffffffffffff");
         string log_geral ="";
         string log_histoSTR ="";
     
         if(!seraQueTem(string_log_progress_order_p,(string)ticket))
         {
            log_geral = log_progress_order[(string)ticket].ToStr();
         }
         //Alert(string_log_progress_order);
         if(!seraQueTem(string_log_historico_geral_p,(string)ticket))
         {
            //Alert("sdaadawdawdddddddddddd");
            log_histoSTR = log_historico_geral[(string)ticket].ToStr(); 
         }

         //Alert(string_log_historico_geral);
         if (log_geral == "gravado" && log_histoSTR !="fechamento")
         {
            //Alert(ticket);
            Comment("--->>><><><><><><>",(string)ticket);
            revisar = true;
            break;
         }
      }
   }
   //Alert("6666676767676");
   //---
   //Alert(revisar);
   if(revisar)
   {
      //Alert("11111");
      
      varresinal();

      varresinalfechado();
      
      string_log_historico_geral_p = Lerreversa();
      string_log_progress_order_p = Ler_();
      log_progress_order.Deserialize(string_log_progress_order_p);
      log_historico_geral.Deserialize(string_log_historico_geral_p);
   }
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
  
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
bool seraQueTem(string texto, string quer)
{
   
   int comp =  1;
   comp = StringFind(texto,quer,0);
   bool status = false;
   
   if(comp <=0)
   {
      status = true;
   }
   
   return(status);
}
bool aindaTaAtivo(ulong idEspecifico)
{
   bool fg = false;
   for(int i=0; i<(int)PositionsTotal(); i++)
   {
      
      
      ulong ticket=PositionGetTicket(i);
      if(ticket ==0) continue;
      if(ticket == idEspecifico)
      {
         fg = true;
         break;
      }
   }
   return(fg);
}
void varresinalfechado()
{
   //Alert("varresinalfechado");
   bool v_fechou = false;
   //alert("varre sinal");
   string string_log_progress_order = Ler_();
   string log_historico_geralc = Lerreversa();


   CJAVal log_historico(NULL, jtUNDEF);
   log_historico.Deserialize(string_log_progress_order);
   

   CJAVal log_historico__(NULL, jtUNDEF);
   log_historico__.Deserialize(log_historico_geralc);
   




   //Alert("varresinalfechado antes do for");
   HistorySelect(0,TimeCurrent());
   for (int i = 0; i < HistoryOrdersTotal(); i++)
   {
      //Alert("varresinalfechado dentro do for");
      ulong ticket=HistoryOrderGetTicket(i);
      //Alert(ticket);
      if(ticket<=0)  continue;
      //Alert("varresinalfechado continue");
      if(aindaTaAtivo(ticket)) continue;
      //Alert("varresinalfechado segunda faze");
      string log_histoSTR   = "";
      string log_histoSTR__ = "";

      if(!seraQueTem(string_log_progress_order,(string)ticket))
      {
         log_histoSTR = log_historico[(string)ticket].ToStr();
      }
         
      if(!seraQueTem(log_historico_geralc,(string)ticket))
      {
         log_histoSTR__ = log_historico__[(string)ticket].ToStr(); 
      }

      bool estaNatList = false;
      if (log_histoSTR == "gravado" && log_histoSTR__ !="fechamento")
      {
         //Alert(HistoryDealGetTicket(i));
         estaNatList = false;
      }
      else
      {
         estaNatList = true;
      }
      if (!estaNatList)
      {
         //Alert("log_histoSTR "+ log_histoSTR +"  ?? " + "log_histoSTR__"+log_histoSTR__ ,"   ",ticket);
         string js = ("{\"ticket\":\"" + (string)ticket + "\",\"status\":\"fechamento\"}");
         log_historico[(string)ticket] = "fechamento";
         //Alert(log_historico[(string)ticket].ToStr());
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
         MensagemHistorico((string)ticket);
      }
   
   }
}

void varresinal()
{
   //Alert("varresinal");
   bool temRodando = false;

   for(int i=0; i<(int)PositionsTotal(); i++)
   {
      
    
      ulong ticket=PositionGetTicket(i);
      if(ticket ==0) continue;
   }

   if(!temRodando)
   {
      limpar();
   }
   //alert("varre sinal222");


   string string_log_progress_order = Ler_();
   string log_historico_gerals = Lerreversa();


   CJAVal log_historicos(NULL, jtUNDEF);
   log_historicos.Deserialize(string_log_progress_order);
   

   CJAVal log_historico__(NULL, jtUNDEF);
   log_historico__.Deserialize(log_historico_gerals);
   
   for (int i = 0; i < PositionsTotal(); i++)
   {

      ulong ticket=PositionGetTicket(i);
      if(ticket ==0) continue;

      string log_histoSTR   = "";
      string log_histoSTR__ = "";

      if(!seraQueTem(string_log_progress_order,(string)ticket))
      {
         log_histoSTR = log_historicos[(string)ticket].ToStr();
      }
         
      if(!seraQueTem(log_historico_gerals,(string)ticket))
      {
         log_histoSTR__ = log_historico__[(string)ticket].ToStr(); 
      }
      
      bool estaNatList = false;
      //Alert(log_histoSTR, " ggggggg");
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
         //Alert(PositionGetInteger(POSITION_TYPE));
         switch (PositionGetInteger(POSITION_TYPE))
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
         string js = ("{\"ticket\":\"" + (string)ticket + "\",\"abertura\":\"" + iq_server + "\",\"direcao\":\"" + direcao +
                     "\",\"par\":\"" + PositionGetString(POSITION_SYMBOL) + "\",\"lots\":\"" + (string)PositionGetDouble(POSITION_VOLUME) + "\",\"status\":\"abertura\"}");
                
         //alert("__________al222");
         string back_ = httpPost(endereco, porta_, "set_sinal", js);
         Mensagem((string)ticket, "gravado");
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
          "http://" + endereco + ":80/copy/" + idxfile, // URL
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
   file_handle=FileOpen(iq_server+"_1556.txt",FILE_READ|FILE_WRITE|FILE_TXT); 
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
