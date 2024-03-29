//+------------------------------------------------------------------+
//|                                                        medan.mq4 |
//|                                             Copyright 2021, issc |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, issc"
#property link "https://www.mql5.com"
#property version "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 DarkOrchid

//+------------------------------------------------------------------+
//| Expert variaveis                                                 |
//+------------------------------------------------------------------+

double ma21_ant, ma9, ma21, ma9_ant;
datetime ctm[1];
datetime LastTime;
extern int MAGICNUMBER = 10006;
extern bool maiorQue = false;
extern double linha_fechamento = 10263.00;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Alert(Symbol());
   HideTestIndicators(FALSE);
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
   principal();
   //---
   //principal();
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
   //---
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

void CloseOrder()
{
   //retorar futuramento o histórico de quanto ganhou
   double  resultado = 0;

   for (int i = 0; i < OrdersTotal(); i++)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
         break;
      if (OrderMagicNumber() == MAGICNUMBER)
      {
         resultado += OrderProfit();
      }
   }
   for (int i = 0; i < OrdersTotal(); i++)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
         break;
      if (OrderMagicNumber() == MAGICNUMBER && resultado >= 10)
         if (OrderType() == 1)
         {

            Print("Commission for the order 10  venda", OrderProfit());
            Print("ssssssssssssssssssssssssssssssss", MarketInfo(OrderSymbol(), MODE_BID));
            OrderClose(OrderTicket(), OrderLots(),  MarketInfo(OrderSymbol(),MODE_BID),5,Green);
            RefreshRates();
         }
         else
         {

            Print("Commission for the order 10 compra ", OrderProfit());
            Print("ssssssssssssssssssssssssssssssss", MarketInfo(OrderSymbol(), MODE_ASK));
            OrderClose(OrderTicket(), OrderLots(),  MarketInfo(OrderSymbol(),MODE_ASK),5,Green);
            RefreshRates();
         }
   }
}

void principal()
{
   double vbid    = MarketInfo(Symbol(),MODE_BID);
   double vask    = MarketInfo(Symbol(),MODE_ASK);
   double vpoint  = MarketInfo(Symbol(),MODE_POINT);
   int    vdigits = (int)MarketInfo(Symbol(),MODE_DIGITS);
   int    vspread = (int)MarketInfo(Symbol(),MODE_SPREAD);
   Print("MODE_BID ",vbid," MODE_ASK ",vask," MODE_POINT ",MODE_POINT," MODE_DIGITS ",vdigits," MODE_SPREAD ",vspread);
   if(maiorQue)
   {
      if( vbid >= linha_fechamento)
      {
         CloseOrder();
      }
   }
   else
   {
      if( vbid <= linha_fechamento)
      {
         CloseOrder();
      }
   }
}
