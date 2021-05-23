//+------------------------------------------------------------------+
//|                                               Script Example.mq5 |
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
//---
   Print("Hello World!");
   string target = "XAUUSD";
   int total = SymbolsTotal(true);
   Print("There is ", total," target asset in total.");
   Print("Current target is ", Symbol());
   double price_diff = 0;
   while(price_diff < 1)
   {
      double volume = SymbolInfoDouble(target, SYMBOL_VOLUME_REAL);
      Print(target," current volume: ",volume);
      double bid_price = SymbolInfoDouble(target, SYMBOL_BID);
      double ask_price = SymbolInfoDouble(target, SYMBOL_ASK);
      //---Print("Ask Price of ",target," is ", ask_price," now");
      //---Print("Bid Price of ",target," is ", bid_price," now");
      price_diff = MathAbs(ask_price - bid_price);
      Print("Price differ is " , price_diff);
      Sleep(1000);
   }
  }
//+------------------------------------------------------------------+
