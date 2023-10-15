//+------------------------------------------------------------------+
//|                                                         test.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include "send-transaction-close.mqh"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

//input ushort ADX_window_param = 14;
input short MA_window_param = 5;
input ENUM_TIMEFRAMES peroid_param = PERIOD_CURRENT;
MqlRates rates[];

int MA_high_handle;
int MA_low_handle;
double MA_high[];
double MA_low[];

int OnInit()
  {
//---
   //ChartSetSymbolPeriod(0,"XAUUSD",_Period);
   Print("Successful initialization!");
   Print("current symbol: ", _Symbol);
   Print("current peroid: ", PeriodSeconds());
   MA_high_handle = iMA(_Symbol, peroid_param, MA_window_param, 0, MODE_SMA, PRICE_HIGH);
   MA_low_handle = iMA(_Symbol, peroid_param, MA_window_param, 0, MODE_SMA, PRICE_LOW);
   EventSetTimer(PeriodSeconds(peroid_param));
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
   
   int MA_high_num = CopyBuffer(MA_high_handle, 0, 0, 2, MA_high);
   if(MA_high_num != -1)
      PrintFormat("MA_high: %f, last MA_high: %f", MA_high[1], MA_high[0]);
      
   int MA_low_num = CopyBuffer(MA_low_handle, 0, 0, 2, MA_low);
   if(MA_low_num != -1)
      PrintFormat("MA_low: %f, last MA_low: %f", MA_low[1], MA_low[0]);   
   
   int rate_num = CopyRates(_Symbol, _Period, 0, 2, rates);
   if(rate_num == -1)
      Print("Error occur when calling CopyRates()");
   
   
   if(MA_high_num == -1 || MA_low_num == -1)
      Print("Error occur when calling iMA()");
   else if(rates[0].close > MA_high[0])
   {
      PrintFormat("last close > %d_MA_high, Buy!", MA_window_param);
      OrderSender order_sender();
      order_sender.buy();
   }
   else if(rates[0].close < MA_low[0])
   {
      PrintFormat("last close < %d_MA_low, Sell!", MA_window_param);
      OrderSender order_sender();
      order_sender.sell();         
   }
   else
   {
      PrintFormat("Didn't meet the strategy, do nothing in this peroid!");
   }
   
   Print("====================================================");
}