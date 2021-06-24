//+------------------------------------------------------------------+
//|                                                         test.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <send-transaction-close-order-same-trend.mqh>
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
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
   MqlRates rates[];
   // last_K = 0 -> red bar
   // last_K = 1 -> green bar
   
   bool last_K;
   double last_open;
   double last_close;
   int cnt = 0;
   int rate_num = CopyRates(_Symbol, _Period, 0, 2, rates);
   while(true)
   {
      if(rate_num != -1)
      {
         Print("Last K bar:");
         last_open = rates[0].open;
         last_close = rates[0].close;
         if(rates[0].open < rates[0].close)
         {
            last_K = 0;
            PrintFormat("RED open: %f, close: %f", rates[0].open, rates[0].close);
         }
         else {
            last_K = 1;
            PrintFormat("GREEN open: %f, close: %f", rates[0].open, rates[0].close);
         }
         if(rates[0].open != rates[0].close)
            break;
         cnt ++;   
         rate_num = CopyRates(_Symbol, _Period, 0, 2+cnt, rates);  
      }
      else
      {
         Print("error occur when calling CopyRates()");
         break;
      }
   }
   
   int cnv_K_idx;
   int tg_K_idx;
   bool tmp_K;
   int range=0;
   int i;
   while(true)
   {
      range++;
      rate_num = CopyRates(_Symbol, _Period, 2+cnt-1, 10*range, rates);
      
      // for finding last converted K bar
      for(i=ArraySize(rates)-1; i>=0; i--)
      {
         if(rates[i].open == rates[i].close)
            continue;
         tmp_K = rates[i].open > rates[i].close;
         if(last_K == 0 && tmp_K == 1)
         {
            PrintFormat("Got the last conversion K bar at idx: %d", i);
            PrintFormat("GREEN open: %f, close: %f", rates[i].open, rates[i].close);
            cnv_K_idx = i;
            break;
         }
         else if(last_K == 1 && tmp_K==0)
         {
            PrintFormat("Got the last conversion K bar at idx: %d", i);
            PrintFormat("RED open: %f, close: %f", rates[i].open, rates[i].close);
            cnv_K_idx = i;
            break;
         }
      }
      if(i==-1)
         continue;
         
      // for finding target K bar
      for(i=cnv_K_idx; i>=0; i--)
      {
         if(rates[i].open == rates[i].close)
            continue;
         tmp_K = rates[i].open > rates[i].close;
         if(last_K == 0 && tmp_K == 0)
         {
            PrintFormat("Got the target K bar at idx: %d", i);
            PrintFormat("RED open: %f, close: %f, high: %f, low: %f", 
                        rates[i].open, rates[i].close, rates[i].high, rates[i].low);
            tg_K_idx = i;
            break;
         }
         else if(last_K == 1 && tmp_K == 1)
         {
            PrintFormat("Got the target K bar at idx: %d", i);
            PrintFormat("GREEN open: %f, close: %f, high: %f, low: %f", 
                        rates[i].open, rates[i].close, rates[i].high, rates[i].low);
            tg_K_idx = i;
            break;
         }
      }
      if(i!=-1)
         break;
   }
   PrintFormat("range: %d, cnv_K_idx: %d, tg_K_idx: %d, i: %d", range*10, cnv_K_idx, tg_K_idx, i);
   
   if(last_K==0 && last_close > rates[tg_K_idx].high)
   {
      
      PrintFormat("last_close > target K bar's high , Buy");
      buy();
   }   
   else if(last_K==1 && last_close < rates[tg_K_idx].low)
   {
      PrintFormat("last_close < target K bar's low, Sell");
      sell();   
   }
   else
   {
      PrintFormat("Didn't meet the strategy, do nothing in this peroid!");
   }
   Print("====================================================");
}