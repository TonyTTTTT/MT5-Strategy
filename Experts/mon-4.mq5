//+------------------------------------------------------------------+
//|                                                         test.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include "send-transaction-close.mqh"
#include "ADXGenerator.mqh"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int ADX_handle;
double pDI[];
double nDI[];
int OnInit()
  {
//---
   //ChartSetSymbolPeriod(0,"XAUUSD",_Period);
   Print("Successful initialization!");
   Print("current symbol: ", _Symbol);
   Print("current peroid: ", PeriodSeconds());
   ADX_handle = iADX(_Symbol, PERIOD_CURRENT, 14);
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
   
   if(CopyBuffer(ADX_handle, 1, 0, 3, pDI) < 0)
   {
      Print("err occur when calling iADX pDI");
   }
   if(CopyBuffer(ADX_handle, 2, 0, 3, nDI) < 0)
   {
      Print("err occur when calling iADX for nDI");
   }
   PrintFormat("pDI = %f, last pDI = %f", pDI[1], pDI[0]);
   PrintFormat("nDI = %f, last nDI = %f", nDI[1], nDI[0]);
   /*ADXGenerator adx_generator();
   
   double pDI_avg = adx_generator.getpDI();
   double nDI_avg = adx_generator.getnDI();
   PrintFormat("pDI_avg: %f, nDI_avg: %f", pDI_avg, nDI_avg);*/
   if(pDI[1] > nDI[1] && pDI[0] < nDI[0])
   {
      
      PrintFormat("pDI > nDI, Buy");
      OrderSender order_sender();
      order_sender.buy();
   }   
   else if(nDI[1] > pDI[1] && nDI[0] < pDI[0])
   {
      PrintFormat("nDI > pDI, Sell");
      OrderSender order_sender();
      order_sender.sell();   
   }
   else
   {
      PrintFormat("Didn't meet the strategy, do nothing in this peroid!");
   }
   Print("====================================================");
}