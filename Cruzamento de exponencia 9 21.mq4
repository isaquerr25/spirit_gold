//+------------------------------------------------------------------+
//|                                                        medan.mq4 |
//|                                             Copyright 2021, issc |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, issc"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 DarkOrchid

//+------------------------------------------------------------------+
//| Expert variaveis                                                 |
//+------------------------------------------------------------------+

double ma21_ant,ma9,ma21,ma9_ant;
double resultado_r = 0.0;
datetime ctm[1];
datetime LastTime;
double lot,slv,tpv;
extern int barsToProcess=100;
extern int MAGICNUMBER  = 10006; 
extern bool Abre_venda  = true; 
extern bool Abre_compra = true;
extern double Fator_Multipicativo  = 1.2; 
extern double Lots       = 0.1; /*Lots*/              // Lot
extern double Max_Lots    = 20.0;
double Lotss = Lots;
double fix = Lotss;
extern int Take_exter = 150;
extern bool TradeStop = True;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
    HideTestIndicators (FALSE);
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
      principal();
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

double total_ordem_open(int magic_n,int BUY_SELL)
{
   int total_order = OrdersTotal();
   int contador = 0;
   for(int i = 0;i<total_order;i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == false)
         break;
         
      if((OrderMagicNumber() == magic_n) && (OrderType() == BUY_SELL))
          contador++;
   }
   return (contador);
}


void CloseOrder(int BUY_SELL,int magic_n)
{
   //retorar futuramento o histórico de quanto ganhou
    bool tad = false;
	for(int i = 0;i<OrdersTotal();i++)
	{
		if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == false)
			break;
				
		if((OrderMagicNumber() == magic_n) && (OrderType() == BUY_SELL))
		   	
			if(BUY_SELL == OP_SELL)
			{
			
			   
				resultado_r += OrderProfit();
				Print("Commission for the order 10  venda" ,OrderProfit()); 
            Print("ssssssssssssssssssssssssssssssss" ,MarketInfo(OrderSymbol(),MODE_BID)); 
            RefreshRates();
				//tad = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(),MODE_BID),5,Red);
				tad = OrderClose(OrderTicket(), OrderLots(),  MarketInfo(OrderSymbol(),MODE_ASK),5,Green);
			}
			else
			{	
			   
				resultado_r += OrderProfit();
				Print("Commission for the order 10 compra ",OrderProfit()); 
            Print("ssssssssssssssssssssssssssssssss" ,MarketInfo(OrderSymbol(),MODE_ASK));
            RefreshRates();
            tad = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(),MODE_BID),5,Red);
				//tad = OrderClose(OrderTicket(), OrderLots(),  MarketInfo(OrderSymbol(),MODE_ASK),5,Green);
            
            
			}
			
			
	}
	if(tad && resultado_r<0.0)
			{
			   	Lotss= Lotss*Fator_Multipicativo;
			}
			else if(tad && resultado_r>0.0)
			{
				Lotss = fix;
				resultado_r = 0;
			}
   if(Lotss >Max_Lots)
			{
			   Lotss = Max_Lots;
			}
			Comment(Lotss);
}

void abertura_ordem(string direc,double lote)
{
   int order;
   if(direc == "buy")
   
      order = OrderSend(Symbol(),OP_BUY,lote,Ask,0,0,0,"buy",MAGICNUMBER,0,clrBlueViolet);
      RefreshRates();
   if(direc == "sell")
   
      order = OrderSend(Symbol(),OP_SELL,lote,Bid,0,0,0,"sell",MAGICNUMBER,0,clrRed);
      RefreshRates();
}  

string direction_speak() //retorna direção
{
	ma21=iMA(NULL,PERIOD_CURRENT,21,0,MODE_EMA,PRICE_CLOSE,1);
	ma9=iMA(NULL,PERIOD_CURRENT,9,0,MODE_EMA,PRICE_CLOSE,1);
	ma21_ant=iMA(NULL,PERIOD_CURRENT,21,0,MODE_EMA,PRICE_CLOSE,2);
	ma9_ant=iMA(NULL,PERIOD_CURRENT,9,0,MODE_EMA,PRICE_CLOSE,2);
	if(((ma21 < ma9) && (ma21_ant > ma9_ant)))
	{
	    return("buy");
	}
	if(((ma21 > ma9) && (ma21_ant < ma9_ant)))
	{
	    return("sell");
	}
	return("none");
}

void stop_Take()
{
   int total_order = OrdersTotal();
   int contador = 0;
   for(int i = 0;i<total_order;i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == false)
         break;
      if((OrderMagicNumber() == MAGICNUMBER) )
      {
            if (OrderType() == OP_BUY)              
            if(Bid-OrderOpenPrice()>Point*Take_exter)
             {
                if(OrderStopLoss()<Bid-Point*Take_exter)
                  {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*Take_exter,OrderTakeProfit(),0,Green);
                     
                  }
             }
            
            
            
            if (OrderType() == OP_SELL) if((OrderOpenPrice()-Ask)>(Point*Take_exter))
             {
                if((OrderStopLoss()>(Ask+Point*Take_exter)) || (OrderStopLoss()==0))
                {
                   OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*Take_exter,OrderTakeProfit(),0,Red);
                  
                }
             }
               
      }
   }
}


void principal()
{
   Comment("ask = ",Ask," bid=",Bid);
   string dire_ac = "";
   dire_ac  = direction_speak();
   if(TradeStop)
   {
      stop_Take();
   }
   if(dire_ac == "buy")
   {
         
		   CloseOrder(OP_SELL,MAGICNUMBER);
         if (total_ordem_open(MAGICNUMBER,OP_BUY) ==0 &&  Abre_compra && total_ordem_open(MAGICNUMBER,OP_SELL) ==0)
		   {
			   abertura_ordem(dire_ac,Lotss);
			   Comment("_______________1______________");
			
		   }
		   dire_ac = "";
		   return;
    }
    if(dire_ac == "sell" )
    {
      
    	CloseOrder(OP_BUY,MAGICNUMBER);
    	if (total_ordem_open(MAGICNUMBER,OP_SELL) ==0 &&  Abre_venda && total_ordem_open(MAGICNUMBER,OP_BUY) ==0)
		{

			abertura_ordem(dire_ac,Lotss);
			Comment("_______________2______________");
			
		}
		dire_ac = "";
		return;
    }

}

