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

input ushort ADX_window_param = 14;
input short MA_window_param = 300;
input ENUM_TIMEFRAMES peroid_param = PERIOD_CURRENT;
int ADX_handle;
double pDI[];
double nDI[];
int MA_handle;
double MA[];
int KD_handle;

int OnInit()
  {
//---
   //ChartSetSymbolPeriod(0,"XAUUSD",_Period);
   Print("Successful initialization!");
   Print("current symbol: ", _Symbol);
   Print("current peroid: ", PeriodSeconds());
   ADX_handle = iADX(_Symbol, peroid_param, ADX_window_param);
   MA_handle = iMA(_Symbol, peroid_param, MA_window_param, 0, MODE_SMA, PRICE_CLOSE);
   KD_handle = iStochastic(_Symbol, peroid_param, 9, 3, 3, MODE_SMA, STO_CLOSECLOSE);
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
   
   int pDI_num = CopyBuffer(ADX_handle, 1, 0, 3, pDI);
   if(pDI_num != -1)
      PrintFormat("pDI = %f, last pDI = %f", pDI[1], pDI[0]);
   
   int nDI_num = CopyBuffer(ADX_handle, 2, 0, 3, nDI);
   if(nDI_num != -1)
      PrintFormat("nDI = %f, last nDI = %f", nDI[1], nDI[0]);
   
   int MA_num = CopyBuffer(MA_handle, 0, 0, 3, MA);
   if(MA_num != -1)
      PrintFormat("MA = %f, last MA = %f", MA[1], MA[0]);
   

   if(pDI[1] > nDI[1] && pDI[0] < nDI[0])
   {
      PrintFormat("pDI > nDI");
      
      if(MA_num == -1)
         Print("Error occur when calling iMA for MA, don't order");      
      if(SymbolInfoDouble(_Symbol, SYMBOL_ASK) > MA[1])
      {
         PrintFormat("ASK > MA, Buy");
         OrderSender order_sender();
         order_sender.buy();
      }
      else
         Print("Buy price < MA, don't buy");   
   }   
   else if(nDI[1] > pDI[1] && nDI[0] < pDI[0])
   {
      PrintFormat("nDI > pDI");
      
      if(MA_num == -1)
         Print("Error occur when calling iMA for MA, don't order");
      else if(SymbolInfoDouble(_Symbol, SYMBOL_BID) < MA[1])
      {
         PrintFormat("BID < MA, Sell");
         OrderSender order_sender();
         order_sender.sell();   
      }
      else
         Print("Sell price > MA, don't sell");   
   }
   else if(pDI_num == -1 || nDI_num == -1)
   {
      Print("Error occur when calling iADX for nDI or pDI, don't order");
   }   
   else
   {
      PrintFormat("Didn't meet the strategy, do nothing in this peroid!");
   }
   
   
   Print("====================================================");
}