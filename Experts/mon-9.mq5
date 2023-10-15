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
input ENUM_APPLIED_PRICE applied_price_param = PRICE_CLOSE;
MqlRates rates[];

int MA_handle;
int MA_low_handle;
int RSI_handle;
double MA[];
double rsi_buffer[];
double last_rsi_u50_price;
double last_rsi_d50_greenk_high_price;
double last_rsi_d50_redk_low_price;
bool red_k = true;

int OnInit()
  {
//---
   //ChartSetSymbolPeriod(0,"XAUUSD",_Period);
   Print("Successful initialization!");
   Print("current symbol: ", _Symbol);
   Print("current peroid: ", PeriodSeconds());
   MA_handle = iMA(_Symbol, peroid_param, MA_window_param, 0, MODE_SMA, applied_price_param);
   RSI_handle = iRSI(_Symbol, peroid_param, MA_window_param, applied_price_param);
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

   int rate_num = CopyRates(_Symbol, _Period, 0, 2, rates);
   
   if(rate_num != -1) {
      if (rates[0].close > rates[0].open)
         red_k = true;
      else
         red_k = false;   
   } else  {
      Print("Error occur when calling CopyRates()");
   }  


   int MA_num = CopyBuffer(MA_handle, 0, 0, 2, MA);
   
   if(MA_num != -1)
      PrintFormat("MA_%s: %f, last MA: %f", applied_price_param, MA[1], MA[0]);
   if(MA_num == -1)
      Print("Error occur when calling iMA()");


   int RSI_num = CopyBuffer(RSI_handle,0,0,1,rsi_buffer);
   
   if (RSI_num != -1) {
      PrintFormat("RSI: %f", rsi_buffer[0]);
   } else {
      Print("error occur when calling RSI");
   }
      
      
   if (rsi_buffer[0] > 50) {
      if (rates[0].close>last_rsi_u50_price && rates[0].close>MA[0]) {
         PrintFormat("Meet buy strategy 1\ncurrent price: %f, last rsi up 50 price: %f,  %d_MA: %f\nBuy!", rates[0].close, last_rsi_u50_price, MA_window_param, MA[0]);
         OrderSender order_sender();
         order_sender.buy();
      }
      if (red_k)
         last_rsi_d50_redk_low_price = rates[0].low;
      last_rsi_u50_price = rates[0].close;
   } else if (rsi_buffer[0] < 50) {
      
      
      if (!red_k)
         last_rsi_d50_greenk_high_price = rates[0].high;
   }
   
   if (rates[0].close>last_rsi_d50_greenk_high_price && rates[0].close>MA) {
      PrintFormat("Meet buy strategy 2\ncurrent price: %f, last rsi down 50 green k high price: %f,  %d_MA: %f\nBuy!", rates[0].close, last_rsi_d50_greenk_high_price, MA_window_param, MA[0]);
      OrderSender order_sender();
      order_sender.buy();
   } else if (rates[0].close<last_rsi_d50_redk_low_price && rates[0].close<MA) {
      PrintFormat("Meet sell strategy 2\ncurrent price: %f, last rsi up 50 red k low price: %f,  %d_MA: %f\nBuy!", rates[0].close, last_rsi_d50_redk_low_price, MA_window_param, MA[0]);
      OrderSender order_sender();
      order_sender.sell();      
   }



   else
   {
      PrintFormat("Didn't meet the strategy, do nothing in this peroid!");
   }
   
   Print("====================================================");
}