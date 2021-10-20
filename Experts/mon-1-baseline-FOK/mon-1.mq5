//+------------------------------------------------------------------+
//|                                                         test.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include "send-transaction-close.mqh"
#include "mon-1-ind.mqh"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   //ChartSetSymbolPeriod(0,"XAUUSD",_Period);
   Print("Successful initialization!");
   Print("current symbol: ", _Symbol);
   Print("current peroid: ", PeriodSeconds());
   EventSetTimer(PeriodSeconds());
   OnTimer();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+

void OnTimer()
{
   Print("execute OnTimer!");
   MonOneInd mon_one_ind;
   mon_one_ind.findLastK();
   mon_one_ind.findLastConverseNTarget();
   bool last_K = mon_one_ind.getLastK();
   double last_close = mon_one_ind.getLastClose();
   double target_high = mon_one_ind.getTargetHigh();
   double target_low = mon_one_ind.getTargetLow();
   
   if(last_K == 0 && last_close > target_high)
   {
      
      PrintFormat("last_close > target K bar's high , Buy");
      OrderSender order_sender(1);
      order_sender.buy();
   }   
   else if(last_K == 1 && last_close < target_low)
   {
      PrintFormat("last_close < target K bar's low, Sell");
      OrderSender order_sender(1);
      order_sender.sell();   
   }
   else
   {
      PrintFormat("Didn't meet the strategy, do nothing in this peroid!");
   }
   Print("====================================================");
}