//+------------------------------------------------------------------+
//|                                                mon_strategy1.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---\
   string target = "EURUSD";
   //bool period_set = ChartSetSymbolPeriod(0, target, PERIOD_M5);
   while(true)
   {
      MqlRates rates[];
      int rate_num = CopyRates(target, PERIOD_M5, 0, 2, rates);
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
      Sleep(1000 * 5);
      
   }
   
  }
//+------------------------------------------------------------------+
