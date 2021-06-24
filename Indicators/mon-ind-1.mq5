//+------------------------------------------------------------------+
//|                                                    mon-ind-1.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
    //string target = "EURUSD";
   //bool period_set = ChartSetSymbolPeriod(0, target, PERIOD_M5);
   MqlRates rates[];
   Print("current symbol: ", _Symbol);
   int rate_num = CopyRates(_Symbol, PERIOD_M5, 0, 2, rates);
   if(rate_num != -1)
   {
      Print("open: ", rates[0].open, " close: ", rates[0].close);
      if(rates[0].open < rates[0].close)
      {
         Print("last K bar is red");
      }
      else {
         Print("last K bar is green");
      }  
   }
   //Sleep(1000 * 5);
//---
   return(INIT_SUCCEEDED);
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
   Print("OnCalculating!");
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
