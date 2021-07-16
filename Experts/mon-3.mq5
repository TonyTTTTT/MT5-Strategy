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
//input short MA_window_param = 300;
input ENUM_TIMEFRAMES peroid_param = PERIOD_CURRENT;
MqlRates rates[];

int MA_handle;
double MA[];
int KD_handle;
double Stoch[];
double Signal[];
double last_golden_close = 65536;
double last_death_close = -65536;

int OnInit()
  {
//---
   //ChartSetSymbolPeriod(0,"XAUUSD",_Period);
   Print("Successful initialization!");
   Print("current symbol: ", _Symbol);
   Print("current peroid: ", PeriodSeconds());
   //MA_handle = iMA(_Symbol, peroid_param, MA_window_param, 0, MODE_SMA, PRICE_CLOSE);
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
   
   int Stoch_num = CopyBuffer(KD_handle, 0, 0, 3, Stoch);
   if(Stoch_num != -1)
      PrintFormat("Stoch: %f, last Stoch: %f", Stoch[1], Stoch[0]);
      
   int Signal_num = CopyBuffer(KD_handle, 1, 0, 3, Signal);
   if(Signal_num != -1)
      PrintFormat("Signal: %f, last Signal: %f", Signal[1], Signal[0]);   
   
   /*int MA_num = CopyBuffer(MA_handle, 0, 0, 3, MA);
   if(MA_num != -1)
      PrintFormat("MA = %f, last MA = %f", MA[1], MA[0]);*/
   
   int rate_num = CopyRates(_Symbol, _Period, 0, 2, rates);
   if(rate_num == -1)
      Print("Error occur when calling CopyRates()");
   
   
   if(Stoch_num == -1 || Signal_num == -1)
      Print("Error occur when calling iStoch()");
   else if(Stoch[1] > Signal[1] && Stoch[0] < Signal[0])
   {
      Print("Golden Cross!");
      PrintFormat("last_golden_close: %f", last_golden_close);
      if(rates[0].close > last_golden_close)
      {
         OrderSender order_sender();
         order_sender.buy();
      }
      last_golden_close = rates[0].close;
   }
   else if(Stoch[1] < Signal[1] && Stoch[0] > Signal[0])
   {
      Print("Death Cross!");
      PrintFormat("last_death_close: %f", last_death_close);
      if(rates[0].close < last_death_close)
      {
         OrderSender order_sender();
         order_sender.sell();         
      }
      last_death_close = rates[0].close;
   }
   
   /*if(pDI[1] > nDI[1] && pDI[0] < nDI[0])
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
   }*/
   
   
   Print("====================================================");
}