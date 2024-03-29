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
#property version   "13.52"

        
enum broker {
   All = 0,
   IQOption = 1,
   Binary = 2,
   Spectre = 3,
   Alpari = 4,
   InstaBinary = 5
};

enum onoff {
   NO = 0,
   YES = 1 
};

static onoff AutoSignal = YES;     // Autotrade Enabled

enum signaltype {
   IntraBar = 0,   // Intrabar
   ClosedCandle = 1       // On new bar
};

enum martintype {
   NoMartingale = 0, // No Martingale    
   OnNextExpiry = 1, // On Next Expiry
   OnNextSignal = 2,  // On Next Signal
   Anti_OnNextExpiry = 3, // Anti-/ On Next Expiry
   Anti_OnNextSignal = 4, // Anti-/ On Next Signal
   OnNextSignal_Global = 5,  // On Next Signal (Global)
   Anti_OnNextSignal_Global = 6 // Anti-/ On Next Signal (Global)
};


#import "mt2trading_library.ex4"   // Please use only library version 13.52 or higher !!!
   bool mt2trading  (string symbol, string direction, double amount, int expiryMinutes);
   bool mt2trading  (string symbol, string direction, double amount, int expiryMinutes, string signalname);
   bool mt2trading  (string symbol, string direction, double amount, int expiryMinutes, martintype martingaleType, int martingaleSteps, double martingaleCoef, broker myBroker, string signalName, string signalid);
   int  traderesult (string signalid);
   
   int getlbnum();
   bool chartInit(int mid);
   int updateGUI   (bool initialized, int lbnum, string indicatorName, broker Broker, bool auto, double amount, int expiryMinutes);
   int processEvent(const int id, const string& sparam, bool auto, int lbnum ); 
   void showErrorText (int lbnum, broker Broker, string errorText);
   void remove (const int reason, int lbnum, int mid);
   void cleanGUI();
#import



// Inputs Parameters
extern string id_referencial = "5";            
input string s0 = "===== SIGNAL SETTINGS ============="; // ======================
input broker Broker = All;
input string SignalName = ""; // Signal Name (optional)
input string IndicatorName = "BB_AlertArrows"; // Indicator File Name
input int IndiBufferCall = 0;      // Signal Buffer Up ("Call") 
input int IndiBufferPut = 1;       // Signal Buffer Down ("Put") 
input signaltype SignalType = ClosedCandle; // Entry Type
input string s_title_settings   = "===== TRADING SETTINGS ============"; // ====================
input double TradeAmount = 1;            // Trade Amount 
input int ExpiryMinutes = 5;          // Expiry Time [minutes]
input martintype MartingaleType = NoMartingale; // Martingale
input int MartingaleSteps = 2; // Martingale Steps          
input double MartingaleCoef = 2.0; // Martingale Coefficient
input string nc_section2 = "================="; // ==== Internal Parameters ===
input int mID = 0;      // ID (do not modify)
          
          
// Variables          
int lbnum = 0;
bool initgui = false;
datetime sendOnce;   // Candle time stampe of signal for preventing duplicated signals on one candle
string asset;        // Symbol name (e.g. EURUSD)
string signalID;     // Signal ID (unique ID)
bool alerted = false;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{     

   EventSetTimer(1); 
   
   chartInit(mID);  // Chart Initialization
   lbnum = getlbnum(); // Generating Special Connector ID  
   
   // Initialize the time flag
   sendOnce = TimeCurrent();
   
   // Generate a unique signal id for MT2IQ signals management (based on timestamp, chart id and some random number)
   MathSrand(GetTickCount()); 
   if (MartingaleType == OnNextExpiry)
      signalID = IntegerToString(GetTickCount()) + IntegerToString(MathRand()) + " OnNextExpiry";   // For OnNextSignal martingale will be indicator-wide unique id generated
   else if (MartingaleType == Anti_OnNextExpiry)
      signalID = IntegerToString(GetTickCount()) + IntegerToString(MathRand()) + " AntiOnNextExpiry";   // For OnNextSignal martingale will be indicator-wide unique id generated
   else if (MartingaleType == OnNextSignal)
      signalID = IntegerToString(ChartID()) + IntegerToString(AccountNumber()) + IntegerToString(mID) + " OnNextSignal";   // For OnNextSignal martingale will be indicator-wide unique id generated
   else if (MartingaleType == Anti_OnNextSignal)
      signalID = IntegerToString(ChartID()) + IntegerToString(AccountNumber()) + IntegerToString(mID) + " AntiOnNextSignal";   // For OnNextSignal martingale will be indicator-wide unique id generated
   else if (MartingaleType == OnNextSignal_Global) 
      signalID = "MARTINGALE GLOBAL On Next Signal";   // For global martingale will be terminal-wide unique id generated     
   else if (MartingaleType == Anti_OnNextSignal_Global)
      signalID = "MARTINGALE GLOBAL Anti On Next Signal";   // For global martingale will be terminal-wide unique id generated     
         
   // Symbol name should consists of 6 first letters
   if (StringLen(Symbol()) >= 6)
      asset = StringSubstr(Symbol(),0,6);
   else
      asset = Symbol();
      
   
   return(INIT_SUCCEEDED);
}

  
void OnDeinit(const int reason)
{
   EventKillTimer();
   remove(reason, lbnum, mID);
   
}

void Mensagem(string messe)
{
   while(True)
      {
         int h=FileOpen("arquivosdesinais.txt",FILE_READ|FILE_WRITE|FILE_ANSI|FILE_TXT);
         if(h==INVALID_HANDLE)
         {
            Alert("Error opening file");
            Print("Não pode enviar o sinal para ser protocolado");
         }
         else
         {
               FileSeek(h,0,SEEK_END);
               FileWrite(h,"{\"par\":\""+Symbol()+"\",\"direcao\":\""+messe+"\",\"abertura\":\""+id_referencial+"\",\"ticket\":\"0\",\"lots\":\"0\",\"status\":\"abertura\"}");
               FileClose(h);
               Alert("File created"+Symbol(),messe);
               alerted=true;
               break;
         }
      }
}




//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- 
   double up = 0, dn = 0;
   ResetLastError();
   
   if (MartingaleType == NoMartingale || MartingaleType == OnNextExpiry || MartingaleType == Anti_OnNextExpiry)
      signalID = IntegerToString(GetTickCount()) + IntegerToString(MathRand());   // For NoMartingale or OnNextExpiry martingale will be candle-wide unique id generated

             
   if (IndicatorName != "") {
      up = iCustom(NULL, 0, IndicatorName, IndiBufferCall, SignalType);
      dn = iCustom(NULL, 0, IndicatorName, IndiBufferPut, SignalType);
   }
   else {
      showErrorText (lbnum, Broker, "Indicator name is EMPTY!");
   }
      
   // Check if iCustom is processed successful. If not: alert error once.
   int errornum = GetLastError();
   if (errornum == 4072) {
      showErrorText (lbnum, Broker, "'" + IndicatorName+"' indicator is not found!");
      if (!alerted) {
         Alert("Erro 225");
         alerted = true;

      }
   }
            
   // if signal UP (CALL)
   if (AutoSignal && signal(up) && Time[0] > sendOnce) {
      mt2trading (asset, "CALL", TradeAmount, ExpiryMinutes, MartingaleType, MartingaleSteps, MartingaleCoef, Broker, SignalName, signalID);
      Print ("CALL - Signal sent!" + (MartingaleType != NoMartingale ? " [Martingale: Steps " + IntegerToString(MartingaleSteps) + ", Coefficient " + DoubleToString(MartingaleCoef,2) + "]" : ""));
      sendOnce = Time[0]; // Time stamp flag to avoid duplicated trades
      Print("comprar ////////////////////////////////////////");  
      Mensagem("buy");   
   }
      
   // if signal DOWN (PUT)
   if (AutoSignal && signal(dn) && Time[0] > sendOnce) {
      mt2trading (asset, "PUT", TradeAmount, ExpiryMinutes, MartingaleType, MartingaleSteps, MartingaleCoef, Broker, SignalName, signalID);
      Print ("PUT - Signal sent!" + (MartingaleType != NoMartingale ? " [Martingale: Steps " + IntegerToString(MartingaleSteps) + ", Coefficient " + DoubleToString(MartingaleCoef,2) + "]" : ""));
      sendOnce = Time[0]; // Time stamp flag to avoid duplicated trades
      Print("Venda");
      Mensagem("sell");  
   }
   
      
   //--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+


// Function: check indicators signal buffer value 
bool signal (double value) 
{
   if (value != 0 && value != EMPTY_VALUE)
      return true;
   else
      return false;
} 



// Function: create info label on the chart
void OnTimer() {   
   if (!initgui) {
      cleanGUI();    
      initgui = false;
   }
  // lbnum = updateGUI(initgui, lbnum, IndicatorName, Broker, AutoSignal, TradeAmount, ExpiryMinutes);
}


void OnChartEvent(const int id,         // Event ID 
                  const long& lparam,   // Parameter of type long event 
                  const double& dparam, // Parameter of type double event 
                  const string& sparam  // Parameter of type string events 
                  ) 
{
  
   int res = processEvent(id, sparam, AutoSignal, lbnum);   
   if (res == 0)
      AutoSignal = false;
   else if (res == 1)
      AutoSignal = true;      
}



