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

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue
//---- buffers
double v1[];
double v2[];
double val1;
double val2;
int bares;
//+------------------------------------------------------------------+A
//| Expert variaveis                                                 |
//+------------------------------------------------------------------+

int OnInit()
{
    Comment("adoccccccccccccccccc /n asdasdasda");
//---- drawing settings
    SetIndexArrow(0, 119);
    SetIndexArrow(1, 119);
    //----  
    SetIndexStyle(0, DRAW_ARROW, STYLE_DOT, 1);
    SetIndexDrawBegin(0, bares-1);
    SetIndexBuffer(0, v1);
    SetIndexLabel(0,"Resistance");
    //----    
    SetIndexStyle(1,DRAW_ARROW,STYLE_DOT,1);
    SetIndexDrawBegin(1,bares-1);
    SetIndexBuffer(1, v2);
    SetIndexLabel(1,"Support");
    //---- 

    HideTestIndicators(true);
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
    ObjectsDeleteAll(0);
    EventKillTimer();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    strategia();

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
//+------------------------------------------------------------------+


void strategia()
{
    Comment("adoccccccccccccccccc /n asdasdasda");
    Print("asdasdasdasda");
    bares = iBars(Symbol(),PERIOD_H1)-1;

    for(int i =0;i<bares;i++) 
        {   
        val1 = iFractals(Symbol(), 0, MODE_UPPER, i);
        //----
        if(val1 > 0) 
            v1[i] = iHigh(Symbol(),PERIOD_H1,i);
        else
            v1[i] = v1[i+1];
        
        val2 = iFractals(Symbol(), 0, MODE_LOWER, i);
        //----
        if(val2 > 0) 
            v2[i] = iLow(Symbol(),PERIOD_H1,i);
        else
            v2[i] = v2[i+1];
        i--;
        }   
    return(0)
}